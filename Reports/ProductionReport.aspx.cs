using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Reports_ProductionReport : System.Web.UI.Page
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
            //Check if you has access to the page of not
            {
                string username = Session["ID"].ToString();
                using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                {
                    string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'ProductionReport.aspx'";
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

            if (!IsPostBack)
            {
                FillGrid();
                BindMachine();
            }
        }
    }

    private void FillGrid()
    {
        DataTable dt = new DataTable();

        using (SqlDataAdapter cmd = new SqlDataAdapter("SP_Reports", con))
        {
            cmd.SelectCommand.CommandType = CommandType.StoredProcedure;

            cmd.SelectCommand.Parameters.Add("@SP_Action", SqlDbType.NVarChar, 100)
                .Value = "ProductionsReport";

            cmd.SelectCommand.Parameters.Add("@DeliveryStatus", SqlDbType.NVarChar, 100)
                .Value = ddlDeliveryStatus.SelectedValue ?? "";

            cmd.SelectCommand.Parameters.Add("@DealerName", SqlDbType.NVarChar, 200)
                .Value = txtDealer.Text.Trim();

            cmd.SelectCommand.Parameters.Add("@ProductName", SqlDbType.NVarChar, -1)
                .Value = txtproduct.Text.Trim();


            cmd.SelectCommand.Parameters.Add("@DispatchStatus", SqlDbType.NVarChar, 100)
        .Value = ddlstatus.SelectedValue ?? "";

            string machineName = null;

            if (ddlMachine != null && ddlMachine.SelectedItem != null)
            {
                if (!string.IsNullOrEmpty(ddlMachine.SelectedValue))
                {
                    machineName = ddlMachine.SelectedItem.Text.Trim();
                }
            }

            cmd.SelectCommand.Parameters.Add("@MachineName", SqlDbType.NVarChar, 100)
                .Value = (object)machineName ?? DBNull.Value;



            cmd.Fill(dt);
        }


        GvProduction.DataSource = dt;
        GvProduction.DataBind();
    }

    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        GvProduction.AllowPaging = false;

        FillGrid(); // rebind data

        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition",
            "attachment;filename=ProductionReport_"+DateTime.Now+".xls");
        Response.Charset = "";
        Response.ContentType = "application/vnd.ms-excel";

        using (StringWriter sw = new StringWriter())
        {
            HtmlTextWriter hw = new HtmlTextWriter(sw);

            if (GvProduction.HeaderRow != null)
            {
                GvProduction.HeaderRow.BackColor = System.Drawing.Color.White;

                foreach (TableCell cell in GvProduction.HeaderRow.Cells)
                {
                    cell.BackColor = GvProduction.HeaderStyle.BackColor;
                }
            }

            foreach (GridViewRow row in GvProduction.Rows)
            {
                row.BackColor = System.Drawing.Color.White;
            }

            GvProduction.RenderControl(hw);

            Response.Write(sw.ToString());
            Response.Flush();
            Response.End();
        }
    }

    public override void VerifyRenderingInServerForm(Control control)
    {
        // Required for GridView export
    }

    protected void ddlDeliveryStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetCompanyList(string prefixText, int count)
    {
        return AutoFillGetDealerNameList(prefixText);
    }

    public static List<string> AutoFillGetDealerNameList(string prefixText)
    {
        List<string> items = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"
            SELECT DISTINCT ID, FullName
            FROM tbl_UserMaster
            WHERE Type='Authorized'
              AND UserRole='Dealer'
              AND IsDeleted=0
              AND FullName LIKE '%' + @Search + '%'";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Search", prefixText);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                string dealerName = dr["FullName"].ToString();
                string dealerId = dr["ID"].ToString();

                items.Add(
                    AutoCompleteExtender.CreateAutoCompleteItem(
                        dealerName,
                        dealerId
                    )
                );
            }
        }

        return items;
    }
    protected void txtDealer_TextChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetproductList(string prefixText, int count)
    {
        return AutoFillGetProductList(prefixText);
    }

    public static List<string> AutoFillGetProductList(string prefixText)
    {
        List<string> items = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"
            SELECT TOP 20
                   ID,
                   Productname,
                   PartNo,
                   Size,
                   ImagenamePath
            FROM tbl_prodcutmaster
            WHERE Productname LIKE '%' + @Search + '%'
              AND IsDeleted = 0
              AND IsActive = 1
            ORDER BY Productname";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Search", prefixText);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                string productId = dr["ID"].ToString();
                string productName = dr["Productname"].ToString();

                items.Add(
                    AutoCompleteExtender.CreateAutoCompleteItem(
                        productName,
                        productId
                    )
                );
            }
        }

        return items;
    }

   
    private void BindMachine()
    {
        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"SELECT ID, MachineName 
                         FROM tbl_MachineMaster
                         WHERE IsDeleted = 0
                         ORDER BY MachineName";

            SqlCommand cmd = new SqlCommand(query, con);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            ddlMachine.DataSource = dr;
            ddlMachine.DataTextField = "MachineName";
            ddlMachine.DataValueField = "ID";
            ddlMachine.DataBind();

            ddlMachine.Items.Insert(0, new ListItem("All", ""));
        }
    }


}


