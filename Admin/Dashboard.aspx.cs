using OfficeOpenXml;
using OfficeOpenXml.Style;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI.WebControls;


public partial class Dashboard : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserCode"] == null)
        {
            Response.Redirect("../Login.aspx");
        }
        else
        {
            if (!IsPostBack)
            {
                if (Session["Role"].ToString() == "Admin")
                {
                    divAdmin.Visible = true;
                }
                if (Session["Role"].ToString() == "Operator")
                {
                    divOperator.Visible = true;
                    BindStages();
                }

            }
        }

    }

    private void BindStages()
    {
        DataTable dtStages = new DataTable();
        SqlDataAdapter daStages = new SqlDataAdapter(
            "SELECT ID, SatgeName AS StageName FROM tbl_StageMaster WHERE IsDeleted = 0", con);
        daStages.Fill(dtStages);

        int loginId = Convert.ToInt32(Session["ID"]);

        DataTable dtMachines = new DataTable();
        SqlCommand cmd = new SqlCommand(@"       
        SELECT 
            MM.ID AS MachineId, 
            MM.MachineName, 
            SM.ID AS StageId,
            CASE WHEN EXISTS (
                SELECT 1 FROM tbl_AssignedMachines L
                WHERE L.MachineId = MM.ID
                  AND L.LoginBy = @LoginId
                  AND L.LogoutTime IS NULL
            ) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsSelected,
            CASE WHEN EXISTS (
                SELECT 1 FROM tbl_AssignedMachines L2
                WHERE L2.MachineId = MM.ID
                  AND L2.LoginBy <> @LoginId
                  AND L2.LogoutTime IS NULL
            ) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsBusy,
            (
                SELECT TOP 1 UM.FullName
                FROM tbl_AssignedMachines L3
                INNER JOIN tbl_UserMaster UM ON UM.ID = L3.LoginBy
                WHERE L3.MachineId = MM.ID
                  AND L3.LogoutTime IS NULL
            ) AS OperatorName
        FROM tbl_MachineMaster MM
        INNER JOIN tbl_StageMaster SM ON MM.AllocatedStage = SM.SatgeName
        WHERE MM.IsDeleted = 0 AND SM.IsDeleted = 0", con);

        cmd.Parameters.AddWithValue("@LoginId", loginId);

        SqlDataAdapter daMachines = new SqlDataAdapter(cmd);
        daMachines.Fill(dtMachines);

        ViewState["MachinesTable"] = dtMachines;

        rptStages.DataSource = dtStages;
        rptStages.DataBind();
    }

    protected void rptStages_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            DataRowView drv = (DataRowView)e.Item.DataItem;
            int stageId = Convert.ToInt32(drv["ID"]);

            DataTable dtMachines = (DataTable)ViewState["MachinesTable"];

            DataView dvFiltered = new DataView(dtMachines);
            dvFiltered.RowFilter = "StageId = " + stageId;

            Repeater rptMachines = (Repeater)e.Item.FindControl("rptMachines");
            rptMachines.DataSource = dvFiltered;
            rptMachines.DataBind();
        }
    }


    [System.Web.Services.WebMethod(EnableSession = true)]
    public static object SelectMachine(int machineId, int stageId, bool force)
    {
        try
        {
            if (HttpContext.Current.Session["ID"] == null)
            {
                return new { Success = false, Message = "Session expired. Please log in again." };
            }

            int loginId = Convert.ToInt32(HttpContext.Current.Session["ID"]);

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                using (SqlTransaction tran = con.BeginTransaction())
                {
                    try
                    {
                        // 1. Check if machine is currently open with SOMEONE ELSE
                        int otherLoginId = 0;
                        string otherOperatorName = "";

                        string checkOtherQuery = @"
                        SELECT TOP 1 L.LoginBy, UM.FullName
                        FROM tbl_AssignedMachines L
                        INNER JOIN tbl_UserMaster UM ON UM.ID = L.LoginBy
                        WHERE L.MachineId = @MachineId
                          AND L.LoginBy <> @LoginId
                          AND L.LogoutTime IS NULL";

                        using (SqlCommand cmdCheck = new SqlCommand(checkOtherQuery, con, tran))
                        {
                            cmdCheck.Parameters.AddWithValue("@MachineId", machineId);
                            cmdCheck.Parameters.AddWithValue("@LoginId", loginId);

                            using (SqlDataReader dr = cmdCheck.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    otherLoginId = Convert.ToInt32(dr["LoginBy"]);
                                    otherOperatorName = dr["FullName"].ToString();
                                }
                            }
                        }

                        // 2. If busy with someone else and NOT forcing, block and inform frontend
                        if (otherLoginId > 0 && !force)
                        {
                            tran.Rollback();
                            return new
                            {
                                Success = false,
                                Busy = true,
                                OperatorName = otherOperatorName,
                                Message = "This machine is currently used by " + otherOperatorName + "."
                            };
                        }

                        // 3. If forcing, log out the other user from this machine
                        if (otherLoginId > 0 && force)
                        {
                            string forceLogoutQuery = @"
                            UPDATE tbl_AssignedMachines
                            SET LogoutTime = GETDATE(), LogoutBy = @LogoutBy
                            WHERE MachineId = @MachineId
                              AND LoginBy = @OtherLoginId
                              AND LogoutTime IS NULL";

                            using (SqlCommand cmdForce = new SqlCommand(forceLogoutQuery, con, tran))
                            {
                                cmdForce.Parameters.AddWithValue("@LogoutBy", loginId);
                                cmdForce.Parameters.AddWithValue("@MachineId", machineId);
                                cmdForce.Parameters.AddWithValue("@OtherLoginId", otherLoginId);
                                cmdForce.ExecuteNonQuery();
                            }
                        }

                        // 4. Close current user's own open session on ANY machine
                        string cmdCloseQuery = @"
                        UPDATE tbl_AssignedMachines 
                        SET LogoutTime = GETDATE(), LogoutBy = @LoginId
                        WHERE LoginBy = @LoginId AND LogoutTime IS NULL";

                        using (SqlCommand cmdClose = new SqlCommand(cmdCloseQuery, con, tran))
                        {
                            cmdClose.Parameters.AddWithValue("@LoginId", loginId);
                            cmdClose.ExecuteNonQuery();
                        }

                        // 5. Insert new check-in for the selected machine
                        string cmdInsertQuery = @"
                        INSERT INTO tbl_AssignedMachines (MachineId, StageId, LoginBy, LoginTime)
                        VALUES (@MachineId, @StageId, @LoginId, GETDATE())";

                        using (SqlCommand cmdInsert = new SqlCommand(cmdInsertQuery, con, tran))
                        {
                            cmdInsert.Parameters.AddWithValue("@MachineId", machineId);
                            cmdInsert.Parameters.AddWithValue("@StageId", stageId);
                            cmdInsert.Parameters.AddWithValue("@LoginId", loginId);
                            cmdInsert.ExecuteNonQuery();
                        }

                        tran.Commit();
                    }
                    catch
                    {
                        tran.Rollback();
                        throw;
                    }
                }
            }

            return new { Success = true, MachineId = machineId };
        }
        catch (Exception ex)
        {
            return new { Success = false, Message = ex.Message };
        }
    }

    [System.Web.Services.WebMethod(EnableSession = true)]
    public static object LogoutMachine(int machineId)
    {
        try
        {
            if (HttpContext.Current.Session["ID"] == null)
            {
                return new { Success = false, Message = "Session expired. Please log in again." };
            }

            int loginId = Convert.ToInt32(HttpContext.Current.Session["ID"]);

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                string logoutQuery = @"
                UPDATE tbl_AssignedMachines
                SET LogoutTime = GETDATE(), LogoutBy = @LoginId
                WHERE MachineId = @MachineId
                  AND LoginBy = @LoginId
                  AND LogoutTime IS NULL";

                using (SqlCommand cmd = new SqlCommand(logoutQuery, con))
                {
                    cmd.Parameters.AddWithValue("@MachineId", machineId);
                    cmd.Parameters.AddWithValue("@LoginId", loginId);

                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected == 0)
                    {
                        return new { Success = false, Message = "No active session found for you on this machine." };
                    }
                }
            }

            return new { Success = true };
        }
        catch (Exception ex)
        {
            return new { Success = false, Message = ex.Message };
        }
    }




    [WebMethod]
    public static Dictionary<string, object> GetDashboard(string fromDate, string toDate)
    {
        Dictionary<string, object> result = new Dictionary<string, object>();

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            result["Stage1"] = ToList(GetDataTable(con, "Todaysproductionsstage1", fromDate, toDate));
            result["Stage2"] = ToList(GetDataTable(con, "Todaysproductionsstage2", fromDate, toDate));
            result["Packaging"] = ToList(GetDataTable(con, "TodaysPackaging", fromDate, toDate));
            result["Orders"] = ToList(GetDataTable(con, "OrderCount", fromDate, toDate));
            result["Rejected"] = ToList(GetDataTable(con, "Returncount", fromDate, toDate));
            result["Dispatch"] = ToList(GetDataTable(con, "Dispatchedcount", fromDate, toDate));
            result["DownTime"] = ToList(GetDataTable(con, "GetBreakdown", fromDate, toDate));
            result["Productivity"] = ToList(GetDataTable(con, "TodaysProductivity", fromDate, toDate));
            result["MonthlyProduction"] = ToList(GetDataTable(con, "Currentmonthproductions", fromDate, toDate));
            result["DealerCount"] = ToList(GetDataTable(con, "CardsDetails", fromDate, toDate));
            result["ProductionGraph"] = ToList(GetDataTable(con, "ProductionGraph", fromDate, toDate));
        }

        return result;
    }

    private static List<Dictionary<string, object>> ToList(DataTable dt)
    {
        List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();

        foreach (DataRow dr in dt.Rows)
        {
            Dictionary<string, object> row = new Dictionary<string, object>();

            foreach (DataColumn col in dt.Columns)
            {
                row[col.ColumnName] = dr[col];
            }

            rows.Add(row);
        }

        return rows;
    }


    private static DataTable GetDataTable(SqlConnection con, string action, string fromDate, string toDate)
    {
        DataTable dt = new DataTable();

        using (SqlDataAdapter da = new SqlDataAdapter("SP_DashboardDetails", con))
        {
            da.SelectCommand.CommandType = CommandType.StoredProcedure;

            da.SelectCommand.Parameters.AddWithValue("@SP_Action", action);
            da.SelectCommand.Parameters.AddWithValue("@FromDate", fromDate);
            da.SelectCommand.Parameters.AddWithValue("@ToDate", toDate);

            da.Fill(dt);
        }

        return dt;
    }

    [WebMethod]
    public static object GetOrderDetails(string fromDate, string toDate, string type)
    {
        DataTable dt = new DataTable();

        string connStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SP_DashboardDetails", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@FromDate", fromDate);
                cmd.Parameters.AddWithValue("@ToDate", toDate);
                cmd.Parameters.AddWithValue("@Type", type);
                cmd.Parameters.AddWithValue("@SP_Action", "GetOrderDetails");

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();

            foreach (DataRow row in dt.Rows)
            {
                Dictionary<string, object> rowDict = new Dictionary<string, object>();

                foreach (DataColumn col in dt.Columns)
                {
                    rowDict[col.ColumnName] = row[col] == DBNull.Value ? null : row[col];
                }

                rows.Add(rowDict);
            }

            return rows;
        }
        catch (Exception ex)
        {
            // Log ex the same way GetDashboard does
            return new { Error = true, Message = ex.Message };
        }
    }


    [WebMethod]
    public static object GetOrderDetailsExcel(string fromDate, string toDate, string type)
    {
        DataTable dt = new DataTable();
        string connStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("SP_DashboardDetails", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@FromDate", fromDate);
            cmd.Parameters.AddWithValue("@ToDate", toDate);
            cmd.Parameters.AddWithValue("@Type", type);
            cmd.Parameters.AddWithValue("@SP_Action", "GetOrderDetails");

            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }

        var plainColumns = new[] { "W/O No.", "W/O Date", "Estimated Delivery Date", "ScheduledDate" };

        using (var package = new ExcelPackage())
        {
            var ws = package.Workbook.Worksheets.Add("Orders");

            // Header row
            for (int col = 0; col < dt.Columns.Count; col++)
            {
                var cell = ws.Cells[1, col + 1];
                cell.Value = dt.Columns[col].ColumnName;
                cell.Style.Fill.PatternType = ExcelFillStyle.Solid;
                cell.Style.Fill.BackgroundColor.SetColor(ColorTranslator.FromHtml("#3458a5"));
                cell.Style.Font.Color.SetColor(Color.White);
                cell.Style.Font.Bold = true;
                cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
            }

            // Data rows
            for (int row = 0; row < dt.Rows.Count; row++)
            {
                for (int col = 0; col < dt.Columns.Count; col++)
                {
                    string colName = dt.Columns[col].ColumnName;
                    string val = !string.IsNullOrWhiteSpace(dt.Rows[row][col].ToString()) ? dt.Rows[row][col].ToString() : "";

                    var cell = ws.Cells[row + 2, col + 1];
                    cell.Value = val;
                    cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    cell.Style.Font.Bold = true;

                    if (Array.IndexOf(plainColumns, colName) < 0)
                    {
                        cell.Style.Fill.PatternType = ExcelFillStyle.Solid;
                        cell.Style.Fill.BackgroundColor.SetColor(ColorTranslator.FromHtml(GetBadgeHex(val)));
                        cell.Style.Font.Color.SetColor(Color.White);
                    }
                }
            }

            ws.Cells[ws.Dimension.Address].AutoFitColumns();

            byte[] fileBytes = package.GetAsByteArray();
            string base64 = Convert.ToBase64String(fileBytes);

            return new
            {
                FileName = type.Replace(" ", "_") + "_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xlsx",
                FileContent = base64
            };
        }
    }

    private static string GetBadgeHex(string status)
    {
        switch (status)
        {
            case "W/O On Hold":
            case "Send For Design Approval":
            case "Not Scheduled":
            case "Work Started":
            case "Partially Active":
            case "Production Pending":
            case "In Production":
            case "Pending":
            case "Out For Delivery":
                return "#E8A33D";

            case "W/O Canceled":
            case "Rejected From Designer":
            case "Rejected":
            case "Work Not Started":
            case "W/O Not Allocated":
            case "Not Packed":
            case "Not Dispatched":
                return "#E5566D";

            case "Approved From Designer":
            case "Approved":
            case "Scheduled":
            case "Completed":
            case "Packed":
            case "Production Completed":
            case "Delivered":
                return "#1FA97A";

            case "Active":
            case "Dispatched":
                return "#2AAFD6";

            default:
                return "#6b7280";
        }
    }


    [WebMethod]
    public static List<Dictionary<string, object>> GetNotifications()
    {
        var notifications = new List<Dictionary<string, object>>();

        if (HttpContext.Current.Session["Role"].ToString() == "Admin")
        {
            string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand(@"
                SELECT DH.ID,
                       OrderID,
                       UM.FullName AS DealerName,
                       CONVERT(varchar(10), CreatedDate, 105) AS CDate,
                       COUNT(DD.HeaderID) AS TotProducts,
                       SUM(CAST(Qty AS decimal)) AS ProductQty,
                       CASE WHEN DH.HoldStatus = 1 AND DH.HoldStatus IS NOT NULL THEN 'ON HOLD' ELSE '' END as HoldStatus
                FROM tbl_DealersOrderHDR DH
                INNER JOIN tbl_DealersOrderDTLs DD
                    ON DD.HeaderID = DH.ID
                LEFT JOIN tbl_UserMaster UM
                    ON UM.ID = DH.DealerID
                WHERE DH.OrderStatus ='Order Placed'
                GROUP BY DH.ID, OrderID, UM.FullName, CreatedDate,DH.OrderStatus,DH.HoldStatus
                ORDER BY DH.ID DESC", con);

                con.Open();

                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    notifications.Add(new Dictionary<string, object>
                {
                    { "Id", encrypt(dr["ID"].ToString()) },
                    { "orderId", dr["OrderID"].ToString() },
                    { "dealerName", dr["DealerName"].ToString() },
                    { "totalProducts", dr["TotProducts"].ToString() },
                    { "productQty", dr["ProductQty"].ToString() },
                    { "holdStatus", dr["HoldStatus"].ToString() },
                    { "orderDate", dr["CDate"].ToString() }
                });
                }
            }
        }

        return notifications;
    }

    public static string encrypt(string encryptString)
    {
        string encryptionKey = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        byte[] clearBytes = Encoding.Unicode.GetBytes(encryptString);

        using (Aes encryptor = Aes.Create())
        {
            using (Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(
                encryptionKey,
                new byte[]
                {
                0x49, 0x76, 0x61, 0x6E,
                0x20, 0x4D, 0x65, 0x64,
                0x76, 0x65, 0x64, 0x65,
                0x76
                }))
            {
                encryptor.Key = pdb.GetBytes(32);
                encryptor.IV = pdb.GetBytes(16);

                using (MemoryStream ms = new MemoryStream())
                {
                    using (CryptoStream cs = new CryptoStream(ms, encryptor.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        cs.Write(clearBytes, 0, clearBytes.Length);
                        cs.FlushFinalBlock();
                    }

                    // Convert to Base64
                    string encrypted = Convert.ToBase64String(ms.ToArray());

                    // Make URL-safe
                    encrypted = encrypted.Replace("+", "-")
                                         .Replace("/", "_")
                                         .Replace("=", "");

                    return encrypted;
                }
            }
        }
    }
}


