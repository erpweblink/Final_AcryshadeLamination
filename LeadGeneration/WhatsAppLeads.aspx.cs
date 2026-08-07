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

public partial class WhatsAppLeads : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'WhatsAppLeads.aspx'";
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
                GetWhatsAppLeads();
            }
        }
    }

    private void GetWhatsAppLeads()
    {
        try
        {
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            string apiUrl = "https://www.weblinkservices.net/career/inquiry/whatsapp_api.php?api_key=c9a81b1f2a8db1917b562a193c3576eca423c9eae1b51b667138b2816ae006e6";

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
                        using (SqlCommand cmd = new SqlCommand("SP_InsertWhatsappLead", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;

                            int apiId = 0;
                            if (item["id"] != null) int.TryParse(item["id"].ToString(), out apiId);

                            cmd.Parameters.AddWithValue("@Action", "Insertwhleads");
                            cmd.Parameters.AddWithValue("@ApiId", apiId);

                            cmd.Parameters.AddWithValue("@CompanyDomain",
                                item["company_domain"] != null ? item["company_domain"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@CompanyName",
                                item["company_name"] != null ? item["company_name"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@Name",
                                item["name"] != null ? item["name"].ToString() : (object)DBNull.Value);

                            cmd.Parameters.AddWithValue("@MobileNumber",
                                item["mobile_number"] != null ? item["mobile_number"].ToString() : (object)DBNull.Value);

                            DateTime createdAt;
                            if (DateTime.TryParse(Convert.ToString(item["created_at"]), out createdAt))
                                cmd.Parameters.AddWithValue("@CreatedAt", createdAt);
                            else
                                cmd.Parameters.AddWithValue("@CreatedAt", DBNull.Value);

                            cmd.Parameters.AddWithValue("@Service",
                                item["Service"] != null ? item["Service"].ToString() : (object)DBNull.Value);

                            int companyId;
                            if (item["CompanyId"] != null && int.TryParse(item["CompanyId"].ToString(), out companyId))
                                cmd.Parameters.AddWithValue("@CompanyId", companyId);
                            else
                                cmd.Parameters.AddWithValue("@CompanyId", DBNull.Value);

                            cmd.Parameters.AddWithValue("@CustomerURL",
                                item["CustomerURL"] != null ? item["CustomerURL"].ToString() : (object)DBNull.Value);

                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
        }
        catch (WebException ex)
        {
            System.Diagnostics.Debug.WriteLine("WhatsApp API Error: " + ex.Message);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("WhatsApp API Error: " + ex.Message);
        }
    }

    [WebMethod]
    public static string SearchLeads(string searchTerm, int pageSize, string statusFilter, string assignedFilter, string dealerFilter, string fromDate, string toDate, string salesPersonFilter)
    {
        string conString = ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString;

        string role = System.Web.HttpContext.Current.Session["Role"] != null
               ? System.Web.HttpContext.Current.Session["Role"].ToString() : "";
        string userId = System.Web.HttpContext.Current.Session["ID"] != null
            ? System.Web.HttpContext.Current.Session["ID"].ToString() : "";

        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(conString))
        {
            using (SqlCommand cmd = new SqlCommand("SP_InsertWhatsappLead", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Action", "WhatsAppList");
                cmd.Parameters.AddWithValue("@Search", searchTerm ?? "");
                cmd.Parameters.AddWithValue("@ShowRecords", pageSize);
                cmd.Parameters.AddWithValue("@Status", statusFilter ?? "");
                cmd.Parameters.AddWithValue("@AssignedFilter", assignedFilter ?? "");
                cmd.Parameters.AddWithValue("@FromDate", string.IsNullOrEmpty(fromDate) ? (object)DBNull.Value : fromDate);
                cmd.Parameters.AddWithValue("@ToDate", string.IsNullOrEmpty(toDate) ? (object)DBNull.Value : toDate);
                cmd.Parameters.AddWithValue("@Role", role);
                cmd.Parameters.AddWithValue("@Id", string.IsNullOrEmpty(userId) ? (object)DBNull.Value : userId);
                cmd.Parameters.AddWithValue("@DealerIds", string.IsNullOrEmpty(dealerFilter) ? (object)DBNull.Value : dealerFilter);
                cmd.Parameters.AddWithValue("@SalesPersonId", string.IsNullOrEmpty(salesPersonFilter) ? (object)DBNull.Value : salesPersonFilter);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }

        List<Dictionary<string, object>> results = new List<Dictionary<string, object>>();

        foreach (DataRow row in dt.Rows)
        {
            Dictionary<string, object> item = new Dictionary<string, object>();
            item["LeadID"] = row["LeadID"].ToString();
            item["Name"] = row["Name"] == DBNull.Value ? "" : row["Name"].ToString();
            item["MobileNumber"] = row["MobileNumber"] == DBNull.Value ? "" : row["MobileNumber"].ToString();
            item["Service"] = row["Service"] == DBNull.Value ? "" : row["Service"].ToString();
            item["CreatedAt"] = row["CreatedDate"].ToString();
            item["CustomerURL"] = row["CustomerURL"] == DBNull.Value ? "" : row["CustomerURL"].ToString();
            item["Status"] = row["Status"] == DBNull.Value ? "" : row["Status"].ToString();
            item["AssignTo"] = row["AssignedTo"] == DBNull.Value ? "" : row["AssignedTo"].ToString();
            item["SalesPerson"] = row["SalesPerson"] == DBNull.Value ? "" : row["SalesPerson"].ToString();

            results.Add(item);
        }

        return JsonConvert.SerializeObject(results);
    }

    [WebMethod]
    public static string GetDealers()
    {
        string conString = ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString;
        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(conString))
        {
            using (SqlCommand cmd = new SqlCommand("SP_InsertWhatsappLead", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Action", "GetDealer");

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }

        // SP's 'GetDealer' action returns: ID, Dealer (FullName aliased as Dealer)
        List<Dictionary<string, string>> dealers = new List<Dictionary<string, string>>();
        foreach (DataRow row in dt.Rows)
        {
            dealers.Add(new Dictionary<string, string> {
                { "ID", row["ID"].ToString() },
                { "DealerName", row["Dealer"].ToString() }
            });
        }

        return JsonConvert.SerializeObject(dealers);
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
    public static string UpdateLeadStatus(int id, string status)
    {
        try
        {
            string conString = ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_InsertWhatsappLead", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "Updatedstatus");
                    cmd.Parameters.AddWithValue("@Id", id);
                    cmd.Parameters.AddWithValue("@Status", status);

                    con.Open();
                    cmd.ExecuteNonQuery();
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
            string conString = ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString;

            string role = System.Web.HttpContext.Current.Session["Role"] != null
                 ? System.Web.HttpContext.Current.Session["Role"].ToString() : "";
            if (role == "Dealer")
            {
                return "Access Denied";
            }

            using (SqlConnection con = new SqlConnection(conString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_InsertWhatsappLead", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "AssignDealer");
                    cmd.Parameters.AddWithValue("@Id", leadId);
                    cmd.Parameters.AddWithValue("@DealerId", string.IsNullOrWhiteSpace(dealerId) ? (object)DBNull.Value : dealerId.Trim());

                    if (string.IsNullOrEmpty(reminder))
                        cmd.Parameters.AddWithValue("@AdminReminderDate", DBNull.Value);
                    else
                        cmd.Parameters.AddWithValue("@AdminReminderDate", Convert.ToDateTime(reminder));

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            return string.IsNullOrWhiteSpace(dealerId) ? "Dealer Removed" : "Assigned";
        }
        catch (Exception ex)
        {
            return "Error : " + ex.Message;
        }
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

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString))
        {
            con.Open();

            foreach (string rawId in ids)
            {
                string leadId = rawId.Trim();
                if (leadId.Length == 0) continue;

                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE Tbl_Whatsuplead SET SalesPerson = @SalesPersonId, SalesPersonAssDate = GETDATE() WHERE Id = @ID", con))
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
                    "UPDATE Tbl_Whatsuplead SET IsDeleted = 1, DeletedBy = @ActionBy, DeletedOn= GETDATE() WHERE ID = @ID", con))
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
        try
        {
            string conString = ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_InsertWhatsappLead", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "savefeedwh");
                    cmd.Parameters.AddWithValue("@Id", leadId);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@Feedback", feedback);
                    cmd.Parameters.AddWithValue("@Name", System.Web.HttpContext.Current.Session["ID"].ToString());

                    if (string.IsNullOrEmpty(followDate))
                        cmd.Parameters.AddWithValue("@FollowUpDate", DBNull.Value);
                    else
                        cmd.Parameters.AddWithValue("@FollowUpDate", Convert.ToDateTime(followDate));

                    con.Open();
                    cmd.ExecuteNonQuery();
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
    public static string GetFollowUpHistory(int leadId)
    {
        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString))
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT
                CONVERT(varchar(20), h.CreatedAt, 105) AS FollowDate,
                h.Feedback,
                h.Status,
                CONVERT(varchar(20), h.FollowupDate, 105) AS NextReminder,
                UM.FullName AS UserName
            FROM Tbl_Whatsuplead_FeedbackHistory h
            LEFT JOIN tbl_UserMaster UM
            ON UM.ID = h.UserName
            WHERE h.WhatsupLeadId = @LeadId
            ORDER BY h.CreatedAt DESC", con);

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