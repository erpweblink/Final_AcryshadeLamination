// =====================================================================
// Add the "using" statements below to the top of your existing Login.aspx.cs
// and add the three [WebMethod] static methods to your Login class.
// They must be PUBLIC STATIC because they are called via PageMethods (AJAX),
// which does not have access to instance members or the page's controls.
//
// This snippet uses Session to hold the OTP + expiry + verified flag,
// since page-method calls don't have a live control tree.
// Wire the two TODO sections to your real user table and SMTP settings.
// =====================================================================

using System;
using System.Web.Services;      // WebMethod attribute
using System.Web.Script.Services; // ScriptMethod (optional, JSON is default)
using System.Net.Mail;
using System.Web;          // for sending the OTP email
// using System.Data.SqlClient; // uncomment / adjust to match your DB layer

public partial class Login : System.Web.UI.Page
{
    // ... your existing Page_Load / btnsave_Click stay exactly as they are ...

    private const string SessionOtpKey = "FP_OTP";
    private const string SessionEmailKey = "FP_EMAIL";
    private const string SessionExpiryKey = "FP_OTP_EXPIRY";
    private const string SessionVerifiedKey = "FP_OTP_VERIFIED";

    [WebMethod(EnableSession = true)]
    public static string SendOtp(string email)
    {
        try
        {
            // TODO: replace with a real lookup against your Users table.
            // if (!UserExists(email))
            //     return "No account found with that email address.";

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
