<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="WoProductionS2.aspx.cs" Inherits="WoProductionS2" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <style type="text/css">
        /* ================= TABLE BASE STYLE (MATCH GRIDVIEW) ================= */
        table {
            width: 100%;
            border-collapse: collapse;
        }

            /* HEADER STYLE (same as HeaderStyle-BackColor="#5b78b1") */
            table tr:first-child th {
                background: #2d6be0;
                color: white;
                font-weight: bold;
                text-align: center;
                padding: 10px;
                border: 1px solid #ddd;
            }

            /* CELL STYLE */
            table td {
                border: 1px solid #ddd;
                padding: 8px;
                text-align: center;
                vertical-align: middle;
            }

            /* HOVER LIKE Bootstrap table-hover */
            table tr:hover {
                background: #f5f5f5;
            }

        /* MACHINE BADGE STYLE */
        .badge {
            padding: 5px 10px;
            border-radius: 5px;
            font-weight: bold;
            color: white;
        }

        .bg-info {
            background: #17a2b8;
        }

        .bg-danger {
            background: #dc3545;
        }

        .bg-warning {
            background: #ffc107;
            color: black;
        }

        .bg-success {
            background: #28a745;
        }

        /* BUTTON STYLE LIKE bootstrap-outline-primary */
        button {
            padding: 3px 8px;
            margin: 2px;
            cursor: pointer;
            border: 1px solid #007bff;
            background: transparent;
            color: #007bff;
            border-radius: 3px;
            font-size: 15px;
        }

            button:hover {
                background: #007bff;
                color: white;
            }

        /* REMOVE BUTTON BORDER FOR + / - SMALL */
        .btnMinus, .btnPlus {
            width: 24px;
            height: 24px;
            padding: 0;
            line-height: 20px;
        }

        /* INPUT STYLE LIKE ASP.NET */
        input[type="checkbox"], input[type="radio"] {
            transform: scale(1.1);
        }

        /* CARD HEADER STYLE MATCH */
        h3 {
            font-weight: 700;
        }

        /* DETAIL ROW BACKGROUND */
        .detail-row td {
            background: #fafafa;
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

        /*CSS fro Image Pop UP*/
        .product-image-preview {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border: 1px solid #ddd;
            border-radius: 8px;
            cursor: pointer;
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

        /*END*/
    </style>
    <script type="text/javascript">
        var AssignWorkOrders = [];
        var operatorData = [];
        var qtyUpdating = {};
        var isMachineActive = true;
        var hasAssignedOperator = false;
        $(function () {
            loadOperatorDetails();
        });

        function loadMachine() {
            $.ajax({
                type: "POST",
                url: "WoProductionS2.aspx/GetMachines",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var rows = JSON.parse(response.d);
                    var ddl = $("#ddlMachine");

                    ddl.empty();
                    ddl.append("<option value=''>-Select Machine-</option>");

                    $.each(rows, function (i, machine) {
                        ddl.append(
                            "<option value='" + machine.ID + "'>" +
                            machine.MachineName +
                            "</option>"
                        );
                    });
                },
                error: function (xhr, status, error) {
                    console.log(error);
                    alert("Error loading Machine data");
                }
            });
        }

        function loadOperatorDetails() {
            debugger;
            $.ajax({
                type: "POST",
                url: "WoProductionS2.aspx/GetOperatorDetails",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var role = response.d.Role;
                    operatorData = JSON.parse(response.d.Data);

                    $("#ddlMachine").empty();
                    if (role === "Operator") {

                        if (operatorData.length > 0) {
                            currentMachineId = operatorData[0].MachineID;

                            $("#ddlMachine").append(
                                "<option value='" + currentMachineId + "' selected>" +
                                operatorData[0].MachineName +
                                "</option>"
                            );

                            $("#ddlMachine").prop("disabled", true);


                            machineChanged(currentMachineId);
                        }
                        else {

                            $("#woContainer").html(
                                "<div class='alert alert-info mb-0'>You are not assigned to this Stage.</div>"
                            );

                            return;
                        }
                    } else {
                        $("#ddlMachine").prop("disabled", false);
                        loadMachine(); // admin full list
                    }
                }
            });
        }

        function machineChanged(machineId) {

            machineId = machineId || $("#ddlMachine").val();

            if (!machineId) {
                window.location.href = window.location.href;
                return;
            }


            currentMachineId = machineId;

            // show operator info
            var operator = operatorData.find(x => x.MachineID == machineId);

            if (!operator) {
                // NEW: No operator assigned to this machine
                $("#operatorInfo").html(
                    "<div class='alert alert-warning mb-0'>No operator assigned to this machine.</div>"
                ).show();

                $("#woContainer").html("");
                //return; // stop here — nothing to load, nothing to transfer
            } else {
                hasAssignedOperator = true;

                var html = `
                <div class="row mb-3">
                    <div class="col-md-3">
                        <div class="card p-2">
                            <b>Operator</b><br/>
                            ${operator.OperatorName}
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card p-2">
                            <b>Target Qty</b><br/>
                            ${operator.TargetQty}
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card p-2">
                            <b>Completed Qty</b><br/>
                            ${operator.CompletedQty}
                        </div>
                    </div>
                     <div class="col-md-3">
                          <div class="card p-2 h-100">

                              <label class="form-label"><b>Reason</b></label>
                              <textarea id="txtReason" class="form-control"
                                        rows="2" placeholder="Enter reason..."></textarea>
          
                              <div class="d-flex justify-content-center align-items-center mt-3">
                                  <label class="switch mb-0 me-2">
                                      <input type="checkbox" id="chkMachineActive" checked>
                                      <span class="slider round"></span>
                                  </label>

                                  <span id="machineStatus" class="badge bg-success">
                                      Machine Running
                                  </span>
                              </div>
                                <input type="hidden" id="hdnWorkOrderIDs" />
                          </div>
                     </div>

                </div>`;
                $("#operatorInfo").html(html).show();
                $("#hdnWorkOrderIDs").val(operator.WorkOrderIDs);

                loadMachineStatus(machineId);
            }

            // 🔥 LOAD WORK ORDERS FOR SELECTED MACHINE
            loadWorkOrder(machineId);
        }

        $(document).on("change", "#chkMachineActive", function () {

            var isActive = $(this).is(":checked");
            var reason = $("#txtReason").val().trim();

            // Prevent stop without reason
            if (!isActive && reason === "") {
                alert("Please enter a reason before stopping the machine.");

                $(this).prop("checked", true);
                return;
            }

            if (isActive) {
                reason = "";                 // IMPORTANT
                $("#txtReason").val("");
            }
            updateMachineUI(isActive);

            saveMachineStatus(isActive, reason);
        });

        function updateMachineUI(isActive) {

            if (isActive) {

                $("#machineStatus")
                    .removeClass("bg-danger")
                    .addClass("bg-success")
                    .text("Machine Running");
            }
            else {

                $("#machineStatus")
                    .removeClass("bg-success")
                    .addClass("bg-danger")
                    .text("Machine Stopped");

            }
        }

        function loadMachineStatus(machineId) {

            $.ajax({
                type: "POST",
                url: "WoProductionS2.aspx/GetMachineStatus",
                data: JSON.stringify({ machineId: machineId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var row = response.d;

                    if (row) {
                        isMachineActive = row.IsActive;

                        $("#chkMachineActive").prop("checked", row.IsActive);
                        $("#txtReason").val(row.Reason);

                        updateMachineUI(row.IsActive); // ✅ ADD THIS
                    }
                    else {
                        isMachineActive = true;
                        $("#chkMachineActive").prop("checked", true);
                        $("#txtReason").val("");

                        updateMachineUI(true); // default active
                    }
                }
            });

        }

        function saveMachineStatus(isActive, reason) {

            var workOrderIDs = $("#hdnWorkOrderIDs").val();
            $.ajax({
                type: "POST",
                url: "WoProductionS2.aspx/SaveMachineStatus",
                data: JSON.stringify({
                    machineId: currentMachineId,
                    isActive: isActive,
                    reason: reason,
                    workOrderIDs: workOrderIDs
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var result = response.d;

                    if (result.IsActive === "Success") {

                        isMachineActive = result.Status; // true/false

                        alert("Machine Status Updated successfully..");
                    }
                    else {
                        alert("Failed to update machine status");
                    }
                },
                error: function () {
                    alert("Unable to save machine status.");
                }
            });

        }

        function loadWorkOrder(machineId) {
            $.ajax({
                type: "POST",
                url: "WoProductionS2.aspx/GetAssignWorkOrders",
                data: JSON.stringify({ machineId: machineId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var rows = JSON.parse(response.d);
                    AssignWorkOrders = [];

                    if (!rows || rows.length === 0) {

                        $("#woContainer").html(
                            "<div class='alert alert-info mb-0'>No work orders assigned to this machine.</div>"
                        );

                        return;
                    }

                    var grouped = {};
                    $.each(rows, function (i, row) {
                        if (!grouped[row.ProductionID]) {
                            grouped[row.ProductionID] = {
                                woId: row.ProductionID,
                                rankNo: parseInt(row.RankNo),
                                woNo: row.WorkOrderNo,
                                scheduledDate: row.ScheduledDate || '',
                                customer: row.Dealer,
                                totalSqFeet: 0,
                                totalQty: 0,
                                AllocatedQty: 0,
                                RevertQty: 0,
                                balanceQty: 0,
                                status: "Not Active",
                                details: [],
                                isCompleted: true
                            };
                        }

                        grouped[row.ProductionID].details.push({
                            detailedId: row.DetailedID,
                            product: row.ProductName,
                            size: row.Size,

                            originalQty: parseFloat(row.totQty),
                            originalsqFeet: parseFloat(row.SqFeet || 0),

                            description: row.Description,
                            uploadedImage: row.UploadedImage,

                            allocatedQty: parseFloat(row.AllocatedQty || 0),
                            allocatedSqFeet: parseFloat(row.AllocatedSqFeet || 0),

                            usedQty: parseFloat(row.CompletedQty || 0),
                            usedSqFt: parseFloat(row.CompetedSqFeet || 0),
                            stage2compDate: row.CompletedDate,
                            revertQty: parseFloat(row.PackagingRevertQty || 0)

                        });

                        grouped[row.ProductionID].totalSqFeet += parseFloat(row.SqFeet || 0);
                        grouped[row.ProductionID].totalQty += parseFloat(row.totQty);
                        grouped[row.ProductionID].AllocatedQty += parseFloat(row.AllocatedQty);

                        grouped[row.ProductionID].RevertQty += parseFloat(row.PackagingRevertQty);

                        grouped[row.ProductionID].balanceQty += parseFloat(row.CompletedQty);

                        if (grouped[row.ProductionID].totalQty === grouped[row.ProductionID].balanceQty) {
                            grouped[row.ProductionID].status = 'Completed';
                        } else if (grouped[row.ProductionID].totalQty === grouped[row.ProductionID].AllocatedQty) {
                            grouped[row.ProductionID].status = 'Active';
                        } else if (grouped[row.ProductionID].AllocatedQty !== 0) {
                            grouped[row.ProductionID].status = 'Partially Active';
                        }
                    });

                    $.each(grouped, function (key, value) {
                        // check if ALL items are stage2 completed
                        var allStage2Done = value.details.length > 0 &&
                            value.details.every(function (d) {
                                return d.stage2compDate !== null &&
                                    d.stage2compDate !== "" &&
                                    d.stage2compDate !== undefined;
                            });

                        // ❌ skip fully completed work orders
                        if (!allStage2Done) {
                            AssignWorkOrders.push(value);
                        }
                    });

                    AssignWorkOrders.sort(function (a, b) {
                        return a.rankNo - b.rankNo;
                    });
                    bindTodaysWorkOrders();
                },
                error: function (xhr, status, error) {
                    console.log(error);
                    alert("Error loading Work Orders data");
                }
            });
        }

        function formatDate_ddMMyyyy(dateStr) {

            if (!dateStr) return "";

            var d = new Date(dateStr);

            if (isNaN(d.getTime())) return dateStr;

            var day = ("0" + d.getDate()).slice(-2);
            var month = ("0" + (d.getMonth() + 1)).slice(-2);
            var year = d.getFullYear();

            return day + "-" + month + "-" + year;
        }

        function bindTodaysWorkOrders() {
            var count = 1;
            var html = "<table id='todaystable'>";
            html += "<thead>";
            html += "<tr>";
            html += "<th>Sr.No.</th>";
            html += "<th></th>";
            html += "<th>WO No</th>";
            html += "<th>Scheduled Date</th>";
            html += "<th>Customer</th>";
            html += "<th>Total Sq Feet</th>";
            html += "<th>Total Qty</th>";
            html += "<th>Allocated Qty</th>";
            html += "<th>Completed Qty</th>";
            html += "<th>Revert Qty</th>";
            html += "<th>Status</th>";
            html += "</tr>";
            html += "</thead>";

            html += "<tbody>";
            $.each(AssignWorkOrders, function (i, wo) {

                html += "<tr class='drag-row' data-id='" + wo.woId + "'>";
                html += "<td>" + count++ + "</td>";
                html += "<td><button type='button' onclick='toggleDetails(" + wo.woId + ", this)'>+</button></td>";
                html += "<td style='font-weight:900;color:#f5641d;'>" + wo.woNo + "</td>";
                html += "<td>" + formatDate_ddMMyyyy(wo.scheduledDate) + "</td>";
                html += "<td>" + wo.customer + "</td>";
                html += "<td>" + wo.totalSqFeet + "</td>";
                html += "<td>" + wo.totalQty + "</td>";
                html += "<td>" + wo.AllocatedQty + "</td>";
                html += "<td id='bal_" + wo.woId + "'>" + wo.balanceQty + "</td>";
                html += "<td>" + wo.RevertQty + "</td>";

                var statusColor = "black";
                if (wo.status == "Partially Active" || wo.status == "Active")
                    statusColor = "green";
                else if (wo.status == "Not Active")
                    statusColor = "red";


                html += "<td id='status_" + wo.woId + "' style='font-weight:bold;color:" + statusColor + "'>" +
                    wo.status +
                    "</td>";
                html += "</tr>";

                html += "<tr id='detailRow_" + wo.woId + "' style='display:none'>";
                html += "<td colspan='2'></td>";
                html += "<td colspan='9'>";
                html += "<div id='details_" + wo.woId + "'></div>";
                html += "</td>";
                html += "</tr>";
            });
            html += "</tbody>";
            html += "</table>";

            $("#woContainer").html(html);
        }

        function toggleDetails(id, btn) {

            var row = $("#detailRow_" + id);

            if (row.is(":visible")) {
                row.hide();
                $(btn).text("+");
                return;
            }

            buildDetails(id);
            row.show();
            $(btn).text("-");
        }

        function buildDetails(woId) {
            var wo = AssignWorkOrders.find(x => x.woId == woId);
            var html = "<table>";

            html += "<tr>";
            html += "<th>Product</th>";
            html += "<th>Size</th>";
            html += "<th>Description</th>";
            html += "<th>Image</th>";
            html += "<th>Original SqFt</th>";
            html += "<th>Original Qty</th>";
            html += "<th>Assigned SqFt</th>";
            html += "<th>Assigned Qty</th>";
            html += "<th>Completed Qty</th>";
            html += "<th>Reverted Qty</th>";
            html += "</tr>";

            $.each(wo.details, function (i, item) {
                var image = item.uploadedImage
                    ? item.uploadedImage
                    : 'https://placehold.co/400x400?text=Image';

                html += "<tr>";

                html += "<td>" + item.product + "</td>";
                html += "<td>" + item.size + "</td>";
                html += "<td>" + (item.description || '') + "</td>";

                html += `<td>`;
                if (item.uploadedImage) {
                    html += `<div class="image-hover-container">
                       <img src="${image}"
                            class="product-image-preview"
                            width="45" height="45"
                            style="object-fit:cover; border-radius:4px; cursor:pointer;"
                            onclick="openImage('${image}')" />
                    </div>`;
                } else {
                    html += `No Image`;
                }
                html += `</td>`;

                html += "<td>" + item.originalsqFeet + "</td>";
                html += "<td>" + item.originalQty + "</td>";
                html += "<td>" + item.allocatedSqFeet + "</td>";
                html += "<td>" + item.allocatedQty + "</td>";

                html += "<td>";

                var isActive = (wo.status === "Partially Active" || wo.status == "Active");

                var disableMinus = isActive ? "" : "disabled";
                var disablePlus = isActive ? "" : "disabled";

                html += "<button type='button' " + disableMinus + " onclick='showMinusPanel(" + woId + "," + i + ")'>-</button>";
                html += " <span id='uq_" + woId + "_" + i + "'>" + item.usedQty + "</span> ";
                html += "<button type='button'  id='plus_" + woId + "_" + i + "' " + disablePlus + " onclick='changeQty(" + woId + "," + i + ",1,false,false,\"No\")'>+</button>";
                html += "</td>";

                html += "<td>" + item.revertQty + "</td>";

                html += "</tr>";

                html += "<tr class='minusPanel' id='minusPanel_" + woId + "_" + i + "' style='display:none;background:#f8f9fa'>";
                html += "<td colspan='7' style='text-align:right;'>";

                html += "<div style='display:inline-block;padding:15px;border:1px solid #ccc;background:#9ab6dc;border-radius:6px;width:350px;text-align:left;'>";

                html += "<label style='margin-right:20px;color: red;'>";
                html += "<input style='border:1px solid red' type='checkbox' id='mistaken_" + woId + "_" + i + "' ";
                html += "onclick='selectReason(\"mistaken\"," + woId + "," + i + ")'> ";
                html += "Mistaken";
                html += "</label>";

                html += "<label style='color: red;'>";
                html += "<input style='border:1px solid red' type='checkbox' id='faulty_" + woId + "_" + i + "' ";
                html += "onclick='selectReason(\"faulty\"," + woId + "," + i + ")'> ";
                html += "Revert To Stage 1";
                html += "</label>";

                html += "<div id='reasonDiv_" + woId + "_" + i + "' style='display:none;margin-top:10px;'>";

                html += "<textarea id='reason_" + woId + "_" + i + "' ";
                html += "class='form-control' rows='3' ";
                html += "placeholder='Enter faulty reason'></textarea>";

                html += "</div>";

                html += "<div style='margin-top:12px;text-align:right;'>";

                html += "<button type='button' class='btn btn-outline-success btn-sm' onclick='confirmMinus(" + woId + "," + i + ")'>";
                html += "Confirm";
                html += "</button>";

                html += "</div>";

                html += "</div>";

                html += "</td>";
                html += "</tr>";

            });

            html += "</table>";

            $("#details_" + woId).html(html);
        }

        function openImage(src) {
            // Show the modal
            $("#modalImg").attr("src", src);
            $("#imageModal").fadeIn();

            // Important: stop the click event from bubbling up
            // so the same click doesn't trigger the close handler
            event.stopPropagation();
        }

        // Close when clicking the background (outside the image)
        $(document).on("click", "#imageModal", function (e) {
            if (e.target === this) {
                $(this).fadeOut();
            }
        });

        // Prevent clicks on the image itself from closing the modal
        $(document).on("click", "#modalImg", function (e) {
            e.stopPropagation();
        });

        // Close when clicking anywhere else in the page (like table cells)
        $(document).on("click", function (e) {
            if ($("#imageModal").is(":visible") &&
                !$(e.target).closest("#modalImg").length &&
                !$(e.target).closest("#imageModal").length) {
                $("#imageModal").fadeOut();
            }
        });

        // Optional: close with ESC key
        $(document).on("keyup", function (e) {
            if (e.key === "Escape") {
                $("#imageModal").fadeOut();
            }
        });

        function showMinusPanel(woId, index) {

            if (!isMachineActive) {
                alert("Machine is stopped.");
                return;
            }

            var wo = AssignWorkOrders.find(x => x.woId == woId);
            var item = wo.details[index];

            if (item.usedQty === 0)
                return;

            var panel = $("#minusPanel_" + woId + "_" + index);
            var plusBtn = $("#plus_" + woId + "_" + index);

            // If already open, close it and enable +
            if (panel.is(":visible")) {
                panel.hide();
                plusBtn.prop("disabled", false);
                return;
            }

            // Close all open panels
            $(".minusPanel").hide();

            // Enable all plus buttons
            $("button[id^='plus_']").prop("disabled", false);

            // Show current panel
            panel.show();

            // Disable current plus button
            plusBtn.prop("disabled", true);
        }

        function selectReason(type, woId, index) {

            if (type === "mistaken") {

                $("#faulty_" + woId + "_" + index).prop("checked", false);
                $("#reasonDiv_" + woId + "_" + index).hide();
                $("#reason_" + woId + "_" + index).val("");

            } else {

                $("#mistaken_" + woId + "_" + index).prop("checked", false);

                if ($("#faulty_" + woId + "_" + index).is(":checked"))
                    $("#reasonDiv_" + woId + "_" + index).show();
                else
                    $("#reasonDiv_" + woId + "_" + index).hide();
            }
        }

        function confirmMinus(woId, index) {

            if (!isMachineActive) {
                alert("Machine is stopped.");
                return;
            }

            var mistaken = $("#mistaken_" + woId + "_" + index).is(":checked");
            var faulty = $("#faulty_" + woId + "_" + index).is(":checked");
            var reason = $("#reason_" + woId + "_" + index).val();

            if (!mistaken && !faulty) {
                alert("Select Mistaken or Faulty.");
                return;
            }

            if (faulty && reason.trim() == "") {
                alert("Please enter faulty reason.");
                return;
            }

            // Hide panel
            $("#minusPanel_" + woId + "_" + index).hide();

            // Existing quantity change
            changeQty(
                woId,
                index,
                -1,
                mistaken,
                faulty,
                reason
            );
        }

        function changeQty(woId, index, delta, mistaken, faulty, reason) {

            if (!hasAssignedOperator) {   // NEW
                alert("Please assign an operator to this machine first.");
                return;
            }

            if (!isMachineActive) {
                alert("Machine is stopped. You cannot update quantity.");
                return;
            }

            var key = woId + "_" + index;

            // 🚫 prevent multiple fast clicks
            if (qtyUpdating[key]) return;

            qtyUpdating[key] = true;

            var wo = AssignWorkOrders.find(x => x.woId == woId);
            var item = wo.details[index];

            var newQty = item.usedQty + delta;


            //if (item.usedQty >= item.allocatedQty && delta < 0) {
            //    alert("This item is already completed. You cannot reduce quantity.");
            //    return;
            //}

            if (newQty < 0) {
                alert("Completed Qty cannot be less than 0.");
                qtyUpdating[key] = false;
                return;
            }

            if (newQty > item.allocatedQty) {
                alert("Allocated Qty already completed.");
                qtyUpdating[key] = false;
                return;
            }

            var sqFtPerQty = item.allocatedSqFeet / item.allocatedQty;
            var completedSqFt = newQty * sqFtPerQty;
            var revertedSqFt = sqFtPerQty;

            $.ajax({
                type: "POST",
                url: "WoProductionS2.aspx/SaveCompletedQty",
                data: JSON.stringify({
                    detailedId: item.detailedId,
                    completedQty: newQty,
                    completedSqFt: completedSqFt,
                    revertedSqFt: revertedSqFt,
                    mistaken: mistaken,
                    faulty: faulty,
                    reason: reason
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {
                    if (response.d.Status == "Success") {

                        item.usedQty = newQty;

                        $("#uq_" + woId + "_" + index).text(item.usedQty);

                        // ✅ TOTAL COMPLETED QTY (your "balanceQty")
                        wo.balanceQty = wo.details.reduce((t, d) => t + d.usedQty, 0);

                        $("#bal_" + woId).text(wo.balanceQty);

                        if (response.d.IsCompleted) {
                            alert("Allocated Qty Completed.");
                        }


                        $("#mistaken_" + woId + "_" + index).prop("checked", false);
                        $("#faulty_" + woId + "_" + index).prop("checked", false);
                        $("#reason_" + woId + "_" + index).val("");
                        $("#reasonDiv_" + woId + "_" + index).hide();
                        $("#minusPanel_" + woId + "_" + index).hide();
                        $("#plus_" + woId + "_" + index).prop("disabled", false);

                        if (response.d.HeaderStatus === "Completed") {
                            window.location.href = window.location.href;
                        }

                        if (response.d.HeaderStatus === "Reduced") {
                            window.location.href = window.location.href;
                        }
                    }
                    else {
                        alert(response.d.Message);
                    }
                },

                complete: function () {
                    // 🔓 unlock after request finishes
                    qtyUpdating[key] = false;
                },

                error: function () {
                    alert("Error while saving quantity.");
                    qtyUpdating[key] = false;
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
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <asp:HiddenField ID="hdnRole" runat="server" />
                    <h3 class="m-0 font-weight-bold"><b>Production Stage 2</b></h3>
                    <select id="ddlMachine" class="form-control" style="width: 174px;" onchange="machineChanged()">
                        <option value="">-Select Machine-</option>
                    </select>
                </div>
                <div class="card-body">
                    <div id="operatorInfo" style="display: none;">
                    </div>
                    <div class="box">
                        <div class="table-responsive">
                            <div id="woContainer"></div>
                        </div>
                        <div id="imageModal" class="image-popup">
                            <img id="modalImg" src="" />
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
