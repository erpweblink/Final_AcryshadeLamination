<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="AdsDetails.aspx.cs" Inherits="AdsDetails" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <style>
        .spncls {
            color: red;
        }

        .question-row {
            margin-bottom: 10px;
        }

        .remove-row-btn {
            cursor: pointer;
        }

        .section-box {
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 12px;
            margin-bottom: 15px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b><span id="formHeaderText">Ad Form</span></b></h3>
                </div>
                <div class="card-body">

                    <div class="row">
                        <center>
                            <div class="col-md-6 col-12 mb-3">
                                <asp:Label ID="lblDepartment" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Form ID:</asp:Label>
                                <asp:TextBox ID="txtFormID" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Form ID"
                                    ControlToValidate="txtFormID" ForeColor="Red" SetFocusOnError="true" InitialValue="" ValidationGroup="001"></asp:RequiredFieldValidator>
                            </div>
                        </center>
                    </div>

                    <div class="row">
                        <!-- Personal Details Section -->
                        <div class="col-md-6 col-12 mb-3">
                            <div class="section-box">
                                <h4>Personal Details</h4>

                                <div id="personalRowsContainer">
                                    <!-- Rows get added here dynamically via JS -->
                                </div>

                                <div class="mb-2">
                                    <button type="button" id="btnAddPersonalRow" class="btn btn-outline-primary btn-sm">+ Add Personal Field</button>
                                </div>
                            </div>
                        </div>

                        <!-- Other Details Section -->
                        <div class="col-md-6 col-12 mb-3">
                            <div class="section-box">
                                <h4>Other Details</h4>

                                <div id="otherRowsContainer">
                                    <!-- Rows get added here dynamically via JS -->
                                </div>

                                <div class="mb-2">
                                    <button type="button" id="btnAddOtherRow" class="btn btn-outline-primary btn-sm">+ Add Question</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Hidden fields carry state back on postback -->
                    <asp:HiddenField ID="hdnPersonalDetails" runat="server" />
                    <asp:HiddenField ID="hdnOtherDetails" runat="server" />
                    <asp:HiddenField ID="hdnEditID" runat="server" Value="0" />

                    <center>
                        <div>
                            <asp:LinkButton ID="btnsave" ValidationGroup="001" class="btn btn-outline-success me-3 btn-sm" runat="server" Text="Save"
                                OnClick="btn_save_Click" OnClientClick="return prepareFormDetails();"></asp:LinkButton>
                            <button type="button" id="btnCancelEdit" class="btn btn-outline-danger me-3 btn-sm" style="display: none;" onclick="cancelEdit();">Cancel Edit</button>
                        </div>
                    </center>
                    <br />
                    <br />
                    <h2>Form Details</h2>
                    <hr />
                    <div class="table-responsive">
                        <asp:GridView ID="GVCompany" runat="server" DataKeyNames="ID" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#2d6be0"
                            HeaderStyle-HorizontalAlign="Center" HeaderStyle-Font-Bold="true" AutoGenerateColumns="false" OnRowCommand="GVCompany_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.No." HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Form ID" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <span class="form-id-tooltip"
                                            data-bs-toggle="tooltip"
                                            data-bs-html="true"
                                            data-bs-placement="top"
                                            title='<%#GetFormDetailsTooltip(Eval("PersonalDetails"), Eval("OtherDetails"))%>'>
                                            <asp:Label ID="lblFormID" runat="server"
                                                Text='<%#Eval("FormID").ToString()%>'></asp:Label>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" ToolTip="Edit Form" CommandName="RowEdit"
                                            CommandArgument='<%#Eval("ID")%>' CssClass="btn btn-outline-primary btn-sm me-2"><i class="bi bi-pencil-fill"></i></asp:LinkButton>
                                        <asp:LinkButton ID="btnDelete" runat="server" ToolTip="Delete Role" CommandName="RowDelete" Enabled="false" OnClientClick="Javascript:return confirm('This button is not activated')" CommandArgument='<%#Eval("ID")%>' CssClass="btn btn-outline-danger  btn-sm"><i class='bi bi-trash3-fill'></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script>
        var personalRowCounter = 0;
        var otherRowCounter = 0;

        function initFormIdTooltips() {
            $('.form-id-tooltip[data-bs-toggle="tooltip"]').each(function () {
                var existingTooltip = bootstrap.Tooltip.getInstance(this);
                if (existingTooltip) {
                    existingTooltip.dispose();
                }
            });

            var tooltipTriggerList = [].slice.call(document.querySelectorAll('.form-id-tooltip[data-bs-toggle="tooltip"]'));
            tooltipTriggerList.forEach(function (tooltipTriggerEl) {
                new bootstrap.Tooltip(tooltipTriggerEl);
            });
        }

        function ensureDefaultRows() {
            if ($("#personalRowsContainer").children().length === 0) {
                addPersonalRow();
            }
            if ($("#otherRowsContainer").children().length === 0) {
                addOtherRow();
            }
        }

        function initPageBehavior() {
            initFormIdTooltips();
            ensureDefaultRows();
        }

        $(document).ready(function () {
            initPageBehavior();
        });

        // Re-run after every async postback (Save, Edit, Delete — any UpdatePanel refresh)
        if (typeof (Sys) !== "undefined" && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                initPageBehavior();
            });
        }

        function escapeHtml(str) {
            return $('<div>').text(str).html();
        }

        // ---------- Personal Details rows ----------
        function addPersonalRow(existingValue) {
            personalRowCounter++;
            var rowId = "prow_" + personalRowCounter;

            var rowHtml =
                '<div class="row question-row" id="' + rowId + '">' +
                '<div class="col-8">' +
                '<input type="text" class="form-control personal-input" placeholder="e.g. Full Name, Email, City" value="' + (existingValue ? escapeHtml(existingValue) : '') + '" />' +
                '</div>' +
                '<div class="col-4">' +
                '<button type="button" class="btn btn-outline-danger remove-row-btn btn-sm" onclick="removeRow(\'' + rowId + '\')">Remove</button>' +
                '</div>' +
                '</div>';

            $("#personalRowsContainer").append(rowHtml);
        }

        // ---------- Other Details rows ----------
        function addOtherRow(existingValue) {
            otherRowCounter++;
            var rowId = "orow_" + otherRowCounter;

            var rowHtml =
                '<div class="row question-row" id="' + rowId + '">' +
                '<div class="col-8">' +
                '<input type="text" class="form-control other-input" placeholder="Enter question" value="' + (existingValue ? escapeHtml(existingValue) : '') + '" />' +
                '</div>' +
                '<div class="col-4">' +
                '<button type="button" class="btn btn-outline-danger remove-row-btn btn-sm" onclick="removeRow(\'' + rowId + '\')">Remove</button>' +
                '</div>' +
                '</div>';

            $("#otherRowsContainer").append(rowHtml);
        }

        function removeRow(rowId) {
            $("#" + rowId).remove();
        }

        function clearAllRows() {
            $("#personalRowsContainer").empty();
            $("#otherRowsContainer").empty();
            personalRowCounter = 0;
            otherRowCounter = 0;
        }

        // Delegated binding — survives UpdatePanel DOM replacement
        $(document).on("click", "#btnAddPersonalRow", function () {
            addPersonalRow();
        });

        $(document).on("click", "#btnAddOtherRow", function () {
            addOtherRow();
        });

        function prepareFormDetails() {
            var personalFields = [];
            var otherFields = [];

            $(".personal-input").each(function () {
                var val = $(this).val();
                if (val && val.trim() !== "") {
                    personalFields.push(val.trim());
                }
            });

            $(".other-input").each(function () {
                var val = $(this).val();
                if (val && val.trim() !== "") {
                    otherFields.push(val.trim());
                }
            });

            if (personalFields.length === 0 && otherFields.length === 0) {
                alert("Please add at least one field.");
                return false;
            }

            $("#<%= hdnPersonalDetails.ClientID %>").val(JSON.stringify(personalFields));
            $("#<%= hdnOtherDetails.ClientID %>").val(JSON.stringify(otherFields));

            return true;
        }

        // Called from server-side after RowEdit postback, via RegisterStartupScript
        function loadEditData(formId, personalJson, otherJson) {
            $("#<%= txtFormID.ClientID %>").val(formId);

            clearAllRows();

            var personalFields = JSON.parse(personalJson);
            for (var i = 0; i < personalFields.length; i++) {
                addPersonalRow(personalFields[i]);
            }

            var otherFields = JSON.parse(otherJson);
            for (var j = 0; j < otherFields.length; j++) {
                addOtherRow(otherFields[j]);
            }

            $("#formHeaderText").text("Edit Form");
            $("#btnCancelEdit").show();

            $('html, body').animate({ scrollTop: $("#formHeaderText").offset().top - 20 }, 300);
        }

        function cancelEdit() {
            $("#<%= txtFormID.ClientID %>").val("");
            $("#<%= hdnEditID.ClientID %>").val("0");
            clearAllRows();
            addPersonalRow();
            addOtherRow();
            $("#formHeaderText").text("Add Form");
            $("#btnCancelEdit").hide();
        }
    </script>
</asp:Content>
