using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Services;

public partial class EnquiryList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //Check if you has access to the page of not
            //{
            //    string username = Session["ID"].ToString();
            //    using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            //    {
            //        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'EnquiryList.aspx'";
            //        SqlCommand cmds = new SqlCommand(query, cons);
            //        cmds.Parameters.AddWithValue("@UserID", username);
            //        cons.Open();
            //        object result = cmds.ExecuteScalar();
            //        if (result == null || result.ToString() != "True")
            //        {
            //            Response.Redirect("/AccessDenied.aspx");
            //        }
            //    }
            //}

            GetEnqAppLeads();
        }
    }

    private void GetEnqAppLeads()
    {
        try
        {
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            string apiUrl = "https://www.weblinkservices.net/career/inquiry/enquiry_api.php?api_key=c9a81b1f2a8db1917b562a193c3576eca423c9eae1b51b667138b2816ae006e6";

            using (WebClient client = new WebClient())
            {
                client.Encoding = Encoding.UTF8;
                client.Headers.Add("User-Agent", "Mozilla/5.0");

                string json = client.DownloadString(apiUrl);
                JArray arr = JArray.Parse(json);

                string conString = ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString;

                using (SqlConnection con = new SqlConnection(conString))
                {
                    con.Open();

                    foreach (JObject item in arr)
                    {
                        using (SqlCommand cmd = new SqlCommand("SP_MetaLead", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;

                            int apiId = 0;
                            if (item["id"] != null) int.TryParse(item["id"].ToString(), out apiId);

                            cmd.Parameters.AddWithValue("@SP_Action", "InsertNewEnquiry");
                            cmd.Parameters.AddWithValue("@ApiId", apiId);

                            cmd.Parameters.AddWithValue("@CompanyDomain",
                                item["company_domain"] != null ? item["company_domain"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@CompanyName",
                                item["company_name"] != null ? item["company_name"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@Name",
                                item["name"] != null ? item["name"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@CName",
                                item["cname"] != null ? item["cname"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@MobileNumber",
                                item["mobile_no"] != null ? item["mobile_no"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@EmailID",
                                item["email_id"] != null ? item["email_id"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@CProduct",
                                item["cproduct"] != null ? item["cproduct"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@message",
                                item["message"] != null ? item["message"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@city",
                                item["city"] != null ? item["city"].ToString() : (object)DBNull.Value);

                            DateTime createdAt;
                            if (DateTime.TryParse(Convert.ToString(item["enquiry_date"]), out createdAt))
                                cmd.Parameters.AddWithValue("@EnquiryDate", createdAt);
                            else
                                cmd.Parameters.AddWithValue("@EnquiryDate", DBNull.Value);

                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
        }
        catch (WebException ex)
        {
            System.Diagnostics.Debug.WriteLine("Enquiry API Error: " + ex.Message);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Enquiry API Error: " + ex.Message);
        }
    }

    [WebMethod]
    public static string SearchLeads(string searchTerm, int pageSize, string statusFilter, string assignedFilter, string dealerFilter)
    {
        string conString = ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString;
        DataTable dt = new DataTable();

        string role = System.Web.HttpContext.Current.Session["Role"] != null
               ? System.Web.HttpContext.Current.Session["Role"].ToString() : "";
        string userId = System.Web.HttpContext.Current.Session["ID"] != null
            ? System.Web.HttpContext.Current.Session["ID"].ToString() : "";

        using (SqlConnection con = new SqlConnection(conString))
        {

            using (SqlCommand cmd = new SqlCommand("SP_MetaLead", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SP_Action", "GetEnquiryList");

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }

        DataView dv = dt.DefaultView;

        List<string> filters = new List<string>();

        if (role == "Dealer")
        {
            filters.Add(string.Format("Convert(AssignTo, System.String) = '{0}'", userId.Replace("'", "''")));
        }

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            string term = searchTerm.Replace("'", "''");
            filters.Add(string.Format(
                "(Convert(Name, System.String) LIKE '%{0}%' OR Convert(MobileNumber, System.String) LIKE '%{0}%' OR Convert(message, System.String) LIKE '%{0}%')",
                term));
        }

        if (!string.IsNullOrWhiteSpace(statusFilter))
        {
            filters.Add(string.Format("Status = '{0}'", statusFilter.Replace("'", "''")));
        }

        if (role != "Dealer")
        {
            if (!string.IsNullOrWhiteSpace(assignedFilter))
            {
                if (assignedFilter == "Assigned")
                    filters.Add("(AssignTo IS NOT NULL AND AssignTo <> '')");
                else if (assignedFilter == "Not Assigned")
                    filters.Add("(AssignTo IS NULL OR AssignTo = '')");
            }

            if (!string.IsNullOrWhiteSpace(dealerFilter))
            {
                var ids = dealerFilter.Split(',')
                    .Select(x => x.Trim().Replace("'", "''"))
                    .Where(x => x.Length > 0)
                    .Select(x => "'" + x + "'");

                filters.Add(string.Format("Convert(AssignTo, System.String) IN ({0})", string.Join(",", ids)));
            }
        }

        if (filters.Count > 0)
        {
            dv.RowFilter = string.Join(" AND ", filters);
        }


        dv.Sort = "EnquiryDate DESC";

        List<Dictionary<string, object>> results = new List<Dictionary<string, object>>();

        int count = 0;
        foreach (DataRowView row in dv)
        {
            if (pageSize > 0 && count >= pageSize) break;

            Dictionary<string, object> item = new Dictionary<string, object>();
            item["LeadID"] = row["LeadID"].ToString();
            item["Name"] = row["Name"] == DBNull.Value ? "" : row["Name"].ToString();
            item["MobileNumber"] = row["MobileNumber"] == DBNull.Value ? "" : row["MobileNumber"].ToString();
            item["Service"] = row["message"] == DBNull.Value ? "" : row["message"].ToString();
            item["CreatedAt"] = row["EnquiryDate"] == DBNull.Value ? "" : Convert.ToDateTime(row["EnquiryDate"]).ToString("dd-MMM-yyyy");
            item["CustomerURL"] = "" ;
            item["Status"] = row["Status"] == DBNull.Value ? "" : row["Status"].ToString();
            item["AssignTo"] = row["AssignTo"] == DBNull.Value ? "" : row["AssignTo"].ToString();
            item["FeedbackHistory"] = row["FeedbackHistory"] == DBNull.Value ? "" : row["FeedbackHistory"].ToString();

            results.Add(item);
            count++;
        }

        return JsonConvert.SerializeObject(results);
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
    public static string UpdateLeadStatus(int id, string status)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tbl_WebsiteEnquiry SET Status = @Status WHERE ID = @ID", con))
                {
                    cmd.Parameters.AddWithValue("@Status", string.IsNullOrWhiteSpace(status) ? DBNull.Value : (Object)status);
                    cmd.Parameters.AddWithValue("@ID", id);

                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                }
            }

            return "Success";
        }
        catch (Exception ex)
        {
            return "Error : " + ex.Message;
        }
    }

    [WebMethod]
    public static string AssignDealerToLead(string leadId, string dealerId, string reminder)
    {
        try
        {
            string role = HttpContext.Current.Session["Role"] != null ? HttpContext.Current.Session["Role"].ToString() : "";
            if (role == "Dealer")
            {
                return "Access Denied";
            }

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tbl_WebsiteEnquiry SET AssignTo = @DealerID,AssignDate = GETDATE(),AdminReminderDate = @reminder WHERE ID = @ID", con))
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
        catch (Exception ex)
        {
            return "Error : " + ex.Message;
        }
    }

    [WebMethod]
    public static string SaveFeedback(int leadId, string status, string feedback, string followDate)
    {
        try
        {
            string createdBy = HttpContext.Current.Session["ID"].ToString();

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand(@"
                INSERT INTO tbl_WebsiteEnquiryFollowUps
                (
                    WebsiteEnqId,
                    Feedback,
                    Status,
                    FollowUpDate,
                    UserName,
                    CreatedOn
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

                if (string.IsNullOrEmpty(followDate))
                    cmd.Parameters.AddWithValue("@ReminderDate", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@ReminderDate", Convert.ToDateTime(followDate));

                cmd.Parameters.AddWithValue("@CreatedBy", createdBy);

                con.Open();
                cmd.ExecuteNonQuery();
            }

            return "Success";
        }
        catch (Exception ex)
        {
            return "Error : " + ex.Message;
        }
    }
}