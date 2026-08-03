using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class LeadList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //Check if you has access to the page of not
            {
                string username = Session["ID"].ToString();
                using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                {
                    string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'LeadList.aspx'";
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

            // Initial full grid load can stay as-is, or you can leave it empty
            // and let JS call SearchLeads("", 10) on document ready instead.
        }
    }

    [WebMethod]
    public static string SearchLeads(string searchTerm, int pageSize, string statusFilter, string assignedFilter, string dealerFilter)
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string role = System.Web.HttpContext.Current.Session["Role"].ToString();
            string id = System.Web.HttpContext.Current.Session["ID"].ToString();
          
            SqlDataAdapter da = new SqlDataAdapter("SP_MetaLead", con);
            da.SelectCommand.CommandType = CommandType.StoredProcedure;
            da.SelectCommand.Parameters.AddWithValue("@SP_Action", "LeadList");
            da.SelectCommand.Parameters.AddWithValue("@Search", searchTerm);
            da.SelectCommand.Parameters.AddWithValue("@ShowRecords", pageSize);
            da.SelectCommand.Parameters.AddWithValue("@Status", statusFilter);
            da.SelectCommand.Parameters.AddWithValue("@AssignedFilter", assignedFilter);
            da.SelectCommand.Parameters.AddWithValue("@Role", role);
            da.SelectCommand.Parameters.AddWithValue("@Id", id);
            da.SelectCommand.Parameters.AddWithValue("@DealerIds", string.IsNullOrEmpty(dealerFilter) ? (object)DBNull.Value : dealerFilter);
            DataTable dt = new DataTable();
            da.Fill(dt);

            List<Dictionary<string, object>> results = new List<Dictionary<string, object>>();

            foreach (DataRow row in dt.Rows)
            {
                Dictionary<string, object> item = new Dictionary<string, object>();
                item["ID"] = row["ID"].ToString();
                item["PersonalInfo"] = row["PersonalInfo"].ToString();
                item["FormQuestion"] = row["FormQuestion"].ToString();
                item["CreatedDate"] = row["CreatedDate"].ToString();
                item["Status"] = row["Status"] == DBNull.Value ? "" : row["Status"].ToString();
                item["AssignedTo"] = row["AssignedTo"] == DBNull.Value ? "" : row["AssignedTo"].ToString();

                results.Add(item);
            }

            return JsonConvert.SerializeObject(results);

        }
    }

    [WebMethod]
    public static string GetDealers()
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ID, FullName as DealerName FROM tbl_UserMaster WHERE ISNULL(IsDeleted,0) = 0 AND UserRole='Dealer' ORDER BY DealerName", con))
            {
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                List<Dictionary<string, string>> dealers = new List<Dictionary<string, string>>();
                foreach (DataRow row in dt.Rows)
                {
                    dealers.Add(new Dictionary<string, string> {
                        { "ID", row["ID"].ToString() },
                        { "DealerName", row["DealerName"].ToString() }
                    });
                }

                return JsonConvert.SerializeObject(dealers);
            }
        }
    }

    [WebMethod]
    public static string UpdateLeadStatus(string leadId, string status)
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE tbl_MetaLeads SET Status = @Status WHERE ID = @ID", con))
            {
                cmd.Parameters.AddWithValue("@Status", string.IsNullOrWhiteSpace(status) ? DBNull.Value : (Object)status);
                cmd.Parameters.AddWithValue("@ID", leadId);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();
            }
        }

        return "Updated";
    }

    [WebMethod]
    public static string AssignDealerToLead(string leadId, string dealerId, string reminder)
    {
        string role = HttpContext.Current.Session["Role"] != null ? HttpContext.Current.Session["Role"].ToString() : "";
        if (role == "Dealer")
        {
            return "Access Denied";
        }

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE tbl_MetaLeads SET AssignedTo = @DealerID,AssignedDate = GETDATE(),AdminSideNextReminder = @reminder WHERE ID = @ID", con))
            {
                cmd.Parameters.AddWithValue("@DealerID", dealerId);
                cmd.Parameters.AddWithValue("@ID", leadId);
                cmd.Parameters.AddWithValue("@reminder", reminder);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();
            }
        }

        return "Assigned";
    }

    [WebMethod]
    public static string SaveFollowUp(int leadId, string feedback, string status, string reminder)
    {
        string createdBy = HttpContext.Current.Session["ID"].ToString();

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            SqlCommand cmd = new SqlCommand(@"
            INSERT INTO tbl_MetaLeadFollowUp
            (
                LeadId,
                Feedback,
                Status,
                ReminderDate,
                CreatedBy,
                CreatedDate
            )
            VALUES
            (
                @LeadId,
                @Feedback,
                @Status,
                @ReminderDate,
                @CreatedBy,
                GETDATE()
            )", con);

            cmd.Parameters.AddWithValue("@LeadId", leadId);
            cmd.Parameters.AddWithValue("@Feedback", feedback);
            cmd.Parameters.AddWithValue("@Status", status);

            if (string.IsNullOrEmpty(reminder))
                cmd.Parameters.AddWithValue("@ReminderDate", DBNull.Value);
            else
                cmd.Parameters.AddWithValue("@ReminderDate", Convert.ToDateTime(reminder));

            cmd.Parameters.AddWithValue("@CreatedBy", createdBy);

            con.Open();
            cmd.ExecuteNonQuery();
        }

        return "Success";
    }

    [WebMethod]
    public static string GetFollowUpHistory(int leadId)
    {
        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string role = System.Web.HttpContext.Current.Session["Role"].ToString();
            string id = System.Web.HttpContext.Current.Session["ID"].ToString();

            SqlCommand cmd = new SqlCommand(@"
            SELECT
                CONVERT(varchar(20), CreatedDate, 105) AS FollowDate,
                Feedback,
                Status,
                CONVERT(varchar(20), ReminderDate, 105) AS NextReminder,
                 UM.FullName AS UserName
            FROM tbl_MetaLeadFollowUp MF
            LEFT JOIN tbl_UserMaster UM
            ON UM.ID = MF.CreatedBy
            WHERE LeadId = @LeadId
           -- AND (@Role <> 'Dealer' OR MF.CreatedBy = @ID)
            ORDER BY CreatedDate DESC", con);

            cmd.Parameters.AddWithValue("@LeadId", leadId);
            cmd.Parameters.AddWithValue("@Role", role);
            cmd.Parameters.AddWithValue("@ID", id);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }

        List<object> list = new List<object>();

        foreach (DataRow dr in dt.Rows)
        {
            list.Add(new
            {
                FollowDate = dr["FollowDate"].ToString(),
                Feedback = dr["Feedback"].ToString(),
                Status = dr["Status"].ToString(),
                NextReminder = dr["NextReminder"].ToString(),
                UserName = dr["UserName"].ToString()
            });
        }

        JavaScriptSerializer js = new JavaScriptSerializer();
        return js.Serialize(list);
    }
}