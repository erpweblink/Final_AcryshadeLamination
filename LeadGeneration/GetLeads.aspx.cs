using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Net;
using System.Text;
using System.Web.Services;


public partial class GetLeads : System.Web.UI.Page
{    
    protected void Page_Load(object sender, EventArgs e)
    {
       
    }


    [WebMethod]
    public static string GenerateLongToken()
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            DataTable dt = new DataTable();
            SqlDataAdapter cmd = new SqlDataAdapter("SELECT * FROM tbl_MetaAuthTokens", con);
            cmd.Fill(dt);
            string longLivedUserToken = "", facebookPageId = "";

            if (dt.Rows.Count == 0)
                return "No auth token record found.";

            DateTime ExpiresDate = Convert.ToDateTime(dt.Rows[0]["ExpiresIn"]);
            facebookPageId = dt.Rows[0]["PageID"].ToString();
            string Longtoken = dt.Rows[0]["Longtoken"].ToString();

            if (ExpiresDate <= DateTime.Now.AddDays(2))
            {
                longLivedUserToken = GetPageAccessToken(Longtoken, facebookPageId);
                SaveTokens(con, longLivedUserToken);
            }
            else
            {
                longLivedUserToken = Longtoken;
            }

            if (string.IsNullOrEmpty(longLivedUserToken))
                return "Failed to obtain access token.";

            List<JObject> leadForms = FetchPageLeadId(facebookPageId, longLivedUserToken);
            int totalLeadsProcessed = 0;

            foreach (var form in leadForms)
            {
                string formId = form["id"] != null ? form["id"].ToString() : null;
                if (string.IsNullOrEmpty(formId))
                    continue;

                DataTable dts = new DataTable();
                using (var selectCmd = new SqlCommand(
                    "SELECT * FROM tbl_AdsQuestionsFormID WHERE FormID = @FormID AND ISNULL(IsDeleted,0) = 0", con))
                {
                    selectCmd.Parameters.AddWithValue("@FormID", formId);
                    SqlDataAdapter adapter = new SqlDataAdapter(selectCmd);
                    adapter.Fill(dts);
                }

                if (dts.Rows.Count == 0)
                    continue;

                string storedFormId = dts.Rows[0]["FormID"].ToString();
                string personalDetailsJson = dts.Rows[0]["PersonalDetails"].ToString();
                string otherDetailsJson = dts.Rows[0]["OtherDetails"].ToString();

                List<string> storedPersonalFields = ParseJsonList(personalDetailsJson);
                List<string> storedOtherQuestions = ParseJsonList(otherDetailsJson);

                List<JObject> leads = FetchLeadsFromPageLeadID(storedFormId, longLivedUserToken);

                foreach (var lead in leads)
                {
                    string leadId = lead["id"] != null ? lead["id"].ToString() : null;
                    string createdTimeStr = lead["created_time"] != null ? lead["created_time"].ToString() : null;

                    if (string.IsNullOrEmpty(leadId))
                        continue;

                    DateTime? createdTime = null;
                    DateTime parsedDate;
                    if (DateTime.TryParse(createdTimeStr, out parsedDate))
                        createdTime = parsedDate;

                    var fieldDataArray = lead["field_data"] as JArray;
                    Dictionary<string, string> fieldValues = new Dictionary<string, string>();

                    if (fieldDataArray != null)
                    {
                        foreach (var field in fieldDataArray)
                        {
                            string fieldName = field["name"] != null ? field["name"].ToString() : null;
                            var valuesArray = field["values"] as JArray;

                            string fieldValue = null;
                            if (valuesArray != null && valuesArray.Count > 0)
                                fieldValue = valuesArray[0].ToString();

                            if (!string.IsNullOrEmpty(fieldName))
                                fieldValues[fieldName] = fieldValue;
                        }
                    }

                    Dictionary<string, string> personalInfo = new Dictionary<string, string>();
                    Dictionary<string, string> formQuestionAnswers = new Dictionary<string, string>();

                    // Store Personal Details in the same order as tbl_AdsQuestionsFormID
                    foreach (string personalField in storedPersonalFields)
                    {
                        string value = "";

                        foreach (var kvp in fieldValues)
                        {
                            if (Normalize(kvp.Key) == Normalize(personalField))
                            {
                                value = kvp.Value;
                                break;
                            }
                        }

                        personalInfo.Add(personalField, value);
                    }

                    // Store Questions in the same order as tbl_AdsQuestionsFormID
                    foreach (string question in storedOtherQuestions)
                    {
                        string value = "";

                        foreach (var kvp in fieldValues)
                        {
                            if (Normalize(kvp.Key) == Normalize(question))
                            {
                                value = FormatAnswer(string.IsNullOrWhiteSpace(kvp.Value)?"N/A": kvp.Value);
                                break;
                            }
                        }

                        formQuestionAnswers.Add(question, value);
                    }

                    string personalInfoJson = JsonConvert.SerializeObject(personalInfo);
                    string formQuestionJson = JsonConvert.SerializeObject(formQuestionAnswers);

                    InsertLeadLog(con, storedFormId, leadId, createdTime, personalInfoJson, formQuestionJson);

                    if (!LeadExists(con, leadId))
                    {
                        InsertLead(con, storedFormId, leadId, createdTime, personalInfoJson, formQuestionJson);
                    }

                    totalLeadsProcessed++;
                }
            }

            return "Processed " + totalLeadsProcessed + " lead(s) successfully.";
        }
    }

    //To remove unicode eg.- Åh̊m̊e̊d̊åb̊åd̊ like this 
    public static string RemoveDiacritics(string text)
    {
        var normalized = text.Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder();

        foreach (char c in normalized)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
            {
                sb.Append(c);
            }
        }

        return sb.ToString().Normalize(NormalizationForm.FormC);
    }

    private static List<string> ParseJsonList(string json)
    {
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

    private static string Normalize(string s)
    {
        if (string.IsNullOrEmpty(s))
            return "";
        return System.Text.RegularExpressions.Regex.Replace(s.ToLower(), "[^a-z0-9]", "");
    }

    private static string FormatAnswer(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return value;

        value = value.Replace("_/_", " / ");
        value = value.Replace("_", " ");

        return System.Globalization.CultureInfo.CurrentCulture.TextInfo.ToTitleCase(value.ToLower());
    }

    private static bool LeadExists(SqlConnection con, string leadId)
    {
        using (var checkCmd = new SqlCommand(
            "SELECT COUNT(1) FROM tbl_MetaLeads WHERE LeadID = @LeadID", con))
        {
            checkCmd.Parameters.AddWithValue("@LeadID", leadId);

            if (con.State != ConnectionState.Open) con.Open();
            int count = (int)checkCmd.ExecuteScalar();
            con.Close();

            return count > 0;
        }
    }

    private static void InsertLead(SqlConnection con, string formId, string leadId, DateTime? createdDate, string personalInfoJson, string formQuestionJson)
    {
        using (var insertCmd = new SqlCommand(
            "INSERT INTO tbl_MetaLeads (FormID, LeadID, CreatedDate, PersonalInfo, FormQuestion, InsertedDate) " +
            "VALUES (@FormID, @LeadID, @CreatedDate, @PersonalInfo, @FormQuestion, @InsertedDate )", con))
        {
            insertCmd.Parameters.AddWithValue("@FormID", formId);
            insertCmd.Parameters.AddWithValue("@LeadID", leadId);
            insertCmd.Parameters.AddWithValue("@CreatedDate", (object)createdDate ?? DBNull.Value);
            insertCmd.Parameters.AddWithValue("@PersonalInfo", personalInfoJson);
            insertCmd.Parameters.AddWithValue("@FormQuestion", formQuestionJson);
            insertCmd.Parameters.AddWithValue("@InsertedDate", DateTime.Now);

            if (con.State != ConnectionState.Open) con.Open();
            insertCmd.ExecuteNonQuery();
            con.Close();
        }
    }

    private static void InsertLeadLog(SqlConnection con, string formId, string leadId, DateTime? createdDate, string personalInfoJson, string formQuestionJson)
    {
        using (var insertCmd = new SqlCommand(
            "INSERT INTO tbl_MetaLeadsLog (FormID, LeadID, CreatedDate, PersonalInfo, FormQuestion, InsertedDate) " +
            "VALUES (@FormID, @LeadID, @CreatedDate, @PersonalInfo, @FormQuestion, @InsertedDate)", con))
        {
            insertCmd.Parameters.AddWithValue("@FormID", formId);
            insertCmd.Parameters.AddWithValue("@LeadID", leadId);
            insertCmd.Parameters.AddWithValue("@CreatedDate", (object)createdDate ?? DBNull.Value);
            insertCmd.Parameters.AddWithValue("@PersonalInfo", personalInfoJson);
            insertCmd.Parameters.AddWithValue("@FormQuestion", formQuestionJson);
            insertCmd.Parameters.AddWithValue("@InsertedDate", DateTime.Now);

            if (con.State != ConnectionState.Open) con.Open();
            insertCmd.ExecuteNonQuery();
            con.Close();
        }
    }

    private static string MakeGetRequest(string url)
    {
        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
        ServicePointManager.Expect100Continue = false;
        ServicePointManager.DefaultConnectionLimit = 100;

        try
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "GET";
            request.Timeout = 30000;
            request.ReadWriteTimeout = 30000;
            request.KeepAlive = false;

            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            {
                System.Diagnostics.Debug.WriteLine("After GetResponse");

                using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                {
                    string content = reader.ReadToEnd();
                    System.Diagnostics.Debug.WriteLine(content);

                    return content;
                }
            }
        }
        catch (WebException ex)
        {
            if (ex.Response != null)
            {
                using (StreamReader reader = new StreamReader(ex.Response.GetResponseStream()))
                {
                    string error = reader.ReadToEnd();
                    throw new Exception(error);
                }
            }

            throw;
        }
    }

    private static string GetPageAccessToken(string longLivedUserToken, string pageId)
    {
        var url = "https://graph.facebook.com/v18.0/" + pageId
                  + "?fields=access_token"
                  + "&access_token=" + Uri.EscapeDataString(longLivedUserToken);

        string content = MakeGetRequest(url);
        var json = JObject.Parse(content);
        var tokenValue = json["access_token"];
        return tokenValue == null ? null : tokenValue.ToString();
    }

    private static void SaveTokens(SqlConnection con, string longLivedUserToken)
    {
        using (var updateCmd = new SqlCommand(
            "UPDATE tbl_MetaAuthTokens SET Longtoken = @LongToken, ExpiresIn = @ExpiresIn", con))
        {
            updateCmd.Parameters.AddWithValue("@LongToken", longLivedUserToken);
            updateCmd.Parameters.AddWithValue("@ExpiresIn", DateTime.Now.AddDays(61));

            if (con.State != ConnectionState.Open) con.Open();
            updateCmd.ExecuteNonQuery();
            con.Close();
        }
    }

    private static List<JObject> FetchPageLeadId(string pageId, string accessToken)
    {
        var sw = System.Diagnostics.Stopwatch.StartNew();

        var url = "https://graph.facebook.com/v17.0/" + pageId + "/leadgen_forms?access_token=" + accessToken;
        string content = MakeGetRequest(url);

        sw.Stop();
        System.Diagnostics.Debug.WriteLine("FetchPageLeadId took: " + sw.ElapsedMilliseconds + "ms");

        var json = JObject.Parse(content);

        var forms = new List<JObject>();
        var dataArray = json["data"] as JArray;

        if (dataArray != null)
        {
            foreach (var item in dataArray)
                forms.Add((JObject)item);
        }

        return forms;
    }

    private static List<JObject> FetchLeadsFromPageLeadID(string formId, string accessToken)
    {
        var url = "https://graph.facebook.com/v17.0/" + formId + "/leads?access_token=" + accessToken;
        string content = MakeGetRequest(url);
        var json = JObject.Parse(content);

        var leads = new List<JObject>();
        var dataArray = json["data"] as JArray;

        if (dataArray != null)
        {
            foreach (var item in dataArray)
                leads.Add((JObject)item);
        }

        return leads;
    }

}


