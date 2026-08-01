using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Reports_MachineBreakdown : System.Web.UI.Page
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
                    string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'MachineBreakdown.aspx'";
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
        GvMachineBreak.AllowPaging = false;

        FillGrid(); // rebind data

        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition",
            "attachment;filename=MachineBreakDownReport.xls");
        Response.Charset = "";
        Response.ContentType = "application/vnd.ms-excel";

        using (StringWriter sw = new StringWriter())
        {
            HtmlTextWriter hw = new HtmlTextWriter(sw);

            if (GvMachineBreak.HeaderRow != null)
            {
                GvMachineBreak.HeaderRow.BackColor = System.Drawing.Color.White;

                foreach (TableCell cell in GvMachineBreak.HeaderRow.Cells)
                {
                    cell.BackColor = GvMachineBreak.HeaderStyle.BackColor;
                }
            }

            foreach (GridViewRow row in GvMachineBreak.Rows)
            {
                row.BackColor = System.Drawing.Color.White;
            }

            GvMachineBreak.RenderControl(hw);

            Response.Write(sw.ToString());
            Response.Flush();
            Response.End();
        }
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
                    cmd.Parameters.AddWithValue("@SP_Action", "GetOTmachine");

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        GvMachineBreak.DataSource = dt;
                        GvMachineBreak.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Handle error
            Response.Write(ex.Message);
        }
    }

    public override void VerifyRenderingInServerForm(Control control)
    {
        // Required for GridView export
    }
}