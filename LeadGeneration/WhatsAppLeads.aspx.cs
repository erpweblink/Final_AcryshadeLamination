using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web.Services;

public partial class WhatsAppLeads : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            GetWhatsAppLeads();
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
    public static string SearchLeads(string searchTerm, int pageSize, string statusFilter)
    {
        string conString = ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString;
        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(conString))
        {
            using (SqlCommand cmd = new SqlCommand("SP_InsertWhatsappLead", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Action", "Getwhatsappleads");

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }

        DataView dv = dt.DefaultView;

        List<string> filters = new List<string>();

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            string term = searchTerm.Replace("'", "''");
            filters.Add(string.Format(
                "(Convert(Name, System.String) LIKE '%{0}%' OR Convert(MobileNumber, System.String) LIKE '%{0}%' OR Convert(Service, System.String) LIKE '%{0}%')",
                term));
        }

        if (!string.IsNullOrWhiteSpace(statusFilter))
        {
            filters.Add(string.Format("Status = '{0}'", statusFilter.Replace("'", "''")));
        }

        if (filters.Count > 0)
        {
            dv.RowFilter = string.Join(" AND ", filters);
        }

        dv.Sort = "CreatedAt DESC";

        List<Dictionary<string, object>> results = new List<Dictionary<string, object>>();

        int count = 0;
        foreach (DataRowView row in dv)
        {
            if (pageSize > 0 && count >= pageSize) break;

            Dictionary<string, object> item = new Dictionary<string, object>();
            item["LeadID"] = row["LeadID"].ToString();
            item["Name"] = row["Name"] == DBNull.Value ? "" : row["Name"].ToString();
            item["MobileNumber"] = row["MobileNumber"] == DBNull.Value ? "" : row["MobileNumber"].ToString();
            item["Service"] = row["Service"] == DBNull.Value ? "" : row["Service"].ToString();
            item["CreatedAt"] = row["CreatedAt"] == DBNull.Value ? "" : Convert.ToDateTime(row["CreatedAt"]).ToString("dd-MMM-yyyy");
            item["CustomerURL"] = row["CustomerURL"] == DBNull.Value ? "" : row["CustomerURL"].ToString();
            item["Status"] = row["Status"] == DBNull.Value ? "" : row["Status"].ToString();
            item["AssignTo"] = row["AssignTo"] == DBNull.Value ? "" : row["AssignTo"].ToString();
            // FeedbackHistory arrives pre-built as HTML (<div>...</div><hr/> per entry)
            // straight out of the SP's STRING_AGG, so it's passed through as-is.
            item["FeedbackHistory"] = row["FeedbackHistory"] == DBNull.Value ? "" : row["FeedbackHistory"].ToString();

            results.Add(item);
            count++;
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

        // SP's 'GetDealer' action returns: ID, UserCode, Dealer (FullName aliased as Dealer)
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
    public static string AssignDealerToLead(string leadId, string dealerId)
    {
        try
        {
            string conString = ConfigurationManager.ConnectionStrings["ConStr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_InsertWhatsappLead", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "AssignDealer");
                    cmd.Parameters.AddWithValue("@Id", leadId);
                    cmd.Parameters.AddWithValue("@DealerId", dealerId);

                    con.Open();
                    cmd.ExecuteNonQuery();
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
}