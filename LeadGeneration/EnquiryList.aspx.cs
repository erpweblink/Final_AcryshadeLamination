using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Services;

public partial class EnquiryList : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'EnquiryList.aspx'";
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

                GetEnqAppLeads();
            }
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
    public static string SearchLeads(string searchTerm, int pageSize, string statusFilter, string assignedFilter, string dealerFilter, string fromDate, string toDate, string salesPersonFilter)
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string role = System.Web.HttpContext.Current.Session["Role"] != null
                ? System.Web.HttpContext.Current.Session["Role"].ToString() : "";
            string id = System.Web.HttpContext.Current.Session["ID"] != null
                ? System.Web.HttpContext.Current.Session["ID"].ToString() : "";

            SqlDataAdapter da = new SqlDataAdapter("SP_MetaLead", con);
            da.SelectCommand.CommandType = CommandType.StoredProcedure;
            da.SelectCommand.Parameters.AddWithValue("@SP_Action", "EnquiryLists");
            da.SelectCommand.Parameters.AddWithValue("@Search", searchTerm ?? "");
            da.SelectCommand.Parameters.AddWithValue("@ShowRecords", pageSize);
            da.SelectCommand.Parameters.AddWithValue("@Status", statusFilter ?? "");
            da.SelectCommand.Parameters.AddWithValue("@AssignedFilter", assignedFilter ?? "");
            da.SelectCommand.Parameters.AddWithValue("@FromDate", string.IsNullOrEmpty(fromDate) ? (object)DBNull.Value : fromDate);
            da.SelectCommand.Parameters.AddWithValue("@ToDate", string.IsNullOrEmpty(toDate) ? (object)DBNull.Value : toDate);
            da.SelectCommand.Parameters.AddWithValue("@Role", role);
            da.SelectCommand.Parameters.AddWithValue("@Id", id);
            da.SelectCommand.Parameters.AddWithValue("@DealerIds", string.IsNullOrEmpty(dealerFilter) ? (object)DBNull.Value : dealerFilter);
            da.SelectCommand.Parameters.AddWithValue("@SalesPersonId", string.IsNullOrEmpty(salesPersonFilter) ? (object)DBNull.Value : salesPersonFilter);

            DataTable dt = new DataTable();
            da.Fill(dt);

            List<Dictionary<string, object>> results = new List<Dictionary<string, object>>();

            foreach (DataRow row in dt.Rows)
            {
                Dictionary<string, object> item = new Dictionary<string, object>();
                item["LeadID"] = row["LeadID"].ToString();
                item["Name"] = row["Name"] == DBNull.Value ? "" : row["Name"].ToString();
                item["MobileNumber"] = row["MobileNumber"] == DBNull.Value ? "" : row["MobileNumber"].ToString();
                item["Service"] = row["message"] == DBNull.Value ? "" : row["message"].ToString();
                item["CreatedAt"] = row["CreatedDate"].ToString();
                item["CustomerURL"] = row["CompanyDomain"] == DBNull.Value ? "" : row["CompanyDomain"].ToString();
                item["Status"] = row["Status"] == DBNull.Value ? "" : row["Status"].ToString();
                item["AssignTo"] = row["AssignedTo"] == DBNull.Value ? "" : row["AssignedTo"].ToString();
                item["SalesPerson"] = row["SalesPerson"] == DBNull.Value ? "" : row["SalesPerson"].ToString();

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
    public static string GetDealerDetails(string dealerId)
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT ID, FullName AS DealerName,CompanyName AS CompanyName, MobileNo, EmailId AS Email,
                 BillAddress AS Address,ISNULL(BillCity,'INDIA') AS City FROM tbl_UserMaster 
              WHERE ID = @ID AND ISNULL(IsDeleted,0) = 0", con))
            {
                cmd.Parameters.AddWithValue("@ID", dealerId);
                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        Dictionary<string, string> dealer = new Dictionary<string, string>();
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            string colName = reader.GetName(i);
                            string val = reader[i] == DBNull.Value ? "" : reader[i].ToString();
                            dealer[colName] = val;
                        }
                        return JsonConvert.SerializeObject(dealer);
                    }
                }
            }
        }
        return "{}";
    }

    [WebMethod]
    public static string GetSalesPerson()
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ID, FullName as SalesPerson FROM tbl_UserMaster WHERE ISNULL(IsDeleted,0) = 0 AND UserRole='Sales' ORDER BY SalesPerson", con))
            {
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                List<Dictionary<string, string>> salesPerson = new List<Dictionary<string, string>>();
                foreach (DataRow row in dt.Rows)
                {
                    salesPerson.Add(new Dictionary<string, string> {
                        { "ID", row["ID"].ToString() },
                        { "SalesPerson", row["SalesPerson"].ToString() }
                    });
                }

                return JsonConvert.SerializeObject(salesPerson);
            }
        }
    }

    [WebMethod]
    public static string UpdateLeadStatus(string leadId, string status)
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE tbl_WebsiteEnquiry SET Status = @Status WHERE ID = @ID", con))
            {
                cmd.Parameters.AddWithValue("@Status", string.IsNullOrWhiteSpace(status) ? DBNull.Value : (object)status);
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
                "UPDATE tbl_WebsiteEnquiry SET AssignTo = @DealerID, AssignDate = CASE WHEN @DealerID IS NULL THEN NULL ELSE GETDATE() END, AdminReminderDate = @reminder WHERE ID = @ID", con))
            {
                cmd.Parameters.AddWithValue("@DealerID", string.IsNullOrWhiteSpace(dealerId) ? DBNull.Value : (object)dealerId);
                cmd.Parameters.AddWithValue("@ID", leadId);
                cmd.Parameters.AddWithValue("@reminder", string.IsNullOrWhiteSpace(reminder) ? DBNull.Value : (object)reminder);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();
            }
        }

        return string.IsNullOrEmpty(dealerId) ? "Dealer Removed" : "Assigned";
    }

    [WebMethod]
    public static string AssignSalesPersonToLeads(string leadIds, string salesPersonId)
    {
        string role = HttpContext.Current.Session["Role"] != null ? HttpContext.Current.Session["Role"].ToString() : "";
        if (role == "Sales" || role == "Dealer")
        {
            return "Access Denied";
        }

        if (string.IsNullOrWhiteSpace(leadIds) || string.IsNullOrWhiteSpace(salesPersonId))
        {
            return "Please select at least one lead and a Sales Person.";
        }

        string[] ids = leadIds.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        int updatedCount = 0;

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            con.Open();

            foreach (string rawId in ids)
            {
                string leadId = rawId.Trim();
                if (leadId.Length == 0) continue;

                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tbl_WebsiteEnquiry SET SalesPerson = @SalesPersonId, SalesPersonAssDate = GETDATE() WHERE ID = @ID", con))
                {
                    cmd.Parameters.AddWithValue("@SalesPersonId", salesPersonId);
                    cmd.Parameters.AddWithValue("@ID", leadId);
                    updatedCount += cmd.ExecuteNonQuery();
                }
            }
        }

        return updatedCount + " lead(s) assigned to Sales Person successfully.";
    }

    [WebMethod]
    public static string RemoveLeads(string leadIds)
    {
        string role = HttpContext.Current.Session["Role"] != null ? HttpContext.Current.Session["Role"].ToString() : "";
        string ActionBy = HttpContext.Current.Session["ID"] != null ? HttpContext.Current.Session["ID"].ToString() : "";
        if (role == "Sales" || role == "Dealer")
        {
            return "Access Denied";
        }

        if (string.IsNullOrWhiteSpace(leadIds))
        {
            return "Please select at least one lead.";
        }

        string[] ids = leadIds.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        int updatedCount = 0;

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            con.Open();

            foreach (string rawId in ids)
            {
                string leadId = rawId.Trim();
                if (leadId.Length == 0) continue;

                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tbl_WebsiteEnquiry SET IsDeleted = 1, DeletedBy = @ActionBy, DeletedOn= GETDATE() WHERE ID = @ID", con))
                {
                    cmd.Parameters.AddWithValue("@ID", leadId);
                    cmd.Parameters.AddWithValue("@ActionBy", ActionBy);
                    updatedCount += cmd.ExecuteNonQuery();
                }
            }
        }

        return updatedCount + " lead(s) deleted successfully.";
    }

    [WebMethod]
    public static string SaveFeedback(int leadId, string status, string feedback, string followDate)
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

    [WebMethod]
    public static string GetFollowUpHistory(int leadId)
    {
        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT
                CONVERT(varchar(20), h.CreatedOn, 105) AS FollowDate,
                h.Feedback,
                h.Status,
                CONVERT(varchar(20), h.FollowUpDate, 105) AS NextReminder,
                UM.FullName AS UserName
            FROM tbl_WebsiteEnquiryFollowUps h
            LEFT JOIN tbl_UserMaster UM
            ON UM.ID = h.UserName
            WHERE h.WebsiteEnqId = @LeadId
            ORDER BY h.CreatedOn DESC", con);

            cmd.Parameters.AddWithValue("@LeadId", leadId);

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

        return JsonConvert.SerializeObject(list);
    }
}