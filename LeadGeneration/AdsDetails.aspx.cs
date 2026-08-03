using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AdsDetails : System.Web.UI.Page
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
                //Check if you has access to the page of not
                {
                    string username = Session["ID"].ToString();
                    using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                    {
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'AdsDetails.aspx'";
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
                BindGrid();
            }
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        string formId = txtFormID.Text.Trim();
        string personalDetailsJson = hdnPersonalDetails.Value; // e.g. ["Full Name","Email","City"]
        string otherDetailsJson = hdnOtherDetails.Value;       // e.g. ["What best describes you?", ...]
        int editId = 0;
        int.TryParse(hdnEditID.Value, out editId);

        if (string.IsNullOrEmpty(personalDetailsJson) && string.IsNullOrEmpty(otherDetailsJson))
            return;

        if (editId > 0)
        {
            // UPDATE existing row
            using (var updateCmd = new SqlCommand(
                "UPDATE tbl_AdsQuestionsFormID SET FormID = @FormID, PersonalDetails = @PersonalDetails, OtherDetails = @OtherDetails WHERE ID = @ID", con))
            {
                updateCmd.Parameters.AddWithValue("@FormID", formId);
                updateCmd.Parameters.AddWithValue("@PersonalDetails", personalDetailsJson);
                updateCmd.Parameters.AddWithValue("@OtherDetails", otherDetailsJson);
                updateCmd.Parameters.AddWithValue("@ID", editId);

                con.Open();
                updateCmd.ExecuteNonQuery();
                con.Close();
            }
        }
        else
        {
            // INSERT new row
            using (var insertCmd = new SqlCommand(
                "INSERT INTO tbl_AdsQuestionsFormID (FormID, PersonalDetails, OtherDetails, CreatedDate, IsDeleted) " +
                "VALUES (@FormID, @PersonalDetails, @OtherDetails, @CreatedDate, @IsDeleted)", con))
            {
                insertCmd.Parameters.AddWithValue("@FormID", formId);
                insertCmd.Parameters.AddWithValue("@PersonalDetails", personalDetailsJson);
                insertCmd.Parameters.AddWithValue("@OtherDetails", otherDetailsJson);
                insertCmd.Parameters.AddWithValue("@CreatedDate", DateTime.Now);
                insertCmd.Parameters.AddWithValue("@IsDeleted", false);

                con.Open();
                insertCmd.ExecuteNonQuery();
                con.Close();
            }
        }

        // Reset form state
        txtFormID.Text = "";
        hdnPersonalDetails.Value = "";
        hdnOtherDetails.Value = "";
        hdnEditID.Value = "0";

        BindGrid();
    }

    protected void GVCompany_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "RowDelete")
        {
            using (var deleteCmd = new SqlCommand(
                "UPDATE tbl_AdsQuestionsFormID SET IsDeleted = 1 WHERE ID = @ID", con))
            {
                deleteCmd.Parameters.AddWithValue("@ID", id);

                con.Open();
                deleteCmd.ExecuteNonQuery();
                con.Close();
            }

            BindGrid();
        }
        else if (e.CommandName == "RowEdit")
        {
            LoadRecordForEdit(id);
        }
    }

    private void LoadRecordForEdit(int id)
    {
        DataTable dt = new DataTable();
        using (var selectCmd = new SqlCommand(
            "SELECT * FROM tbl_AdsQuestionsFormID WHERE ID = @ID", con))
        {
            selectCmd.Parameters.AddWithValue("@ID", id);
            SqlDataAdapter adapter = new SqlDataAdapter(selectCmd);
            adapter.Fill(dt);
        }

        if (dt.Rows.Count == 0)
            return;

        string formId = dt.Rows[0]["FormID"].ToString();
        string personalDetailsJson = dt.Rows[0]["PersonalDetails"].ToString();
        string otherDetailsJson = dt.Rows[0]["OtherDetails"].ToString();

        hdnEditID.Value = id.ToString();

        // Push data into JS so it can populate the form + dynamic rows
        string script = "loadEditData(" +
            JsonConvert.SerializeObject(formId) + ", " +
            JsonConvert.SerializeObject(personalDetailsJson) + ", " +
            JsonConvert.SerializeObject(otherDetailsJson) + ");";

        ScriptManager.RegisterStartupScript(this, this.GetType(), "loadEdit_" + id, script, true);

        BindGrid();
    }

    private void BindGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter adapter = new SqlDataAdapter(
            "SELECT * FROM tbl_AdsQuestionsFormID WHERE ISNULL(IsDeleted,0) = 0 ORDER BY ID DESC", con);
        adapter.Fill(dt);

        GVCompany.DataSource = dt;
        GVCompany.DataBind();
    }

    protected string GetFormDetailsTooltip(object personalDetailsObj, object otherDetailsObj)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();

        List<string> personalFields = ParseJsonList(personalDetailsObj);
        List<string> otherFields = ParseJsonList(otherDetailsObj);

        if (personalFields.Count > 0)
        {
            sb.Append("<b>Personal Details</b><br/>");
            for (int i = 0; i < personalFields.Count; i++)
            {
                sb.Append((i + 1) + ". " + System.Web.HttpUtility.HtmlEncode(personalFields[i]) + "<br/>");
            }
        }

        if (otherFields.Count > 0)
        {
            if (personalFields.Count > 0)
                sb.Append("<br/>");

            sb.Append("<b>Other Questions</b><br/>");
            for (int i = 0; i < otherFields.Count; i++)
            {
                sb.Append((i + 1) + ". " + System.Web.HttpUtility.HtmlEncode(otherFields[i]));
                if (i < otherFields.Count - 1)
                    sb.Append("<br/>");
            }
        }

        return sb.ToString();
    }

    private List<string> ParseJsonList(object jsonObj)
    {
        if (jsonObj == null || jsonObj == DBNull.Value)
            return new List<string>();

        string json = jsonObj.ToString();

        if (string.IsNullOrEmpty(json))
            return new List<string>();

        try
        {
            var list = JsonConvert.DeserializeObject<List<string>>(json);
            return list ?? new List<string>();
        }
        catch
        {
            return new List<string>();
        }
    }
}