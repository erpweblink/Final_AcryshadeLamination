<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MachineBreakdown.aspx.cs" Inherits="Reports_MachineBreakdown" MasterPageFile="~/MasterPage.master" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Machine BreakDown Report</b></h3>
                    <asp:Button ID="btnExportExcel" runat="server" Text="Export To Excel"
                        CssClass="btn btn-outline-success" OnClick="btnExportExcel_Click" />
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <br />
                        <asp:GridView ID="GvMachineBreak" runat="server"
                            AutoGenerateColumns="False" HeaderStyle-BackColor="#2d6be0"
                            HeaderStyle-Font-Bold="true" HeaderStyle-HorizontalAlign="Center"
                            EmptyDataText="Record Not Found" CssClass="table table-bordered table-striped">
                            <Columns>
                                <asp:BoundField DataField="MachineName" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center"  HeaderText="MachineName" />
                                <asp:BoundField DataField="OldRunningHR" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center"  HeaderText="Old RunningHR" />
                                <asp:BoundField DataField="CurrentRunningHR" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center"  HeaderText="Current RunningHR" />
                                <asp:BoundField DataField="ExtraHours" HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center"  HeaderText="Extra Hours" />
                                <asp:BoundField
                                    DataField="ExtraWorkDate"
                                    HeaderText="Extra Work Date"  HeaderStyle-ForeColor="White" ItemStyle-HorizontalAlign="Center" 
                                    DataFormatString="{0:dd-MM-yyyy}"
                                    HtmlEncode="false" />
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
