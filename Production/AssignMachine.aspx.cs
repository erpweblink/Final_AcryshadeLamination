using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class AssignMachine : System.Web.UI.Page
{
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
                //Check if you has access to the page of not
                {
                    string username = Session["ID"].ToString();
                    using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                    {
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'AssignMachine.aspx'";
                        SqlCommand cmds = new SqlCommand(query, cons);
                        cmds.Parameters.AddWithValue("@UserID", username);
                        cons.Open();
                        object result = cmds.ExecuteScalar();
                        if (result == null || result.ToString() != "True")
                        {
                            Response.Redirect("/AccessDenied.aspx");
                        }
                    }
                }

                BindOperators();
                BindStages();
            }
        }
    }

    private void BindOperators()
    {
        DataTable dtOperators = new DataTable();

        // Adjust this WHERE clause to match how operators are identified in tbl_UserMaster
        string query = @"SELECT ID, FullName FROM tbl_UserMaster WHERE UserRole = 'Operator' AND IsDeleted = 0 ORDER BY FullName";

        using (SqlConnection conOp = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        using (SqlCommand cmd = new SqlCommand(query, conOp))
        {
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dtOperators);
        }

        rptOperators.DataSource = dtOperators;
        rptOperators.DataBind();
    }

    private void BindStages()
    {
        DataTable dtStages = new DataTable();

        using (SqlConnection conStg = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            SqlDataAdapter daStages = new SqlDataAdapter(
                "SELECT ID, SatgeName AS StageName FROM tbl_StageMaster WHERE IsDeleted = 0", conStg);
            daStages.Fill(dtStages);
        }

        DataTable dtMachines = new DataTable();

        using (SqlConnection conMac = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"
                SELECT 
                    MM.ID AS MachineId, 
                    MM.MachineName, 
                    SM.ID AS StageId,
                    CASE WHEN EXISTS (
                        SELECT 1 FROM tbl_AssignedMachines L
                        WHERE L.MachineId = MM.ID AND L.LogoutTime IS NULL
                    ) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsAssigned,
                    (
                        SELECT TOP 1 UM.FullName
                        FROM tbl_AssignedMachines L2
                        INNER JOIN tbl_UserMaster UM ON UM.ID = L2.LoginBy
                        WHERE L2.MachineId = MM.ID AND L2.LogoutTime IS NULL
                    ) AS OperatorName
                FROM tbl_MachineMaster MM
                INNER JOIN tbl_StageMaster SM ON MM.AllocatedStage = SM.SatgeName
                WHERE MM.IsDeleted = 0 AND SM.IsDeleted = 0";

            SqlDataAdapter daMachines = new SqlDataAdapter(query, conMac);
            daMachines.Fill(dtMachines);
        }

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
    public static object AssignOperatorToMachine(int operatorId, int machineId, int stageId, bool force)
    {
        try
        {
            if (HttpContext.Current.Session["ID"] == null)
            {
                return new { Success = false, Message = "Session expired. Please log in again." };
            }

            int adminId = Convert.ToInt32(HttpContext.Current.Session["ID"]);

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                using (SqlTransaction tran = con.BeginTransaction())
                {
                    try
                    {
                        // 1. Check if machine is currently open with someone
                        int otherLoginId = 0;
                        string otherOperatorName = "";

                        string checkOtherQuery = @"
                            SELECT TOP 1 L.LoginBy, UM.FullName
                            FROM tbl_AssignedMachines L
                            INNER JOIN tbl_UserMaster UM ON UM.ID = L.LoginBy
                            WHERE L.MachineId = @MachineId
                              AND L.LogoutTime IS NULL";

                        using (SqlCommand cmdCheck = new SqlCommand(checkOtherQuery, con, tran))
                        {
                            cmdCheck.Parameters.AddWithValue("@MachineId", machineId);

                            using (SqlDataReader dr = cmdCheck.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    otherLoginId = Convert.ToInt32(dr["LoginBy"]);
                                    otherOperatorName = dr["FullName"].ToString();
                                }
                            }
                        }

                        // 2. Already assigned to the SAME operator -> nothing to do
                        if (otherLoginId == operatorId)
                        {
                            tran.Rollback();
                            return new { Success = false, Message = "This machine is already assigned to this operator." };
                        }

                        // 3. Busy with a different operator, not forcing -> block
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

                        // 4. Close whoever is currently on this machine (if forcing)
                        if (otherLoginId > 0)
                        {
                            string closeMachineQuery = @"
                                UPDATE tbl_AssignedMachines
                                SET LogoutTime = GETDATE(), LogoutBy = @AdminId
                                WHERE MachineId = @MachineId AND LogoutTime IS NULL";

                            using (SqlCommand cmdCloseMachine = new SqlCommand(closeMachineQuery, con, tran))
                            {
                                cmdCloseMachine.Parameters.AddWithValue("@AdminId", adminId);
                                cmdCloseMachine.Parameters.AddWithValue("@MachineId", machineId);
                                cmdCloseMachine.ExecuteNonQuery();
                            }
                        }

                        // 5. Close the TARGET OPERATOR's own session on any OTHER machine
                        //    (an operator can only be actively assigned to one machine at a time)
                        string closeOperatorElsewhereQuery = @"
                            UPDATE tbl_AssignedMachines
                            SET LogoutTime = GETDATE(), LogoutBy = @AdminId
                            WHERE LoginBy = @OperatorId AND LogoutTime IS NULL";

                        using (SqlCommand cmdCloseOperator = new SqlCommand(closeOperatorElsewhereQuery, con, tran))
                        {
                            cmdCloseOperator.Parameters.AddWithValue("@AdminId", adminId);
                            cmdCloseOperator.Parameters.AddWithValue("@OperatorId", operatorId);
                            cmdCloseOperator.ExecuteNonQuery();
                        }

                        // 6. Insert new assignment
                        string insertQuery = @"
                            INSERT INTO tbl_AssignedMachines (MachineId, StageId, LoginBy, LoginTime)
                            VALUES (@MachineId, @StageId, @OperatorId, GETDATE())";

                        using (SqlCommand cmdInsert = new SqlCommand(insertQuery, con, tran))
                        {
                            cmdInsert.Parameters.AddWithValue("@MachineId", machineId);
                            cmdInsert.Parameters.AddWithValue("@StageId", stageId);
                            cmdInsert.Parameters.AddWithValue("@OperatorId", operatorId);
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

            return new { Success = true };
        }
        catch (Exception ex)
        {
            return new { Success = false, Message = ex.Message };
        }
    }

    [System.Web.Services.WebMethod(EnableSession = true)]
    public static object UnassignMachine(int machineId)
    {
        try
        {
            if (HttpContext.Current.Session["ID"] == null)
            {
                return new { Success = false, Message = "Session expired. Please log in again." };
            }

            int adminId = Convert.ToInt32(HttpContext.Current.Session["ID"]);

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                string query = @"
                    UPDATE tbl_AssignedMachines
                    SET LogoutTime = GETDATE(), LogoutBy = @AdminId
                    WHERE MachineId = @MachineId AND LogoutTime IS NULL";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@AdminId", adminId);
                    cmd.Parameters.AddWithValue("@MachineId", machineId);

                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected == 0)
                    {
                        return new { Success = false, Message = "No active assignment found on this machine." };
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

}


