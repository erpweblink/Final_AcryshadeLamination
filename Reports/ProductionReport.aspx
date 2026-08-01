<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ProductionReport.aspx.cs" Inherits="Reports_ProductionReport" MasterPageFile="~/MasterPage.master" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
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
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Production Report</b></h3>
                    <asp:Button ID="btnExportExcel" runat="server" Text="Export To Excel"
                        CssClass="btn btn-outline-success" OnClick="btnExportExcel_Click" />
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-3 col-12">
                            <asp:Label runat="server" Font-Bold="true">Product</asp:Label>
                            <asp:TextBox ID="txtproduct" runat="server"
                                CssClass="form-control"
                                AutoPostBack="true" OnTextChanged="txtDealer_TextChanged">
                            </asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender2" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetproductList"
                                TargetControlID="txtproduct" Enabled="true">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="col-md-2 col-12">
                            <asp:Label runat="server" Font-Bold="true">Machine</asp:Label>
                            <asp:DropDownList ID="ddlMachine" runat="server"
                                CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlDeliveryStatus_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <asp:Label runat="server" Font-Bold="true">Delivery Status</asp:Label>
                            <asp:DropDownList ID="ddlDeliveryStatus" runat="server"
                                CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlDeliveryStatus_SelectedIndexChanged">
                                <asp:ListItem Value="">All</asp:ListItem>
                                <asp:ListItem Value="Overdue">Overdue</asp:ListItem>
                                <asp:ListItem Value="Not Overdue">Not Overdue</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3 col-12">
                            <asp:Label runat="server" Font-Bold="true">Dealer</asp:Label>
                            <asp:TextBox ID="txtDealer" CssClass="form-control" runat="server" Width="100%" autocomplete="off" OnTextChanged="txtDealer_TextChanged" AutoPostBack="true"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetCompanyList"
                                TargetControlID="txtDealer" Enabled="true">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="col-md-2 col-12">
                            <asp:Label runat="server" Font-Bold="true">Status</asp:Label>
                            <asp:DropDownList ID="ddlstatus" runat="server"
                                CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlDeliveryStatus_SelectedIndexChanged">
                                <asp:ListItem Value="">All</asp:ListItem>
                                <asp:ListItem Value="Pending">Pending</asp:ListItem>
                                <asp:ListItem Value="Dispatched">Dispatched</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <br />
                    <div class="table-responsive">
                        <asp:GridView ID="GvProduction" runat="server" AutoGenerateColumns="False" HeaderStyle-BackColor="#2d6be0"
                            HeaderStyle-Font-Bold="true" HeaderStyle-HorizontalAlign="Center"
                            EmptyDataText="Record Not Found" CssClass="table table-bordered table-striped">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.No." HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="TallyRefNo" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="Red" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center" HeaderText="Work Order No." />
                                <asp:BoundField DataField="Dealer" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center" HeaderText="Dealer" />
                                <asp:TemplateField HeaderText="Product Name" HeaderStyle-Width="350"  ItemStyle-Width="350" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                       <asp:Literal ID="litProductName" runat="server"
                                                Text='<%# Eval("ProductName").ToString().Replace(",", "<br />") %>'>
                                        </asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="TotalQty" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center" HeaderText="Total Qty" />
                                <asp:BoundField DataField="TotalSqFeet" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center" HeaderText="Total SqFeet" />
                                <asp:TemplateField HeaderText="Production Status" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblProductionStatus" runat="server" Text='<%#Eval("ProductionStatus")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dispatch Status" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDispatchStatus" runat="server" Text='<%#Eval("DispatchStatus")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Delivery Status" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDeliveryStatus" runat="server" Text='<%#Eval("DeliveryStatus")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExportExcel" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>
