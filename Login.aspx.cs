using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net.Mail;
using System.Web;
using System.Web.Security;
using System.Web.Services;
using System.Web.UI;

public partial class Login : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);

    private const string SessionOtpKey = "FP_OTP";
    private const string SessionEmailKey = "FP_EMAIL";
    private const string SessionExpiryKey = "FP_OTP_EXPIRY";
    private const string SessionVerifiedKey = "FP_OTP_VERIFIED";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            Session["message"] = "";
            Session["icon"] = "";
            Session["time"] = "";
            Session["url"] = "";

            Session.Abandon();
            // Pre-fill login form using cookies (Remember Me)
            if (Request.Cookies["Username"] != null)
                txtUsername.Text = Request.Cookies["Username"].Value;

            if (Request.Cookies["Password"] != null)
                txtPassword.Attributes.Add("value", Request.Cookies["Password"].Value);

            if (Request.Cookies["Username"] != null && Request.Cookies["Password"] != null)
                chkremember.Checked = true;
        }
    }

    protected void btnsave_Click(object sender, EventArgs e)
    {
        try
        {
            SqlDataAdapter sad = new SqlDataAdapter("SELECT * FROM tbl_UserMaster WHERE EmailId = @EmailId AND LoginPass = @LogPass", con);
            sad.SelectCommand.Parameters.AddWithValue("@EmailId", txtUsername.Text.Trim());
            sad.SelectCommand.Parameters.AddWithValue("@LogPass", txtPassword.Text.Trim());
            DataTable dt = new DataTable();
            sad.Fill(dt);

            if (dt.Rows.Count > 0)
            {
                string Username = dt.Rows[0]["FullName"].ToString();
                string Role = dt.Rows[0]["UserRole"].ToString();
                string status = dt.Rows[0]["IsActivate"].ToString();
                if (status == "True")
                {
                    FormsAuthentication.SetAuthCookie(txtUsername.Text.Trim(), chkremember.Checked);

                    if (chkremember.Checked)
                    {
                        Response.Cookies["Username"].Value = txtUsername.Text.ToLower().Trim();
                        Response.Cookies["Password"].Value = txtPassword.Text.Trim();
                        Response.Cookies["Username"].Expires = DateTime.Now.AddDays(2);
                        Response.Cookies["Password"].Expires = DateTime.Now.AddDays(2);
                    }
                    else
                    {
                        // Remove the cookie if "Remember Me" is not checked
                        if (Request.Cookies["RememberMe"] != null)
                        {
                            Response.Cookies["Username"].Expires = DateTime.Now.AddDays(-1);
                            Response.Cookies["Password"].Expires = DateTime.Now.AddDays(-1);
                        }
                    }
                    if (!string.IsNullOrEmpty(Username))
                    {
                        Session["ID"] = dt.Rows[0]["ID"].ToString();
                        Session["Username"] = dt.Rows[0]["EmailId"].ToString();
                        Session["Role"] = dt.Rows[0]["UserRole"].ToString();
                        Session["EmailID"] = dt.Rows[0]["EmailID"].ToString();
                        Session["Mobileno"] = dt.Rows[0]["MobileNo"].ToString();
                        Session["UserCode"] = dt.Rows[0]["UserCode"].ToString();

                        string url = "Admin/Dashboard.aspx";
                        if (Session["Role"].ToString() == "Dealer")
                        {
                            url = "Admin/OrderHistory.aspx";
                        }

                        string script = string.Format(@"
                                Swal.fire({{
                                    icon: 'success',
                                    text: 'Login successfully..!!',
                                    showConfirmButton: false,
                                    timer: 2000,
                                    timerProgressBar: true
                                }}).then(function () {{
                                    window.location.href = '{0}';
                                }});", url);
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
                    }
                }
                else
                {
                    txtUsername.Text = ""; txtPassword.Text = "";
                    string script = @"
                            Swal.fire({
                                icon: 'warning',
                                text: 'Login Failed, Activate Your Account First..!!',
                                showConfirmButton: false,
                                timer: 3000,
                                timerProgressBar: true
                            }).then(function () {
                                window.location.href = '/Login.aspx';
                            });";

                    ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
                }
            }
            else
            {
                txtUsername.Text = ""; txtPassword.Text = "";

                string script = @"
                            Swal.fire({
                                icon: 'error',
                                text: 'Login Failed Incorrect UserName or Password..!!',
                                showConfirmButton: false,
                                timer: 4000,
                                timerProgressBar: true
                            }).then(function () {
                                window.location.href = '/Login.aspx';
                            });";

                ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
            }

        }
        catch (Exception)
        {
            throw;
        }
        finally
        {
            con.Close();
            con.Dispose();
        }

    }


    [WebMethod(EnableSession = false)]
    public static bool CheckEmailExists(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
            return false;

        // TODO: replace with your real lookup, e.g.:
        using (var con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        using (var cmd = new SqlCommand("SELECT COUNT(1) FROM tbl_UserMaster WHERE EmailId = @Email AND IsActivate = 1", con))
        {
            cmd.Parameters.Add("@Email", SqlDbType.VarChar, 200).Value = email.Trim();
            con.Open();
            int count = (int)cmd.ExecuteScalar();
            con.Close();
            return count > 0;
        }
    }

    [WebMethod(EnableSession = true)]
    public static string SendOtp(string email)
    {
        try
        {
            string otp = new Random().Next(100000, 999999).ToString();

            HttpContext.Current.Session[SessionOtpKey] = otp;
            HttpContext.Current.Session[SessionEmailKey] = email;
            HttpContext.Current.Session[SessionExpiryKey] = DateTime.Now.AddMinutes(5);
            HttpContext.Current.Session[SessionVerifiedKey] = false;

            SendOtpEmail(email, otp); // TODO: configure real SMTP settings below

            return "OK";
        }
        catch (Exception ex)
        {
            return "Something went wrong while sending the OTP: " + ex.Message;
        }
    }

    [WebMethod(EnableSession = true)]
    public static string VerifyOtp(string email, string otp)
    {
        try
        {
            var sessionEmail = HttpContext.Current.Session[SessionEmailKey] as string;
            var sessionOtp = HttpContext.Current.Session[SessionOtpKey] as string;
            var expiryObj = HttpContext.Current.Session[SessionExpiryKey];

            if (sessionEmail == null || sessionOtp == null || expiryObj == null || sessionEmail != email)
                return "Please request a new OTP.";

            if (DateTime.Now > (DateTime)expiryObj)
                return "This OTP has expired. Please request a new one.";

            if (sessionOtp != otp)
                return "The OTP you entered is incorrect.";

            HttpContext.Current.Session[SessionVerifiedKey] = true;
            return "OK";
        }
        catch (Exception ex)
        {
            return "Something went wrong while verifying the OTP: " + ex.Message;
        }
    }

    [WebMethod(EnableSession = true)]
    public static string ResetPassword(string email, string newPassword, string confirmPassword)
    {
        try
        {
            var sessionEmail = HttpContext.Current.Session[SessionEmailKey] as string;
            var verifiedObj = HttpContext.Current.Session[SessionVerifiedKey];

            if (sessionEmail == null || sessionEmail != email || verifiedObj == null || !(bool)verifiedObj)
                return "OTP verification is required before resetting the password.";

            if (string.IsNullOrEmpty(newPassword) || newPassword.Length < 6)
                return "Password must be at least 6 characters.";

            if (newPassword != confirmPassword)
                return "Password and Confirm Password do not match.";

            // TODO: replace with your real update, e.g. hash + save to DB:
            // UpdateUserPassword(email, HashPassword(newPassword));

            // TODO: replace with your real lookup, e.g.:
            using (var con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            using (var cmd = new SqlCommand("UPDATE tbl_UserMaster SET LoginPassword=@newPassword WHERE EmailId = @Email", con))
            {
                cmd.Parameters.Add("@newPassword", SqlDbType.VarChar, 500).Value = email.Trim();
                cmd.Parameters.Add("@Email", SqlDbType.VarChar, 200).Value = email.Trim();
                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();
            }


            // Clear the OTP session state so it can't be reused
            HttpContext.Current.Session.Remove(SessionOtpKey);
            HttpContext.Current.Session.Remove(SessionEmailKey);
            HttpContext.Current.Session.Remove(SessionExpiryKey);
            HttpContext.Current.Session.Remove(SessionVerifiedKey);

            return "OK";
        }
        catch (Exception ex)
        {
            return "Something went wrong while updating the password: " + ex.Message;
        }
    }

    private static void SendOtpEmail(string toEmail, string otp)
    {
        // TODO: move these settings to Web.config <appSettings> / <mailSettings>
        var mail = new MailMessage();
        mail.From = new MailAddress("noreply@acryshade.com", "Acryshade Laminates");
        mail.To.Add(toEmail);
        mail.Subject = "Your Password Reset OTP";
        mail.Body = "Your OTP for resetting your Acryshade Laminates account password is: " + otp +
                    "\n\nThis code expires in 5 minutes. If you did not request this, please ignore this email.";
        mail.IsBodyHtml = false;

        using (var smtp = new SmtpClient("smtp.yourprovider.com", 587))
        {
            smtp.Credentials = new System.Net.NetworkCredential("smtp-username", "smtp-password");
            smtp.EnableSsl = true;
            smtp.Send(mail);
        }
    }
}

