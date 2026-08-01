<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="WorkOrderList.aspx.cs" Inherits="WorkOrderList" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <style type="text/css">
        .completionList {
            scroll-behavior: smooth;
            border: solid 1px Gray;
            border-radius: 0 0 6px 6px;
            margin: 0px;
            padding: 3px;
            height: 200px;
            overflow: auto;
            width: 500px;
            background-color: #FFFFFF;
            font-size: 16px;
        }

        .listItem {
            color: #191919;
        }

        .itemHighlighted {
            background-color: #5b78b1;
            font-weight: 900;
        }



        /*CSS fro Image Pop UP*/
        .product-image-preview {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border: 1px solid #ddd;
            border-radius: 8px;
            cursor: pointer;
        }

        .image-hover-container {
            display: inline-block;
        }

        .image-popup {
            display: none;
            position: fixed; /* important */
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 99999;
            background: #fff;
            padding: 10px;
            border-radius: 10px;
            box-shadow: 0 0 25px rgba(0,0,0,.4);
        }

            .image-popup img {
                max-width: 600px;
                max-height: 500px;
                width: auto;
                height: auto;
            }

        .image-hover-container:hover .image-popup {
            display: block;
        }
        /*END*/
    </style>
    <script type="text/javascript">
        $("[src*=add-black]").live("click", function () {
            $(this).closest("tr").after("<tr><td></td><td colspan = '999'>" + $(this).next().html() + "</td></tr>")
            $(this).attr("src", "/Content/assets/images/newminus.png");
        });
        $("[src*=newminus]").live("click", function () {
            $(this).attr("src", "/Content/assets/images/add-black.png");
            $(this).closest("tr").next().remove();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Work Order List</b></h3>
                    <asp:Button ID="btnCreate" CssClass="btn btn-outline-primary" Font-Bold="true" Text="Create" CausesValidation="false" OnClick="btnCreate_Click" runat="server" />
                </div>
                <div class="card-body">
                    <div class="row align-items-end">
                        <div class="col-md-3">
                            <asp:Label ID="Label1" runat="server" Font-Bold="true" CssClass="form-label">Search:</asp:Label>
                            <asp:TextBox ID="txtcompanyname" CssClass="form-control" runat="server" Width="100%"></asp:TextBox>
                        </div>
                        <div class="col-md-2">
                            <asp:LinkButton ID="btnSearch" runat="server"
                                OnClick="txtCustomerName_TextChanged" CssClass="btn btn-outline-success"> 
                            <i class="bi bi-search" ></i>
                             </asp:LinkButton>
                            <asp:LinkButton ID="btnrefresh" runat="server"
                                OnClick="btnrefresh_Click" CssClass="btn btn-outline-danger"> 
                                <i class="bi bi-arrow-clockwise" ></i>
                            </asp:LinkButton>
                        </div>
                        <div class="col-md-7 d-flex justify-content-end">
                            <div style="width: 120px;">
                                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-control" AutoPostBack="true" Font-Bold="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                                    <asp:ListItem Text="10" Value="10" Selected="True" />
                                    <asp:ListItem Text="50" Value="50" />
                                    <asp:ListItem Text="All" Value="0" />
                                </asp:DropDownList>
                            </div>
                            <div style="width: 200px;">
                                <asp:DropDownList ID="ddlWOStatus" runat="server" CssClass="form-control" AutoPostBack="true" Font-Bold="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                                    <asp:ListItem Text="Sent for Approval" Value="Assigned" Selected="True" />
                                    <asp:ListItem Text="Design Approved" Value="Completed" />
                                    <asp:ListItem Text="Design Rejected" Value="Rejected" />
                                    <asp:ListItem Text="W/O On Hold" Value="W/O On Hold" />
                                    <asp:ListItem Text="W/O Canceled" Value="W/O Canceled" />
                                    <asp:ListItem Text="All" Value="" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>

                    <hr />
                    <div class="table-responsive">
                        <asp:GridView ID="GVCompany" runat="server" DataKeyNames="ID" OnRowDataBound="GVCompany_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#2d6be0"
                            HeaderStyle-Font-Bold="true" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="GVCompany_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText=" " HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <img alt="" style="cursor: pointer; width: 26px;" src="/Content/assets/images/add-black.png" />
                                        <asp:Panel ID="pnlOrders" runat="server" Style="display: none">
                                            <asp:GridView ID="gvDetails" runat="server" HeaderStyle-HorizontalAlign="Center"
                                                HeaderStyle-Font-Bold="true" CssClass="display table table-striped table-hover" AutoGenerateColumns="false">
                                                <HeaderStyle BackColor="#2d6be0" />
                                                <Columns>
                                                    <asp:TemplateField HeaderText="Sr.No." HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblsnos" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" HeaderStyle-ForeColor="White" DataField="ProductName" HeaderText="Product Name" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" HeaderStyle-ForeColor="White" DataField="Description" HeaderText="Description" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" HeaderStyle-ForeColor="White" DataField="Size" HeaderText="Size" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" HeaderStyle-ForeColor="White" DataField="Unit" HeaderText="Unit" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" HeaderStyle-ForeColor="White" DataField="Qty" HeaderText="Qty" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" HeaderStyle-ForeColor="White" DataField="SqFeet" HeaderText="Sq Feet" />
                                                    <asp:TemplateField HeaderText="Custom Image" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <div class="image-hover-container">
                                                                <asp:Image ID="imG" runat="server"
                                                                    ImageUrl='<%# !string.IsNullOrEmpty(Convert.ToString(Eval("UploadedImage"))) 
                                                                    ? Convert.ToString(Eval("UploadedImage")).Replace("~/", "/Content/") 
                                                                    : "https://placehold.co/100x100?text=" + Convert.ToString(Eval("Productname")) %>'
                                                                    CssClass="product-image-preview" />

                                                                <div class="image-popup">
                                                                    <asp:Image ID="imgLarge" runat="server"
                                                                        ImageUrl='<%# !string.IsNullOrEmpty(Convert.ToString(Eval("UploadedImage"))) 
                                                                        ? Convert.ToString(Eval("UploadedImage")).Replace("~/", "/Content/") 
                                                                        : "https://placehold.co/400x400?text=" + Convert.ToString(Eval("Productname")) %>' />
                                                                </div>
                                                            </div>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </asp:Panel>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sr.No." HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Tally Ref No." HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTallyRefNo" runat="server" ForeColor="Red" Font-Bold="true" Text='<%#Eval("TallyRefNo")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer/Billing Name" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDealer" runat="server" Text='<%#Eval("Dealer")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distributor/Shipping Name" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCustomerName" runat="server" Text='<%#Eval("CustomerName")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="WorkOrder Date" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWorkOrderDate" runat="server" Text='<%#Eval("WorkOrderDate")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Attachment" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btn_View_aattach" runat="server" CommandName="RowPO" CommandArgument='<%# Eval("AttachmentPath") %>'
                                            ForeColor='<%# string.IsNullOrEmpty(Convert.ToString(Eval("AttachmentPath"))) ? System.Drawing.Color.Red : System.Drawing.Color.FromArgb(13,110,253) %>'
                                            Enabled='<%# string.IsNullOrEmpty(Convert.ToString(Eval("AttachmentPath"))) ? false:true %>'
                                            ToolTip="Open File"><i class="bi-file-earmark-medical"  style="font-size:26px;"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Design Status" ItemStyle-Width="150" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDesignStatus" runat="server" Font-Bold="true" ForeColor='<%#
                                                (Convert.ToBoolean(Eval("isdesignapproved")) && Convert.ToBoolean(Eval("SendForDesign")))
                                                    ? System.Drawing.ColorTranslator.FromHtml("#f36700")
                                                    : (!Convert.ToBoolean(Eval("isdesignapproved")) && Convert.ToBoolean(Eval("SendForDesign")))
                                                        ? System.Drawing.ColorTranslator.FromHtml("#0064FF")
                                                        : System.Drawing.Color.Red
                                            %>'
                                            Text='<%#Eval("DesignerStatus")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="ACTION" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="160px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit"
                                            runat="server"
                                            CommandName="RowEdit"
                                            CommandArgument='<%# Eval("ID") %>'
                                            CssClass="btn btn-outline-info btn-sm"
                                            Visible='<%#
                                                    !(Convert.ToBoolean(Eval("isdesignapproved")) ||
                                                      Convert.ToBoolean(Eval("HoldStatus")) ||
                                                      Convert.ToBoolean(Eval("CancelStatus")))
                                                %>'>
                                                <i class="bi bi-pencil"></i>
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnDelete"
                                            runat="server"
                                            CommandName="RowDelete"
                                            CommandArgument='<%# Eval("ID") %>'
                                            OnClientClick="return confirm('Are you sure to Delete?')"
                                            CssClass="btn btn-outline-danger btn-sm"
                                            Visible='<%#
                                                    !(Convert.ToBoolean(Eval("isdesignapproved")) ||
                                                      Convert.ToBoolean(Eval("HoldStatus")) ||
                                                      Convert.ToBoolean(Eval("CancelStatus")))
                                                %>'>
                                                <i class="bi bi-trash3-fill"></i>
                                        </asp:LinkButton>
                                        <asp:Label ID="lblStatus"
                                            runat="server"
                                            Font-Bold="true"
                                            Visible='<%#
                                                Convert.ToBoolean(Eval("CancelStatus")) ||
                                                Convert.ToBoolean(Eval("HoldStatus")) ||
                                                Convert.ToBoolean(Eval("isdesignapproved"))
                                            %>'
                                            Text='<%#
                                                Convert.ToBoolean(Eval("CancelStatus")) ? "<i><small>W/O Canceled</small></i>" :
                                                Convert.ToBoolean(Eval("HoldStatus")) ? "<i><small>W/O On Hold</small></i>" :
                                                Convert.ToBoolean(Eval("isdesignapproved")) ? "<i><small>W/O Approved</small></i>" :
                                                "W/O Not Approved</small></i>"
                                            %>'
                                            ForeColor='<%#
                                                Convert.ToBoolean(Eval("CancelStatus")) ? System.Drawing.Color.Red :
                                                Convert.ToBoolean(Eval("HoldStatus")) ? System.Drawing.Color.Orange :
                                                System.Drawing.Color.Green
                                            %>'
                                            ToolTip='<%#
                                                Convert.ToBoolean(Eval("CancelStatus")) ? Eval("CancelRemark").ToString() :
                                                Convert.ToBoolean(Eval("HoldStatus")) ? Eval("HoldRemark").ToString() :
                                                ""
                                            %>'>
                                        </asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Hold/Cancel" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="160px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnHold" runat="server" ToolTip="Hold W/O" CommandName="RowHold" CommandArgument='<%#Eval("ID")%>' CssClass="btn btn-warning btn-sm"><i class="bi bi-pause-circle"></i></asp:LinkButton>
                                        <asp:LinkButton ID="btnCancel" runat="server" ToolTip="Cancel W/O" CommandName="RowCancel" OnClientClick="Javascript:return confirm('Are you sure to Cancel?')" CommandArgument='<%#Eval("ID")%>' CssClass="btn btn-danger btn-sm"><i class="bi bi-x-circle"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
