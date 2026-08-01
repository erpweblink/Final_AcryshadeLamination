using AjaxControlToolkit;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;

public partial class WorkOrderMaster : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'WorkOrderList.aspx'";
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


                txtworkorderdate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtworkorderdate.Enabled = false;

                if (Request.QueryString["Id"] != null)
                {
                    string ID = objcls.Decrypt(Request.QueryString["Id"].ToString());
                    hdnVal.Value = ID;
                    LoadData(ID);
                }
                if (Request.QueryString["OrderID"] != null)
                {
                    string ID = objcls.Decrypt(Request.QueryString["OrderID"].ToString());
                    hdnVal.Value = ID;
                    LoadOrderedData(ID);
                }           
            }
        }
    }

    protected void LoadData(string ID)
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_WorkOrderMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "WoHdrListById");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txttallyref.Text = dt.Rows[0]["TallyRefNo"].ToString();
            txttallyref.ReadOnly = true;

            DateTime dt1 = Convert.ToDateTime(dt.Rows[0]["WorkOrderDate"]);
            txtworkorderdate.Text = dt1.ToString("yyyy-MM-dd");

            txtDealerName.Text = dt.Rows[0]["Dealer"].ToString();
            txtDealerName.ReadOnly = true;
            txtCustName.Text = dt.Rows[0]["CustomerName"].ToString();
            txtCustName.ReadOnly = true;
            txtrefno.Text = dt.Rows[0]["CustomerRefNo"].ToString();
            txtrefno.ReadOnly = true;
            txtBillingAddress.Text = dt.Rows[0]["BillingAddress"].ToString();
            txtBillingAddress.ReadOnly = true;
            txtBillGst.Text = dt.Rows[0]["BillingGstNo"].ToString();
            txtBillGst.ReadOnly = true;
            txtShipAddress.Text = dt.Rows[0]["ShippingAddress"].ToString();
            txtShipGst.Text = dt.Rows[0]["ShippingGstNo"].ToString();
            txtShipGst.ReadOnly = true;
            txtBillPinCode.Text = dt.Rows[0]["BillingPincode"].ToString();
            txtBillPinCode.ReadOnly = true;
            txtShipPinCode.Text = dt.Rows[0]["ShippingPincode"].ToString();
            txtShipPinCode.ReadOnly = true;

            if (!string.IsNullOrWhiteSpace(dt.Rows[0]["AttachmentPath"].ToString()))
            {
                lblPdfUrl.HRef = ResolveUrl(dt.Rows[0]["AttachmentPath"].ToString().Replace("~/", "/Content/"));
                lblPdfUrl.Visible = true;
            }
            else
            {
                lblPdfUrl.Visible = false;
            }

            DateTime dt2 = Convert.ToDateTime(dt.Rows[0]["DeliveryDate"]);
            txtDeliveryDate.Text = dt2.ToString("yyyy-MM-dd");

            DataTable dts = new DataTable();
            SqlDataAdapter cmds = new SqlDataAdapter("SP_WorkOrderMaster", con);
            cmds.SelectCommand.CommandType = CommandType.StoredProcedure;
            cmds.SelectCommand.Parameters.AddWithValue("@SP_Action", "WODTLSListById");
            cmds.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
            cmds.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
            cmds.Fill(dts);
            if (dts.Rows.Count > 0)
            {
                JavaScriptSerializer js = new JavaScriptSerializer();

                List<Dictionary<string, object>> rows =
                    new List<Dictionary<string, object>>();

                foreach (DataRow dr in dts.Rows)
                {
                    Dictionary<string, object> row =
                        new Dictionary<string, object>();

                    foreach (DataColumn col in dts.Columns)
                    {
                        row.Add(col.ColumnName, dr[col]);
                    }

                    rows.Add(row);
                }

                string json = js.Serialize(rows);

                ClientScript.RegisterStartupScript(
                    this.GetType(),
                    "LoadWorkOrder",
                    "loadWorkOrderData(" + json + ");",
                    true);
            }
            btnsave.Text = "Update";
        }
    }

    protected void LoadOrderedData(string ID)
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter(@"SELECT DH.ID,OrderID,DH.DealerID as DealerID,UM.FullName as DealerName,
                        UM.BillAddress as BillAddress,
                        UM.GstNo as BillGST,UM.BillPinCode,DH.InvoicePath as AttachedPath
                        FROM tbl_DealersOrderHDR DH
                        INNER JOIN tbl_DealersOrderDTLs DD 
                        ON DD.HeaderID = DH.ID
                        LEFT JOIN tbl_UserMaster UM
                        ON UM.ID = DH.DealerID
                        WHERE DH.ID=@Id", con);
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txtworkorderdate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtworkorderdate.Enabled = false;
            txttallyref.AutoPostBack = false;

            txtDealerName.Text = dt.Rows[0]["DealerName"].ToString();
            hdnDealerId.Value = dt.Rows[0]["DealerID"].ToString();
            AutoCompleteExtender2.ContextKey = dt.Rows[0]["DealerID"].ToString();

            txtBillingAddress.Text = dt.Rows[0]["BillAddress"].ToString();
            txtrefno.Text = dt.Rows[0]["OrderID"].ToString();
            txtBillGst.Text = dt.Rows[0]["BillGST"].ToString();
            txtBillPinCode.Text = dt.Rows[0]["BillPinCode"].ToString();
            if (!string.IsNullOrWhiteSpace(dt.Rows[0]["AttachedPath"].ToString()))
            {
                lblPdfUrl.HRef = ResolveUrl(dt.Rows[0]["AttachedPath"].ToString().Replace("~/", "/Content/"));
                lblPdfUrl.Visible = true;
            }
            else
            {
                lblPdfUrl.Visible = false;
            }

            DataTable dts = new DataTable();
            SqlDataAdapter cmds = new SqlDataAdapter("Select * from tbl_DealersOrderDTLs WHERE HeaderID =@HeaderID ", con);
            cmds.SelectCommand.Parameters.AddWithValue("@HeaderID", ID);
            cmds.Fill(dts);
            if (dts.Rows.Count > 0)
            {
                JavaScriptSerializer js = new JavaScriptSerializer();

                List<Dictionary<string, object>> rows =
                    new List<Dictionary<string, object>>();

                foreach (DataRow dr in dts.Rows)
                {
                    Dictionary<string, object> row =
                        new Dictionary<string, object>();

                    foreach (DataColumn col in dts.Columns)
                    {
                        row.Add(col.ColumnName, dr[col]);
                    }

                    rows.Add(row);
                }

                string json = js.Serialize(rows);

                ClientScript.RegisterStartupScript(
                    this.GetType(),
                    "loadOrderData",
                    "loadOrderData(" + json + ");",
                    true);
            }
        }
    }

    protected void btnsave_Click(object sender, EventArgs e)
    {
        try
        {
            // MASTER VALUES
            string tallyref = txttallyref.Text.Trim().ToUpper();
            DateTime workorderdate = Convert.ToDateTime(txtworkorderdate.Text);
            string DealerName = txtDealerName.Text.Trim();
            string CustName = txtCustName.Text.Trim();
            string refno = txtrefno.Text.Trim();
            string BillingAddress = txtBillingAddress.Text.Trim();
            string ShipAddress = txtShipAddress.Text.Trim();
            string BillGst = txtBillGst.Text.Trim();
            string ShipGst = txtShipGst.Text.Trim();
            string BillPinCode = txtBillPinCode.Text.Trim();
            string ShipPinCode = txtShipPinCode.Text.Trim();
            DateTime DeliveryDate = Convert.ToDateTime(txtDeliveryDate.Text);
            int Id = 0;


            DataTable dt = new DataTable();
            dt.Columns.AddRange(new DataColumn[9] { new DataColumn("ProdId"),new DataColumn("ProductName"),new DataColumn("Type"),
                new DataColumn("Description"),new DataColumn("Size"),new DataColumn("Qty"),new DataColumn("SqFeet"),
                new DataColumn("ProdImageName"),new DataColumn("ProdFiles") });

            // DETAIL VALUES
            string[] ProductId = Request.Form.GetValues("ProductId[]");
            string[] ProductName = Request.Form.GetValues("ProductName[]");
            string[] Type = Request.Form.GetValues("Type[]");
            string[] Description = Request.Form.GetValues("Description[]");
            string[] Size = Request.Form.GetValues("Size[]");
            string[] Qty = Request.Form.GetValues("Qty[]");
            string[] SqFeet = Request.Form.GetValues("SqFeet[]");
            string[] Unit = Request.Form.GetValues("Unit[]");
            string[] ProdImageName = Request.Form.GetValues("ProdImageName[]");

            HttpFileCollection files = Request.Files;

            dt.Rows.Clear();

            int fileIndexs = 1;
            int invalidRow = -1;
            for (int i = 0; i < ProductName.Length; i++)
            {
                HttpPostedFile filessss = null;

                if (fileIndexs < files.Count)
                {
                    filessss = files[fileIndexs];
                    fileIndexs++;
                }

                dt.Rows.Add(
                     ProductId[i],
                     ProductName[i],
                     Type[i],
                     Description[i],
                     Size[i],
                     Qty[i],
                     SqFeet[i],
                     ProdImageName[i],
                     filessss
                 );

                if (string.IsNullOrWhiteSpace(ProductName[i]) ||
                   string.IsNullOrWhiteSpace(Size[i]) ||
                   string.IsNullOrWhiteSpace(Qty[i]))
                {
                    invalidRow = i;
                    break;
                }
            }

            if (invalidRow != -1)
            {
                var list = dt.AsEnumerable().Select(r => new
                {
                    ProductID = r["ProdId"],
                    ProductName = r["ProductName"],
                    ProductType = r["Type"],
                    ProductNote = r["Description"],
                    Size = r["Size"],
                    Qty = r["Qty"],
                    SqFeet = r["SqFeet"],
                    ImagePathName = r["ProdImageName"],
                    Files = r["ProdFiles"]
                }).ToList();

                string json = JsonConvert.SerializeObject(list);


                ClientScript.RegisterStartupScript(
                   this.GetType(),
                   "LoadValidateWorkOrderData",
                   "loadValidateWorkOrderData(" + json + ");highlightInvalidRow(" + invalidRow + ");",
                   true);

                return;
            }

            con.Open();

            int OrderHeaderID = 0;
            using (SqlCommand cmd = new SqlCommand("SP_WorkOrderMaster", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // MASTER DATA
                cmd.Parameters.AddWithValue("@TallyRefNo", tallyref);
                cmd.Parameters.AddWithValue("@WorkOrderDate", workorderdate);
                cmd.Parameters.AddWithValue("@Dealer", DealerName);
                cmd.Parameters.AddWithValue("@CustomerName", CustName);
                cmd.Parameters.AddWithValue("@CustomerRefNo", refno);
                cmd.Parameters.AddWithValue("@BillingAddress", BillingAddress);
                cmd.Parameters.AddWithValue("@ShippingAddress", ShipAddress);
                cmd.Parameters.AddWithValue("@BillingGstNo", BillGst);
                cmd.Parameters.AddWithValue("@ShippingGstNo", ShipGst);
                cmd.Parameters.AddWithValue("@BillingPincode", BillPinCode);
                cmd.Parameters.AddWithValue("@ShippingPincode", ShipPinCode);
                cmd.Parameters.AddWithValue("@DeliveryDate", DeliveryDate);
                cmd.Parameters.AddWithValue("@ActionBy", Session["ID"].ToString());


                // IMAGE SAVE
                if (FileMCImage.HasFile)
                {
                    string Filenamenew = FileMCImage.FileName;
                    string codenew = Guid.NewGuid().ToString();

                    string folderPath = Server.MapPath("~/Content/WOAttachedFiles/");

                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }

                    string fileName = codenew + "_" + Filenamenew;
                    string fullPath = Path.Combine(folderPath, fileName);

                    FileMCImage.SaveAs(fullPath);

                    cmd.Parameters.AddWithValue("@AttachmentPath",
                        "~/WOAttachedFiles/" + fileName);

                }
                else
                {
                    DataTable dtImage = new DataTable();
                    SqlDataAdapter da;
                    if (Request.QueryString["OrderID"] != null)
                    {
                        da = new SqlDataAdapter(
                            "SELECT InvoicePath as AttachmentPath FROM tbl_DealersOrderHDR WHERE ID=@Id",
                            con);
                    }
                    else
                    {
                        da = new SqlDataAdapter(
                            "SELECT AttachmentPath FROM tbl_WorkOrderHdr WHERE Id=@Id",
                            con);
                    }


                    da.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(string.IsNullOrWhiteSpace(hdnVal.Value) ? "0" : hdnVal.Value));

                    da.Fill(dtImage);

                    if (dtImage.Rows.Count > 0)
                    {
                        cmd.Parameters.AddWithValue("@AttachmentPath", dtImage.Rows[0]["AttachmentPath"]);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@AttachmentPath", DBNull.Value);
                    }
                }


                if (btnsave.Text == "Update")
                {
                    cmd.Parameters.AddWithValue("@Id", hdnVal.Value);
                    cmd.Parameters.AddWithValue("@SP_Action", "UpdateWoHdr");
                }
                else
                {
                    cmd.Parameters.AddWithValue("@SP_Action", "InsertWoHdr");
                }
                cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                cmd.ExecuteNonQuery();
                Id = Convert.ToInt32(cmd.Parameters["@Result"].Value);

                if (Request.QueryString["OrderID"] == null && Request.QueryString["Id"] == null)
                {
                    OrderHeaderID = CreateDealerOrderHdr(Id, hdnDealerId.Value);
                }
            }

            if (btnsave.Text == "Update")
            {
                using (SqlCommand cmd = new SqlCommand("SP_WorkOrderMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "DeleteWODTLS");
                    cmd.Parameters.AddWithValue("@Id", hdnVal.Value);
                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }
                Id = Convert.ToInt32(hdnVal.Value);
            }

            int fileIndex = 1;
            // LOOP THROUGH ALL ROWS
            for (int i = 0; i < ProductName.Length; i++)
            {
                if (string.IsNullOrWhiteSpace(ProductName[i]))
                {
                    continue;
                }

                using (SqlCommand cmd = new SqlCommand("SP_WorkOrderMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "InsertWODTLS");
                    cmd.Parameters.AddWithValue("@HeaderId", Id);
                    cmd.Parameters.AddWithValue("@ProductId", string.IsNullOrWhiteSpace(ProductId[i]) ? "" : ProductId[i]);
                    cmd.Parameters.AddWithValue("@ProductName", string.IsNullOrWhiteSpace(ProductName[i]) ? "" : ProductName[i]);
                    cmd.Parameters.AddWithValue("@PartNo", "0");
                    cmd.Parameters.AddWithValue("@Type", string.IsNullOrWhiteSpace(Type[i]) ? "0" : Type[i]);
                    cmd.Parameters.AddWithValue("@Description", string.IsNullOrWhiteSpace(Description[i]) ? Type[i] + "-N/A" : Description[i]);
                    cmd.Parameters.AddWithValue("@Size", string.IsNullOrWhiteSpace(Size[i]) ? "0" : Size[i]);
                    cmd.Parameters.AddWithValue("@Qty", string.IsNullOrWhiteSpace(Qty[i]) ? "0" : Qty[i]);
                    cmd.Parameters.AddWithValue("@SqFeet", string.IsNullOrWhiteSpace(SqFeet[i]) ? "0" : SqFeet[i]);
                    cmd.Parameters.AddWithValue("@Unit", string.IsNullOrWhiteSpace(Unit[i]) ? "" : Unit[i]);

                    HttpPostedFile file = null;

                    if (fileIndex < files.Count)
                    {
                        file = files[fileIndex];
                        fileIndex++;
                    }

                    if (file != null && file.ContentLength > 0)
                    {
                        string fileName = Guid.NewGuid() + "_" + Path.GetFileName(file.FileName);

                        string folderPath = Server.MapPath("~/Content/WOCustomProducts/");

                        if (!Directory.Exists(folderPath))
                        {
                            Directory.CreateDirectory(folderPath);
                        }

                        string fullPath = Path.Combine(folderPath, fileName);

                        SaveCompressedImage(file, fullPath, quality: 60, maxWidth: 800);

                        // file.SaveAs(Path.Combine(folderPath, fileName));

                        cmd.Parameters.AddWithValue(
                            "@UploadedImage",
                            "~/WOCustomProducts/" + fileName
                        );
                    }
                    else
                    {
                        if (!string.IsNullOrWhiteSpace(ProdImageName[i]) && ProdImageName[i] != "null")
                        {
                            cmd.Parameters.AddWithValue("@UploadedImage", ProdImageName[i].Replace("/Content", "~"));
                        }
                    }


                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }


            }

            if (Request.QueryString["OrderID"] == null && Request.QueryString["Id"] == null)
            {
                CreateDealerOrderDtls(Id, OrderHeaderID);
            }
            if (btnsave.Text == "Update")
            {
                UpdateDealerOrderDtls(Convert.ToInt32(hdnVal.Value));
            }

            if (Request.QueryString["OrderID"] != null)
            {
                string query = @"UPDATE tbl_DealersOrderHDR SET OrderStatus='Order Approved',EstimatedDeliveryDate = @EstimatedDeliveryDate,ApproveOrNotDate = GETDATE() WHERE ID = @OrderID ";

                SqlCommand cmds = new SqlCommand(query, con);
                cmds.Parameters.AddWithValue("@OrderID", hdnVal.Value);
                cmds.Parameters.AddWithValue("@EstimatedDeliveryDate", DeliveryDate);
                cmds.ExecuteNonQuery();

                string querys = @"UPDATE tbl_WorkOrderHdr SET PlaceOrderID=@OrderID WHERE ID =@ID";

                SqlCommand cmdss = new SqlCommand(querys, con);
                cmdss.Parameters.AddWithValue("@OrderID", hdnVal.Value);
                cmdss.Parameters.AddWithValue("@ID", Id);
                cmdss.ExecuteNonQuery();
            }

            con.Close();
            if (btnsave.Text == "Update")
            {
                Session["message"] = "Work Order updated successfully.";
            }
            else
            {
                Session["message"] = "Work Order created successfully.";
            }
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/WorkOrderList.aspx";

            Response.Redirect("/Alerts.aspx");
        }
        catch (Exception)
        {
            con.Close();
            throw;
        }
    }

    protected int CreateDealerOrderHdr(int Id, string dealerId)
    {
        int OrderHeaderId = 0;
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SELECT * FROM tbl_WorkOrderHdr WHERE Id = @Id", con);
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Id);
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            using (SqlCommand cmds = new SqlCommand("SP_WorkOrderMaster", con))
            {
                cmds.CommandType = CommandType.StoredProcedure;

                cmds.Parameters.AddWithValue("@Dealer", dealerId);
                cmds.Parameters.AddWithValue("@UploadedImage", string.IsNullOrEmpty(dt.Rows[0]["AttachmentPath"].ToString()) ? DBNull.Value : (Object)dt.Rows[0]["AttachmentPath"].ToString());
                cmds.Parameters.AddWithValue("@SP_Action", "PlaceorderHDR");
                cmds.Parameters.AddWithValue("@Unit", "Direct");
                cmds.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                cmds.ExecuteNonQuery();
                OrderHeaderId = Convert.ToInt32(cmds.Parameters["@Result"].Value);
            }


            DataTable dt2 = new DataTable();
            SqlDataAdapter cmd2 = new SqlDataAdapter("SELECT * FROM tbl_DealersOrderHDR WHERE Id = @Id", con);
            cmd2.SelectCommand.Parameters.AddWithValue("@Id", OrderHeaderId);
            cmd2.Fill(dt2);
            if (dt2.Rows.Count > 0)
            {
                string querys = @"UPDATE tbl_WorkOrderHdr SET PlaceOrderID = @OrderID,CustomerRefNo = @OrderNo WHERE ID =@ID";

                SqlCommand cmdss = new SqlCommand(querys, con);
                cmdss.Parameters.AddWithValue("@OrderID", OrderHeaderId);
                cmdss.Parameters.AddWithValue("@OrderNo", dt2.Rows[0]["OrderID"].ToString());
                cmdss.Parameters.AddWithValue("@ID", Id);
                cmdss.ExecuteNonQuery();

            }

               
        }
        return OrderHeaderId;
    }

    protected void CreateDealerOrderDtls(int Id, int OrderHeaderId)
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SELECT * FROM tbl_WorkOrderDetails WHERE HeaderId = @Id", con);
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Id);
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                using (SqlCommand cmds = new SqlCommand("SP_WorkOrderMaster", con))
                {
                    cmds.CommandType = CommandType.StoredProcedure;

                    cmds.Parameters.AddWithValue("@HeaderID", OrderHeaderId);
                    cmds.Parameters.AddWithValue("@ProductId", dt.Rows[i]["ProductId"].ToString());
                    cmds.Parameters.AddWithValue("@ProductName", dt.Rows[i]["ProductName"].ToString());
                    cmds.Parameters.AddWithValue("@Type", dt.Rows[i]["Type"].ToString());
                    cmds.Parameters.AddWithValue("@Size", dt.Rows[i]["Size"].ToString());
                    cmds.Parameters.AddWithValue("@Qty", dt.Rows[i]["Qty"].ToString());
                    cmds.Parameters.AddWithValue("@Description", dt.Rows[i]["Description"].ToString());
                    cmds.Parameters.AddWithValue("@UploadedImage", string.IsNullOrEmpty(dt.Rows[i]["UploadedImage"].ToString()) ? DBNull.Value : (Object)dt.Rows[i]["UploadedImage"].ToString());
                    cmds.Parameters.AddWithValue("@SP_Action", "PlaceorderDtls");
                    cmds.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmds.ExecuteNonQuery();
                }
            }

        }
    }

    protected void UpdateDealerOrderDtls(int Id)
    {
        DataTable dt1 = new DataTable();
        SqlDataAdapter cmd1 = new SqlDataAdapter("SELECT * FROM tbl_WorkOrderHdr WHERE Id = @Id", con);
        cmd1.SelectCommand.Parameters.AddWithValue("@Id", Id);
        cmd1.Fill(dt1);
        if (dt1.Rows.Count > 0)
        {
            DataTable dt2 = new DataTable();
            SqlDataAdapter cmd2 = new SqlDataAdapter("SELECT * FROM tbl_DealersOrderHDR WHERE Id = @Id", con);
            cmd2.SelectCommand.Parameters.AddWithValue("@Id", 
                string.IsNullOrWhiteSpace(dt1.Rows[0]["PlaceOrderID"].ToString())
                ? "0" : dt1.Rows[0]["PlaceOrderID"].ToString());
            cmd2.Fill(dt2);
            if (dt2.Rows.Count > 0)
            {
                using (SqlCommand cmdss = new SqlCommand("DELETE tbl_DealersOrderDTLs WHERE HeaderId = @HeaderId", con))
                {
                    cmdss.Parameters.AddWithValue("@HeaderId", dt2.Rows[0]["Id"].ToString());
                    cmdss.ExecuteNonQuery();
                }


                DataTable dt = new DataTable();
                SqlDataAdapter cmd = new SqlDataAdapter("SELECT * FROM tbl_WorkOrderDetails WHERE HeaderId = @Id", con);
                cmd.SelectCommand.Parameters.AddWithValue("@Id", Id);
                cmd.Fill(dt);
                if (dt.Rows.Count > 0)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        using (SqlCommand cmds = new SqlCommand("SP_WorkOrderMaster", con))
                        {
                            cmds.CommandType = CommandType.StoredProcedure;

                            cmds.Parameters.AddWithValue("@HeaderID", dt2.Rows[0]["Id"].ToString());
                            cmds.Parameters.AddWithValue("@ProductId", dt.Rows[i]["ProductId"].ToString());
                            cmds.Parameters.AddWithValue("@ProductName", dt.Rows[i]["ProductName"].ToString());
                            cmds.Parameters.AddWithValue("@Type", dt.Rows[i]["Type"].ToString());
                            cmds.Parameters.AddWithValue("@Size", dt.Rows[i]["Size"].ToString());
                            cmds.Parameters.AddWithValue("@Qty", dt.Rows[i]["Qty"].ToString());
                            cmds.Parameters.AddWithValue("@Description", dt.Rows[i]["Description"].ToString());
                            cmds.Parameters.AddWithValue("@UploadedImage", string.IsNullOrEmpty(dt.Rows[i]["UploadedImage"].ToString()) ? DBNull.Value : (Object)dt.Rows[i]["UploadedImage"].ToString());
                            cmds.Parameters.AddWithValue("@SP_Action", "PlaceorderDtls");
                            cmds.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                            cmds.ExecuteNonQuery();
                        }
                    }

                }
            }
        }
    }

    public static void SaveCompressedImage(HttpPostedFile file, string fullPath, int quality = 60, int maxWidth = 800)
    {
        using (var image = Image.FromStream(file.InputStream))
        {
            int newWidth = image.Width;
            int newHeight = image.Height;

            // resize if image is too large
            if (image.Width > maxWidth)
            {
                newWidth = maxWidth;
                newHeight = (image.Height * maxWidth) / image.Width;
            }

            using (var bitmap = new Bitmap(image, new Size(newWidth, newHeight)))
            {
                ImageCodecInfo jpgEncoder = ImageCodecInfo
                    .GetImageDecoders()
                    .First(c => c.FormatID == ImageFormat.Jpeg.Guid);

                Encoder encoder = Encoder.Quality;
                EncoderParameters encParams = new EncoderParameters(1);

                encParams.Param[0] = new EncoderParameter(encoder, quality);

                bitmap.Save(fullPath, jpgEncoder, encParams);
            }
        }
    }

    protected void btnDeList_Click(object sender, EventArgs e)
    {
        Response.Redirect("WorkOrderList.aspx");
    }

    [WebMethod]
    public static List<string> GetDealerNameList(string prefixText, int count)
    {
        return AutoFillGetDealerNameList(prefixText);
    }

    public static List<string> AutoFillGetDealerNameList(string prefixText)
    {
        List<string> items = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"
            SELECT DISTINCT ID, FullName
            FROM tbl_UserMaster
            WHERE Type='Authorized'
              AND UserRole='Dealer'
              AND IsDeleted=0
              AND FullName LIKE '%' + @Search + '%'";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Search", prefixText);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                string dealerName = dr["FullName"].ToString();
                string dealerId = dr["ID"].ToString();

                items.Add(
                    AutoCompleteExtender.CreateAutoCompleteItem(
                        dealerName,
                        dealerId
                    )
                );
            }
        }

        return items;
    }

    [WebMethod]
    public static List<string> GetDealersInfo(string dealerId)
    {
        List<string> list = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"SELECT BillAddress,BillPinCode,GstNo,ShipAddress,ShipPinCode
                         FROM tbl_UserMaster
                         WHERE ID=@dealerId";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@dealerId", dealerId);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                list.Add(dr["BillAddress"].ToString());
                list.Add(dr["BillPinCode"].ToString());
                list.Add(dr["GstNo"].ToString());
                list.Add(dr["ShipAddress"].ToString());
                list.Add(dr["ShipPinCode"].ToString());
            }
        }

        return list;
    }

    [WebMethod]
    public static List<string> GetCustNameList(string prefixText, int count)
    {
        return AutoFillGetCustNameList(prefixText);
    }

    public static List<string> AutoFillGetCustNameList(string prefixText)
    {
        List<string> items = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"
            SELECT DISTINCT ID, FullName as CompanyName
            FROM tbl_UserMaster
            WHERE Type='Authorized'
              AND UserRole='Dealer'
              AND IsDeleted=0
              AND FullName LIKE '%' + @Search + '%' --CreatedBy = @Id AND";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Search", prefixText);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                string companyName = dr["CompanyName"].ToString();
                string companyId = dr["ID"].ToString();

                items.Add(
                    AutoCompleteExtender.CreateAutoCompleteItem(
                       companyName,
                       companyId
                    )
                );
            }
        }

        return items;
    }

    [WebMethod]
    public static List<string> GetShippingAddresses(string companyId)
    {
        List<string> list = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"SELECT ShipAddress,ShipPinCode,GstNo
                         FROM tbl_UserMaster
                         WHERE ID=@dealerId";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@dealerId", companyId);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                list.Add(dr["ShipAddress"].ToString());
                list.Add(dr["ShipPinCode"].ToString());
                list.Add(dr["GstNo"].ToString());
            }
        }

        return list;
    }

    [WebMethod]
    public static object GetProductAutoComplete(string prefixText)
    {
        var list = new List<object>();

        string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(cs))
        {
            string query = @"
                SELECT TOP 30
                       ID,
                       Productname,
                       PartNo,
                       Size,
                       ImagenamePath
                FROM tbl_prodcutmaster
                WHERE Productname LIKE '%' + @Search + '%'
                  AND isdeleted = 0 AND isActive = 1
                ORDER BY Productname";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Search", prefixText);

            con.Open();

            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    list.Add(new
                    {
                        ProductId = Convert.ToInt32(dr["ID"]),
                        ProductName = dr["Productname"].ToString(),
                        PartNo = dr["PartNo"].ToString(),
                        Size = dr["Size"].ToString(),
                        ImagenamePath = dr["ImagenamePath"].ToString(),
                    });
                }
            }
        }

        return list;
    }

    [WebMethod]
    public static object SaveProductMaster(string ProductName, string Size)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                SqlCommand checkCmd = new SqlCommand(
                    @"SELECT COUNT(*) 
                  FROM tbl_ProdcutMaster
                  WHERE UPPER(REPLACE(LTRIM(RTRIM(ProductName)), ' ', '')) = UPPER(REPLACE(LTRIM(RTRIM(@ProductName)), ' ', ''))", con);

                checkCmd.Parameters.AddWithValue("@ProductName", ProductName);

                int count = Convert.ToInt32(checkCmd.ExecuteScalar());

                if (count == 0)
                {
                    SqlCommand insertCmd = new SqlCommand(
                        @"INSERT INTO tbl_ProdcutMaster
                      (Productcode,Productname,Size,IsActive,IsDeleted,CreatedBy,CreatedOn)
                      VALUES
                      ([dbo].[FN_ProductNo](),@ProductName,@Size,1,0,@ActionBy,GETDATE())", con);

                    insertCmd.Parameters.AddWithValue("@ProductName", ProductName);
                    insertCmd.Parameters.AddWithValue("@Size", Size);
                    insertCmd.Parameters.AddWithValue("@ActionBy", HttpContext.Current.Session["ID"].ToString());

                    insertCmd.ExecuteNonQuery();
                    return "Success";
                }
            }

            return "No";
        }
        catch (Exception)
        {
            throw;
        }
    }

    [WebMethod]
    public static bool ValidateTallyRef(string TallyNo)
    {
        if (string.IsNullOrWhiteSpace(TallyNo))
            return false;

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            con.Open();

            SqlCommand cmd = new SqlCommand(@"
            SELECT COUNT(*)
            FROM tbl_WorkOrderHdr
            WHERE IsDeleted = 0
            AND UPPER(REPLACE(LTRIM(RTRIM(TallyRefNo)), ' ', '')) =
                UPPER(REPLACE(LTRIM(RTRIM(@TallyRef)), ' ', ''))", con);

            cmd.Parameters.AddWithValue("@TallyRef", TallyNo.Trim());

            int count = Convert.ToInt32(cmd.ExecuteScalar());

            return count > 0;
        }
    }

    [WebMethod]
    public static bool CheckDealer(string dealerName)
    {
        bool isExists = false;

        string conString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(conString))
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(1) FROM tbl_UserMaster WHERE FullName=@DealerName", con))
            {
                cmd.Parameters.AddWithValue("@DealerName", dealerName);

                con.Open();

                isExists = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        return isExists;
    }
}

