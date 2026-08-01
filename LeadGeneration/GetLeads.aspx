<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="GetLeads.aspx.cs" Inherits="GetLeads" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

    <div class="card">
        <div class="card-body">
            <button type="button" id="btnSyncLeads" class="btn btn-primary">Sync Leads Now</button>
            <div id="syncStatus" class="mt-3"></div>
        </div>
    </div>

    <script>
        $(document).on("click", "#btnSyncLeads", function () {
            $("#syncStatus").text("Syncing leads, please wait...");

            PageMethods.GenerateLongToken(onSyncSuccess, onSyncError);
        });

        function onSyncSuccess(result) {
            $("#syncStatus").text(result);
        }

        function onSyncError(error) {
            $("#syncStatus").text("Error: " + error.get_message());
        }
 </script>
</asp:Content>
