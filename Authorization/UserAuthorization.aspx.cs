using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.Services;

public partial class UserAuthorization : System.Web.UI.Page
{
    // Kept only for the access-check on Page_Load - all data operations for
    // the grid now happen through static WebMethods, which open their own connections.
    private static string ConStr
    {
        get { return ConfigurationManager.ConnectionStrings["constr"].ConnectionString; }
    }

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
                // Check if the current user has access to this page
                if (Session["Role"].ToString() != "Admin")
                {
                    string username = Session["ID"].ToString();
                    using (SqlConnection cons = new SqlConnection(ConStr))
                    {
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'UserAuthorization.aspx'";
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
                // Everything else (roles, users, grid) is now loaded client-side via PageMethods.
            }
        }
    }

    // ---------------------------------------------------------------------
    // WebMethods - these are static, so they can be called directly from
    // JavaScript via PageMethods.MethodName(...) without a postback.
    // ---------------------------------------------------------------------

    /// <summary>
    /// JavaScriptSerializer cannot serialize a DataTable directly - it carries
    /// internal references (Site, Container, ExtendedProperties, etc.) that
    /// trigger "A circular reference was detected" errors. Converting each row
    /// to a plain Dictionary&lt;string, object&gt; first avoids that entirely.
    /// </summary>
    private static List<Dictionary<string, object>> DataTableToList(DataTable dt)
    {
        var list = new List<Dictionary<string, object>>();

        foreach (DataRow row in dt.Rows)
        {
            var dict = new Dictionary<string, object>();
            foreach (DataColumn col in dt.Columns)
            {
                object value = row[col];
                dict[col.ColumnName] = (value == DBNull.Value) ? null : value;
            }
            list.Add(dict);
        }

        return list;
    }

    [WebMethod]
    public static string GetRoles()
    {
        DataTable dt = new DataTable();
        using (SqlConnection con = new SqlConnection(ConStr))
        {
            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT ID, Roles FROM tbl_RoleMaster WHERE IsDeleted = 0", con);
            da.Fill(dt);
        }

        var serializer = new JavaScriptSerializer();
        return serializer.Serialize(DataTableToList(dt));
    }

    /// <summary>
    /// Returns every user for a given role, tagged with a Status of "Pending" (no rows yet
    /// in tbl_UserRoleAuthorization) or "Completed" (already has at least one row).
    /// Filtering/searching is done client-side against this full list so switching
    /// between All/Pending/Completed or typing a search term is instant, with no
    /// extra server round-trip.
    /// </summary>
    [WebMethod]
    public static string GetUsers(string roleId)
    {
        DataTable dt = new DataTable();

        string query = @"
            SELECT U.ID, U.FullName,
                   CASE WHEN EXISTS (
                        SELECT 1 FROM tbl_UserRoleAuthorization UR WHERE UR.UserID = U.ID
                   ) THEN 'Completed' ELSE 'Pending' END AS Status
            FROM tbl_UserMaster U
            WHERE U.UserRole = (SELECT Roles FROM tbl_RoleMaster WHERE ID = @RoleId)
              AND U.IsDeleted = 0 AND U.IsActivate = 1
            ORDER BY U.FullName";

        using (SqlConnection con = new SqlConnection(ConStr))
        {
            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@RoleId", roleId);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }

        var serializer = new JavaScriptSerializer();
        return serializer.Serialize(DataTableToList(dt));
    }

    /// <summary>
    /// Returns every page in tbl_AuthPages, left-joined against whatever
    /// authorization the selected user already has (if any).
    /// </summary>
    [WebMethod]
    public static string GetUserPages(string userId)
    {
        DataTable dt = new DataTable();

        string query = @"
            SELECT AP.ID AS MenuId,
                   AP.MenuName AS MenuName,
                   AP.PageName AS PageName,
                   ISNULL(UR.PageAccess, 'False') AS PageAccess,
                   ISNULL(UR.PagesButtonAccess, 'False') AS PageButtonAccess
            FROM tbl_AuthPages AP
            LEFT JOIN tbl_UserRoleAuthorization UR
                   ON AP.ID = UR.MenuId AND UR.UserID = @UserId
            ORDER BY AP.ID";

        using (SqlConnection con = new SqlConnection(ConStr))
        {
            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@UserId", userId);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }

        var serializer = new JavaScriptSerializer();
        return serializer.Serialize(DataTableToList(dt));
    }

    /// <summary>
    /// Upserts one row per page for the selected user:
    ///  - if a row already exists for (UserId, MenuId) -> UPDATE just the access flags
    ///  - otherwise -> INSERT a new row
    /// This replaces the old "delete everything then re-insert" approach, so the
    /// int identity column no longer gets burned through on every save.
    /// </summary>
    [WebMethod(EnableSession = true)]
    public static string SaveAuthorization(string userId, string userName, string pagesJson)
    {
        var serializer = new JavaScriptSerializer();
        List<Dictionary<string, object>> pages = serializer.Deserialize<List<Dictionary<string, object>>>(pagesJson);

        string actionBy = HttpContextCurrentUserId();

        using (SqlConnection con = new SqlConnection(ConStr))
        {
            con.Open();

            foreach (var p in pages)
            {
                int menuId = Convert.ToInt32(p["MenuId"]);
                string menuName = Convert.ToString(p["MenuName"]);
                string pageName = Convert.ToString(p["PageName"]);
                bool pageAccess = Convert.ToBoolean(p["PageAccess"]);
                bool pageButtonAccess = Convert.ToBoolean(p["PageButtonAccess"]);

                // Does a row already exist for this user + menu?
                SqlCommand chk = new SqlCommand(
                    "SELECT COUNT(1) FROM tbl_UserRoleAuthorization WHERE UserID = @UserId AND MenuId = @MenuId", con);
                chk.Parameters.AddWithValue("@UserId", userId);
                chk.Parameters.AddWithValue("@MenuId", menuId);
                int existingCount = (int)chk.ExecuteScalar();

                if (existingCount > 0)
                {
                    SqlCommand upd = new SqlCommand(@"
                        UPDATE tbl_UserRoleAuthorization
                        SET PageAccess = @PageAccess,
                            PagesButtonAccess = @PageButtonAccess,
                            CreatedBy = @ActionBy
                        WHERE UserID = @UserId AND MenuId = @MenuId", con);

                    upd.Parameters.AddWithValue("@PageAccess", pageAccess);
                    upd.Parameters.AddWithValue("@PageButtonAccess", pageButtonAccess);
                    upd.Parameters.AddWithValue("@ActionBy", actionBy);
                    upd.Parameters.AddWithValue("@UserId", userId);
                    upd.Parameters.AddWithValue("@MenuId", menuId);
                    upd.ExecuteNonQuery();
                }
                else
                {
                    SqlCommand ins = new SqlCommand(@"
                        INSERT INTO tbl_UserRoleAuthorization
                            (UserID, UserName, MenuId, MenuName, PageName, PageAccess, PagesButtonAccess, CreatedBy)
                        VALUES
                            (@UserId, @UserName, @MenuId, @MenuName, @PageName, @PageAccess, @PageButtonAccess, @ActionBy)", con);

                    ins.Parameters.AddWithValue("@UserId", userId);
                    ins.Parameters.AddWithValue("@UserName", userName);
                    ins.Parameters.AddWithValue("@MenuId", menuId);
                    ins.Parameters.AddWithValue("@MenuName", menuName);
                    ins.Parameters.AddWithValue("@PageName", pageName);
                    ins.Parameters.AddWithValue("@PageAccess", pageAccess);
                    ins.Parameters.AddWithValue("@PageButtonAccess", pageButtonAccess);
                    ins.Parameters.AddWithValue("@ActionBy", actionBy);
                    ins.ExecuteNonQuery();
                }
            }
        }

        return "Success";
    }

    /// <summary>
    /// WebMethods are static, so they can't read the instance Session/HttpContext
    /// the way normal event handlers do. HttpContext.Current still works fine
    /// inside a WebMethod though, so we use that to get the current admin's ID.
    /// </summary>
    private static string HttpContextCurrentUserId()
    {
        var ctx = System.Web.HttpContext.Current;
        if (ctx != null && ctx.Session != null && ctx.Session["ID"] != null)
        {
            return ctx.Session["ID"].ToString();
        }
        return null;
    }
}