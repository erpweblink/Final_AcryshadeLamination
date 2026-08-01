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

public partial class Reports_TrendingReports : System.Web.UI.Page
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
                    string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'TrendingReports.aspx'";
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
            }
        }
    }
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        GvReports.AllowPaging = false;

        FillGrid(); // rebind data

        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition",
            "attachment;filename=TrendingReport.xls");
        Response.Charset = "";
        Response.ContentType = "application/vnd.ms-excel";

        using (StringWriter sw = new StringWriter())
        {
            HtmlTextWriter hw = new HtmlTextWriter(sw);

            if (GvReports.HeaderRow != null)
            {
                GvReports.HeaderRow.BackColor = System.Drawing.Color.White;

                foreach (TableCell cell in GvReports.HeaderRow.Cells)
                {
                    cell.BackColor = GvReports.HeaderStyle.BackColor;
                }
            }

            foreach (GridViewRow row in GvReports.Rows)
            {
                row.BackColor = System.Drawing.Color.White;
            }

            GvReports.RenderControl(hw);

            Response.Write(sw.ToString());
            Response.Flush();
            Response.End();
        }
    }

    protected void txtproduct_TextChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    private void FillGrid()
    
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_Reports", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@SP_Action", "GetTrendingProduct");

                    // State Filter
                    if (!string.IsNullOrEmpty(txtstate.Text))
                        cmd.Parameters.AddWithValue("@State", txtstate.Text.Trim());
                    else
                        cmd.Parameters.AddWithValue("@State", DBNull.Value);

                    // Product Filter
                    if (!string.IsNullOrWhiteSpace(txtproduct.Text))
                        cmd.Parameters.AddWithValue("@ProductName", txtproduct.Text.Trim());
                    else
                        cmd.Parameters.AddWithValue("@ProductName", DBNull.Value);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        GvReports.DataSource = dt;
                        GvReports.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }
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

    protected void txtstate_TextChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetstateList(string prefixText, int count)
    {
        return AutoFillStateList(prefixText);
    }

    public static List<string> AutoFillStateList(string prefixText)
    {
        List<string> items = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"
            SELECT DISTINCT TOP (20)
                   UM.BillState
            FROM tbl_UserMaster UM
            INNER JOIN tbl_WorkOrderHdr WH
                ON WH.Dealer = UM.CompanyName
            WHERE UM.UserRole = 'Dealer'
              AND UM.IsDeleted = 0
              AND UM.IsActivate = 1
              AND WH.IsDeleted = 0
              AND UM.BillState LIKE '%' + @Search + '%'
            ORDER BY UM.BillState";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Search", prefixText);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                string state = dr["BillState"].ToString();

                items.Add(
                    AutoCompleteExtender.CreateAutoCompleteItem(
                        state,   // Display Text
                        state    // Value
                    )
                );
            }
        }

        return items;
    }

    public override void VerifyRenderingInServerForm(Control control)
    {
        // Required for GridView export
    }
}