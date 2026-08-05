<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="ProfilePage.aspx.cs" Inherits="ProfilePage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .pf-page-wrap {
            padding: 32px 12px 48px;
        }

        .pf-card {
            border: 3px solid #325bb5;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(13, 40, 80, 0.10);
            background: #fff;
        }

        .pf-header {
            position: relative;
            background: linear-gradient(135deg, #0d6efd 0%, #2c5fd6 55%, #c98a3e 130%);
            padding: 34px 24px 52px;
            text-align: center;
            color: #fff;
        }



            .pf-header h3 {
                margin: 0;
                font-weight: 700;
                font-size: 1.4rem;
                letter-spacing: 0.01em;
            }

            .pf-header p {
                margin: 4px 0 0;
                font-size: 0.9rem;
                opacity: 0.9;
            }

        .pf-body {
            padding: 54px 28px 30px;
        }

        .pf-field {
            margin-bottom: 20px;
        }

        .pf-label {
            display: block;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #6b7280;
            margin-bottom: 6px;
        }

        .pf-input-wrap {
            position: relative;
        }

        .pf-input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #9aa4b2;
            font-size: 1rem;
            pointer-events: none;
        }

        .pf-input.form-control {
            height: 46px;
            padding-left: 40px;
            border-radius: 10px;
            border: 1px solid #dfe3ea;
            background: #f8fafc;
            font-size: 0.95rem;
            transition: border-color 0.15s ease, box-shadow 0.15s ease, background 0.15s ease;
        }

            .pf-input.form-control:focus {
                border-color: #0d6efd;
                background: #fff;
                box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.15);
            }

        .pf-password-wrap .pf-input.form-control {
            padding-right: 44px;
        }

        .pf-eye-btn {
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            width: 42px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            border: none;
            padding: 0;
            margin: 0;
            cursor: pointer;
            color: #8a93a1;
            font-size: 1.05rem;
            min-width: 40px;
            min-height: 40px;
        }

            .pf-eye-btn:hover,
            .pf-eye-btn:focus {
                color: #0d6efd;
                outline: none;
            }

            .pf-eye-btn:focus-visible {
                outline: 2px solid #0d6efd;
                outline-offset: 2px;
                border-radius: 4px;
            }

        .pf-validation {
            display: block;
            font-size: 0.78rem;
            margin-top: 5px;
        }

        .pf-save-btn {
            height: 45px;
            border: none;
            border-radius: 10px;
            font-weight: 400;
            letter-spacing: 0.08em;
            background: linear-gradient(135deg, #0d6efd, #2c5fd6);
            box-shadow: 0px 0px 16px 6px rgba(13, 110, 253, 0.28);
            transition: transform 0.12s ease, box-shadow 0.12s ease;
        }

            .pf-save-btn:hover {
                transform: translateY(-1px);
                box-shadow: 0 8px 20px rgba(13, 110, 253, 0.34);
            }

            .pf-save-btn:active {
                transform: translateY(0);
            }

        .pf-message {
            display: inline-block;
            margin-top: 14px;
            padding: 8px 16px;
            border-radius: 999px;
            background: #f1f5f9;
            font-size: 0.88rem;
        }

        /* ---- Responsive tuning for small phones ---- */
        @media (max-width: 480px) {
            .pf-page-wrap {
                padding: 16px 6px 32px;
            }

            .pf-header {
                padding: 26px 16px 46px;
            }

            .pf-body {
                padding: 48px 18px 24px;
            }


            .pf-header h3 {
                font-size: 1.2rem;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="pf-page-wrap">
                <div class="row justify-content-center">
                    <div class="col-lg-6 col-md-8 col-sm-10">
                        <div class="pf-card">

                            <div class="pf-header">
                                <h3>My Profile</h3>
                                <p>Update your account details below</p>
                            </div>

                            <div class="pf-body">
                                <div class="row">
                                    <div class="col-md-6 pf-field">
                                        <label class="pf-label">Full Name</label>
                                        <div class="pf-input-wrap">
                                            <i class="bi bi-person pf-input-icon"></i>
                                            <asp:TextBox ID="txtName" runat="server" ValidationGroup="001" CssClass="form-control pf-input"></asp:TextBox>
                                        </div>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" Display="Dynamic" CssClass="pf-validation" ErrorMessage="Please Enter Name"
                                            ControlToValidate="txtName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                                    </div>

                                    <div class="col-md-6 pf-field">
                                        <label class="pf-label">Mobile Number</label>
                                        <div class="pf-input-wrap">
                                            <i class="bi bi-telephone pf-input-icon"></i>
                                            <asp:TextBox ID="txtMobile" runat="server" CssClass="form-control pf-input"></asp:TextBox>
                                        </div>
                                    </div>

                                    <div class="col-md-6 pf-field">
                                        <label class="pf-label">Email ID</label>
                                        <div class="pf-input-wrap">
                                            <i class="bi bi-envelope pf-input-icon"></i>
                                            <asp:TextBox ID="txtUsername" runat="server" ValidationGroup="001" CssClass="form-control pf-input"
                                                AutoPostBack="true" OnTextChanged="txtEmail_TextChanged"></asp:TextBox>
                                        </div>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" Display="Dynamic" CssClass="pf-validation" ErrorMessage="Please Enter EMail ID "
                                            ControlToValidate="txtUsername" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>

                                        <asp:RegularExpressionValidator
                                            ID="revEmail"
                                            runat="server"
                                            ControlToValidate="txtUsername"
                                            ValidationExpression="^\w+([-.+']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
                                            ErrorMessage="Enter a valid email address."
                                            CssClass="pf-validation text-danger"
                                            Display="Dynamic">
                                        </asp:RegularExpressionValidator>

                                        <asp:CustomValidator
                                            ID="cvEmail"
                                            runat="server"
                                            ControlToValidate="txtUsername"
                                            ErrorMessage="Email already exists."
                                            CssClass="pf-validation text-danger"
                                            Display="Dynamic"
                                            EnableClientScript="false">
                                        </asp:CustomValidator>
                                    </div>

                                    <div class="col-md-6 pf-field">
                                        <label class="pf-label">Password</label>
                                        <div class="pf-input-wrap pf-password-wrap">
                                            <i class="bi bi-lock pf-input-icon"></i>
                                            <asp:TextBox ID="txtPassword" runat="server" ValidationGroup="001" CssClass="form-control pf-input" TextMode="Password"></asp:TextBox>
                                            <button type="button" class="pf-eye-btn" aria-label="Show password" aria-pressed="false" data-target="<%= txtPassword.ClientID %>">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" Display="Dynamic" CssClass="pf-validation" ErrorMessage="Please Enter Password"
                                            ControlToValidate="txtPassword" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                                    </div>


                                    <div class="col-md-12 mt-2">
                                        <center>
                                            <asp:Button
                                                ID="btnUpdate"
                                                runat="server"
                                                Text="Update Profile"
                                                ValidationGroup="001"
                                                CausesValidation="true"
                                                CssClass="btn btn-primary pf-save-btn "
                                                OnClick="btnUpdate_Click" />
                                        </center>
                                    </div>

                                    <div class="col-md-12 text-center">
                                        <asp:Label
                                            ID="lblMessage"
                                            runat="server"
                                            CssClass="pf-message"
                                            ForeColor="Green"
                                            Font-Bold="true"></asp:Label>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script type="text/javascript">
        // Event delegation on document so this survives UpdatePanel async postbacks
        // (the button HTML re-renders inside the UpdatePanel, but the listener stays bound).
        $(document).on("click", ".pf-eye-btn", function () {
            var btn = $(this);
            var targetId = btn.attr("data-target");
            var input = document.getElementById(targetId);
            if (!input) { return; }

            var icon = btn.find("i");
            var isHidden = input.type === "password";

            input.type = isHidden ? "text" : "password";
            btn.attr("aria-pressed", isHidden ? "true" : "false");
            btn.attr("aria-label", isHidden ? "Hide password" : "Show password");

            icon.toggleClass("bi-eye", !isHidden);
            icon.toggleClass("bi-eye-slash", isHidden);

            input.focus();
            var pos = input.value.length;
            if (input.setSelectionRange) {
                input.setSelectionRange(pos, pos);
            }
        });
    </script>
</asp:Content>
