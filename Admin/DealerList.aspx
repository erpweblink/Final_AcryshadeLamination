<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="DealerList.aspx.cs" Inherits="DealerList" %>


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

        /* Toggle switch */
        .switch {
            position: relative;
            display: inline-block;
            width: 36px;
            height: 18px;
        }

            .switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }

        .slider {
            position: absolute;
            cursor: pointer;
            background-color: #ccc;
            transition: .4s;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
        }

            .slider:before {
                position: absolute;
                content: "";
                height: 14px;
                width: 14px;
                left: 2px;
                bottom: 2px;
                background: white;
                transition: .4s;
            }

        input:checked + .slider {
            background-color: #28a745;
        }

            input:checked + .slider:before {
                transform: translateX(18px);
            }

        .slider.round {
            border-radius: 34px;
        }

            .slider.round:before {
                border-radius: 50%;
            }

        /* Responsive adjustments */
        @media (max-width:768px) {

            #UserModal .modal-dialog {
                max-width: 95%;
            }

            .user-table th,
            .user-table td {
                font-size: 12px;
                padding: 6px;
            }
        }

        .btn-Excel {
            background-color: #28a745; /* Green */
            color: #fff;
            border: 1px solid #28a745;
            border-radius: 4px;
            padding: 8px 16px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

            .btn-Excel:hover {
                background-color: #218838;
                border-color: #1e7e34;
                color: #fff;
            }

            .btn-Excel:focus {
                outline: none;
                box-shadow: 0 0 5px rgba(40, 167, 69, 0.5);
            }
    </style>


    <script type="text/javascript">
        function updateStatus(element) {
            var userId = element.getAttribute("data-id");
            var value = element.checked;

            $.ajax({
                type: "POST",
                url: "DealerList.aspx/UpdateUserSetting",
                data: JSON.stringify({
                    id: userId,
                    val: value
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    //console.log("Updated Successfully");
                    window.location.reload();
                },
                error: function (error) {
                    //console.log(error);
                }
            });

        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-column flex-md-row justify-content-between align-items-center">
                    <h3 class="m-0 mb-3 mb-md-0"><b>Dealer List</b></h3>

                    <div class="d-flex flex-wrap justify-content-end gap-2">
                        <asp:Button ID="btnCreate"
                            runat="server"
                            CssClass="btn btn-outline-primary"
                            Text="Create"
                            Font-Bold="true"
                            CausesValidation="false"
                            OnClick="btnCreate_Click" />

                        <asp:Button ID="btnexportoexcel"
                            runat="server"
                            Text="Export to Excel"
                            CssClass="btn btn-outline-success"
                            OnClick="btnexportoexcel_Click" />
                    </div>
                </div>
                <div class="card-body">
                    <div class="row align-items-end">
                        <div class="col-md-3">
                            <asp:Label ID="Label1" runat="server" Font-Bold="true" CssClass="form-label">Search:</asp:Label>
                            <asp:TextBox ID="txtcompanyname" CssClass="form-control" runat="server" Width="100%" autocomplete="off"></asp:TextBox>
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
                                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                                    <asp:ListItem Text="10" Value="10" Selected="True" />
                                    <asp:ListItem Text="50" Value="50" />
                                    <asp:ListItem Text="All" Value="0" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>

                    <hr />
                    <div class="table-responsive">
                        <asp:GridView ID="GVCompany" runat="server" DataKeyNames="ID" OnRowDataBound="GVCompany_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#2d6be0"
                            HeaderStyle-Font-Bold="true" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="GVCompany_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.No." HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblUserCode" runat="server" Text='<%#Eval("UserCode")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblFullName" runat="server" Text='<%#Eval("FullName")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Name" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="d-none" ItemStyle-CssClass="d-none">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCompanyName" runat="server" Text='<%#Eval("CompanyName")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Email Id" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblEmail" runat="server" Text='<%#Eval("EmailId")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Password" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblLoginPass" runat="server" Text='<%#Eval("LoginPass")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Activate" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <label class="switch">
                                            <input type="checkbox" class="ipCheckToggle" data-id='<%# Eval("ID") %>' onchange="updateStatus(this)"
                                                <%# (Eval("IsActivate") != DBNull.Value && Convert.ToBoolean(Eval("IsActivate"))) ? "checked='checked'" : "" %> />
                                            <span class="slider round"></span>
                                        </label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="ACTION" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" ToolTip="Edit Company" CommandName="RowEdit" CommandArgument='<%#Eval("ID")%>' CssClass="btn btn-outline-info  btn-sm"><i class='bi bi-pencil'></i></asp:LinkButton>
                                        <asp:LinkButton ID="btnDelete" runat="server" ToolTip="Delete Company" CommandName="RowDelete" OnClientClick="Javascript:return confirm('Are you sure to Delete?')" CommandArgument='<%#Eval("ID")%>' CssClass="btn btn-outline-danger  btn-sm d-none"><i class='bi bi-trash3-fill'></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnexportoexcel" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>
