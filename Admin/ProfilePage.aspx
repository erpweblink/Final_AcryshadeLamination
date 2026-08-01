<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="ProfilePage.aspx.cs" Inherits="ProfilePage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <style>
        .title {
            font-weight: 600;
            color: #0d6efd;
            margin-bottom: 20px;
        }

        .btn-save {
            width: 100%;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="row justify-content-center">
                <div class="col-lg-6 col-md-8 col-sm-10">
                    <div class="card shadow border-0">
                        <div class="card-header">
                            <h3 class="text-center title">My Profile</h3>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label>Full Name</label>
                                    <asp:TextBox ID="txtName"
                                        runat="server" ValidationGroup="001"
                                        CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Enter Name"
                                        ControlToValidate="txtName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label>Email ID</label>
                                    <asp:TextBox ID="txtUsername"
                                        runat="server" ValidationGroup="001"
                                        CssClass="form-control" AutoPostBack="true"
                                        OnTextChanged="txtEmail_TextChanged"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ErrorMessage="Please Enter EMail ID "
                                        ControlToValidate="txtUsername" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>


                                    <asp:RegularExpressionValidator
                                        ID="revEmail"
                                        runat="server"
                                        ControlToValidate="txtUsername"
                                        ValidationExpression="^\w+([-.+']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
                                        ErrorMessage="Enter a valid email address."
                                        CssClass="text-danger"
                                        Display="Dynamic">
    </asp:RegularExpressionValidator>

                                    <asp:CustomValidator
                                        ID="cvEmail"
                                        runat="server"
                                        ControlToValidate="txtUsername"
                                        ErrorMessage="Email already exists."
                                        CssClass="text-danger"
                                        Display="Dynamic"
                                        EnableClientScript="false">
    </asp:CustomValidator>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label>Password</label>
                                    <asp:TextBox ID="txtPassword"
                                        runat="server" ValidationGroup="001"
                                        CssClass="form-control"></asp:TextBox>

                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Password"
                                        ControlToValidate="txtPassword" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>

                                </div>

                                <div class="col-md-6 mb-3">
                                    <label>Mobile Number</label>
                                    <asp:TextBox ID="txtMobile"
                                        runat="server"
                                        CssClass="form-control"></asp:TextBox>
                                </div>

                                <div class="col-md-12 mt-3">

                                    <asp:Button
                                        ID="btnUpdate"
                                        runat="server"
                                        Text="Update Profile"
                                        ValidationGroup="001"
                                        CausesValidation="true"
                                        CssClass="btn btn-primary btn-save"
                                        OnClick="btnUpdate_Click" />

                                </div>

                                <div class="col-md-12 mt-3 text-center">

                                    <asp:Label
                                        ID="lblMessage"
                                        runat="server"
                                        ForeColor="Green"
                                        Font-Bold="true"></asp:Label>

                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
