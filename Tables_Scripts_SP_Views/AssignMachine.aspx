<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="AssignMachine.aspx.cs" Inherits="AssignMachine" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .operator-card {
            display: inline-block;
            padding: 12px 18px;
            margin: 6px;
            border: 2px solid #ddd;
            border-radius: 8px;
            cursor: pointer;
            background: #fff;
            font-weight: 600;
            transition: .2s;
        }

            .operator-card:hover {
                border-color: #2F6BFF;
            }

        .operator-selected {
            background: #2F6BFF !important;
            color: #fff !important;
            border-color: #2F6BFF !important;
        }


        .stages-container {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 10px;
        }

        .stage-card {
            flex: 1 1 30%; /* takes 1/3 of row when 3 stages exist */
            min-width: 220px; /* stretches to fill row when fewer stages exist */
            border: 1px solid #ddd;
            border-radius: 8px;
            background: #fff;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        }

        .stage-header {
            background: #1a48a1;
            color: #fff;
            font-weight: 900;
            padding: 17px 14px;
            border-radius: 8px 8px 0 0;
            text-align: center;
        }

        .machine-list {
            padding: 24px 12px;
        }

        .machine-item {
            padding: 10px 17px;
            margin-bottom: 11px;
            background: #f4f6f8;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            font-size: 18px;
        }

            .machine-item:last-child {
                margin-bottom: 18px;
            }

        .machine-item {
            cursor: pointer;
            transition: background .2s ease, color .2s ease;
            user-select: none;
        }

        .machine-assigned {
            background: #1FA97A !important;
            color: #fff !important;
        }

        .machine-free {
            background: #E5566D !important;
            color: #fff !important;
        }

        .section-title {
            font-weight: 700;
            font-size: 18px;
            margin: 10px 0;
        }
    </style>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        var selectedOperatorId = null;
        var selectedOperatorName = null;

        function selectOperator(elem, operatorId, operatorName) {
            $(".operator-card").removeClass("operator-selected");
            $(elem).addClass("operator-selected");

            selectedOperatorId = operatorId;
            selectedOperatorName = operatorName;
        }

        function assignMachine(elem, force) {
            if (!selectedOperatorId) {
                alert("Please select an operator first.");
                return;
            }

            var machineId = $(elem).data("machineid");
            var stageId = $(elem).data("stageid");
            var isBusy = String($(elem).data("busy")).toLowerCase() === "true";
            var busyOperator = $(elem).data("busyoperator");

            if (isBusy && !force) {
                var confirmMsg = "This machine is currently used by " + busyOperator +
                    ". Do you want to log them out and assign " + selectedOperatorName + " instead?";

                if (confirm(confirmMsg)) {
                    assignMachine(elem, true);
                }
                return;
            }

            if (!isBusy && !force) {
                var confirmAssign = confirm("Assign " + selectedOperatorName + " to this machine?");
                if (!confirmAssign) return;
            }

            if ($(elem).hasClass("machine-processing")) return;
            $(elem).addClass("machine-processing");

            $.ajax({
                type: "POST",
                url: "AssignMachine.aspx/AssignOperatorToMachine",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    operatorId: selectedOperatorId,
                    machineId: machineId,
                    stageId: stageId,
                    force: force === true
                }),
                success: function (response) {
                    var result = response.d;

                    if (!result.Success) {
                        alert(result.Message || "Failed to assign machine.");
                        $(elem).removeClass("machine-processing");
                        return;
                    }

                    alert("Machine assigned successfully.");
                    window.location.href = window.location.href;
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("Something went wrong.");
                    $(elem).removeClass("machine-processing");
                }
            });
        }

        function unassignMachine(elem, machineId) {
            var confirmUnassign = confirm("Remove the current operator from this machine?");
            if (!confirmUnassign) return;

            $.ajax({
                type: "POST",
                url: "AssignMachine.aspx/UnassignMachine",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ machineId: machineId }),
                success: function (response) {
                    var result = response.d;

                    if (!result.Success) {
                        alert(result.Message || "Failed to unassign.");
                        return;
                    }

                    window.location.href = window.location.href;
                },
                error: function () {
                    alert("Something went wrong.");
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="section-title">Step 1: Select Operator</div>
            <div id="operatorsContainer">
                <asp:Repeater ID="rptOperators" runat="server">
                    <ItemTemplate>
                        <div class="operator-card"
                            onclick="selectOperator(this, '<%# Eval("ID") %>', '<%# Eval("FullName") %>')">
                            <%# Eval("FullName") %>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <br />
            <div class="section-title">Step 2: Select Machine to Assign</div>
            <div class="stages-container">
                <asp:Repeater ID="rptStages" runat="server" OnItemDataBound="rptStages_ItemDataBound">
                    <ItemTemplate>
                        <div class="stage-card">
                            <div class="stage-header">
                                <%# Eval("StageName") %>
                            </div>
                            <div class="machine-list">
                                <asp:Repeater ID="rptMachines" runat="server">
                                    <ItemTemplate>
                                        <div class="machine-item <%# Convert.ToBoolean(Eval("IsAssigned")) ? "machine-assigned" : "machine-free" %>"
                                            data-machineid='<%# Eval("MachineId") %>'
                                            data-stageid='<%# Eval("StageId") %>'
                                            data-busy='<%# Eval("IsAssigned").ToString().ToLower() %>'
                                            data-busyoperator='<%# Eval("OperatorName") %>'
                                            onclick="assignMachine(this)"
                                            title='<%# string.IsNullOrEmpty(Eval("OperatorName").ToString()) ? "Unassigned" : "Assigned to " + Eval("OperatorName") %>'>
                                            <%# Eval("MachineName") %>
                                            <%# string.IsNullOrEmpty(Eval("OperatorName").ToString()) ? "" : " (" + Eval("OperatorName") + ")" %>
                                            <div style='<%# Convert.ToBoolean(Eval("IsAssigned")) ? "": "display:none;" %>'>
                                                <br />
                                                <a href="javascript:void(0);"
                                                    onclick='event.stopPropagation(); unassignMachine(this,"<%# Eval("MachineId") %>")'>Remove
                                                </a>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
