<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="Dashboard.aspx.cs" Inherits="Dashboard" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <style type="text/css">
        .dashboard {
            background: #f5f7fb;
        }

        .dashboard-card {
            background: #fff;
            border-radius: 18px;
            padding: 20px;
            box-shadow: inset 7px 0px 3px 0px rgb(27 70 157);
            margin-bottom: 27px;
            transition: .3s;
            border: 1px solid #0a287c;
        }

            .dashboard-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 30px rgba(0,0,0,.12);
            }

        .card-top {
            display: flex;
            align-items: flex-start;
        }

        .icon-box {
            width: 58px;
            height: 58px;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 26px;
            margin-right: 18px;
        }

        .blue {
            background: #2F6BFF;
        }

        .green {
            background: #18B663;
        }

        .purple {
            background: #B43AD7;
        }

        .red {
            background: #F5515F;
        }

        .orange {
            background: #FFA329;
        }

        .sky {
            background: #15B5E9;
        }

        .card-content {
            flex: 1;
        }

        .card-title {
            font-size: 22px;
            font-weight: 700;
            color: #f75d00;
        }

        .list-item {
            font-size: 16px;
            color: #000000;
            margin: 8px 0;
            font-weight: 500;
        }

        .value {
            font-size: 26px;
            font-weight: 700;
            color: #20243d;
        }

        .progress {
            height: 8px;
            border-radius: 30px;
            background: #eceff6;
            margin-top: 10px;
        }

        .progress-bar {
            background: #3d73ff;
        }

        .dashboard-filter {
            align-items: center;
        }

        .dark-filter {
            height: 42px;
            color: #0438a1;
            font-size: large;
            font-weight: 500;
            background: linear-gradient(246deg, #c1c9d9, #f5f5f5);
            border: 2px solid #233a68;
            border-radius: 10px;
            padding: 8px 12px;
            box-shadow: 0 3px 8px rgba(47, 107, 255, 0.25);
            transition: all .3s ease;
        }

            /* Hover */
            .dark-filter:hover {
                border-color: #18B663;
                box-shadow: 0 4px 12px rgba(24,182,99,0.35);
            }

            /* Focus */
            .dark-filter:focus {
                outline: none;
                border-color: #f75d00;
                box-shadow: 0 0 8px rgba(247,93,0,0.5);
            }


        /* Calendar icon */
        input[type="date"]::-webkit-calendar-picker-indicator {
            cursor: pointer;
            background-color: #2F6BFF;
            border-radius: 50%;
            padding: 6px;
            filter: invert(1);
            transition: .3s;
        }


            input[type="date"]::-webkit-calendar-picker-indicator:hover {
                background-color: #18B663;
                transform: scale(1.15);
            }

        .total-down-time {
            margin-top: 15px;
            padding: 12px 16px;
            background: #f3dab894;
            border-left: 5px solid #ffa329;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            color: #000000;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 9px 7px 6px rgb(255 163 41);
        }

        .total-productivity {
            margin-top: 15px;
            padding: 12px 16px;
            background: #7fecfe45;
            border-left: 5px solid #15b5e9;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            color: #000000;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 9px 7px 6px rgb(27 184 234);
        }

        .total-orders {
            margin-top: 15px;
            padding: 12px 16px;
            background: #18b6634a;
            border-left: 5px solid #18b663;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            color: #000000;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 9px 7px 6px rgb(15 171 89);
        }

        .total-down-time span,
        .total-productivity span,
        .total-ordersy span {
            font-size: 18px;
            font-weight: 700;
            color: #fd0101;
        }

        .mc-back-color {
            color: #0c0b0b;
            background: linear-gradient(246deg, #c1c9d9, #f5f5f5);
            border: 2px solid #ffa329;
            border-radius: 7px;
            padding: 0px 6px;
        }

        .order-clickable {
            cursor: pointer;
            transition: color .15s ease;
        }

            .order-clickable:hover {
                color: #1FA97A;
            }


        /*Modal*/
        .orders-modal-dialog .modal-content {
            max-height: 85vh;
            max-height: 85dvh;
        }

        .orders-modal-dialog .modal-body {
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            touch-action: pan-y;
            max-height: calc(85vh - 60px);
            max-height: calc(85dvh - 60px);
        }

        .orders-table {
            border-collapse: collapse;
        }

            .orders-table th,
            .orders-table td {
                border: 1px solid #333 !important;
                white-space: nowrap;
                padding: 8px 12px;
                text-align: center;
            }

            .orders-table thead th {
                background-color: #3458a5;
                color: #ffffff;
                font-weight: 700;
                position: sticky;
                top: 0;
                z-index: 1;
            }

        @media (max-width: 700px) {
            .orders-modal-dialog .modal-content {
                max-height: 90vh;
                max-height: 90dvh;
            }

            .orders-modal-dialog .modal-body {
                max-height: calc(90vh - 56px);
                max-height: calc(90dvh - 56px);
            }
        }

        @media (max-width: 576px) {
            .card-top {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }

            .icon-box {
                margin-right: 0;
                margin-bottom: 12px;
            }

            .card-content {
                width: 100%;
            }

            /* Keep the down-time machine badges centered under the icon too */
            #divMachineStatus {
                display: flex;
                justify-content: center;
                flex-wrap: wrap;
                gap: 6px;
            }

            /* List items and the total strip read better centered on narrow cards */
            .list-item {
                text-align: center;
            }

            .total-down-time,
            .total-productivity,
            .total-orders {
                flex-direction: column;
                text-align: center;
                gap: 4px;
            }
        }

        @media (max-width: 576px) {
            .card-title {
                font-size: 16px;
                line-height: 1.3;
            }
        }

        .chart-wrapper {
            height: 350px;
        }

        @media (max-width: 576px) {
            .chart-wrapper {
                height: 260px;
            }
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

        .machine-selected {
            background: #1FA97A !important;
            color: #fff !important;
            border-color: #1FA97A !important;
        }

        .machine-unselected {
            background: #E5566D !important;
            color: #fff !important;
            border-color: #E5566D !important;
        }

        .machine-item.machine-busy {
            cursor: not-allowed;
            opacity: 0.75;
        }

        .machine-busy-other {
            background: #FFA329 !important; /* amber = in use by someone else */
            color: #fff !important;
            border-color: #FFA329 !important;
        }
    </style>
    <script type="text/javascript">

        $(function () {

            var today = new Date().toISOString().split('T')[0];

            $("#txtFromDate").val(today);
            $("#txtToDate").val(today);

            loadDashboard();

            $("#txtFromDate,#txtToDate").change(function () {
                loadDashboard();
            });


            $(".machine-item").each(function () {
                var isSelected = String($(this).data("selected")).toLowerCase() === "true";
                var isBusy = String($(this).data("busy")).toLowerCase() === "true";

                if (isSelected) {
                    $(this).addClass("machine-selected");
                } else if (isBusy) {
                    $(this).addClass("machine-busy-other");
                } else {
                    $(this).addClass("machine-unselected");
                }
            });
        });

        function selectMachine(elem, force) {

            // Clicking MY OWN already-selected machine -> offer logout instead of no-op
            if ($(elem).hasClass("machine-selected")) {
                var confirmLogout = confirm("You are currently working on this machine. Do you want to log out?");

                if (confirmLogout) {
                    logoutMachine(elem);
                }
                return;
            }

            var machineId = $(elem).data("machineid");
            var stageId = $(elem).data("stageid");
            var isBusy = String($(elem).data("busy")).toLowerCase() === "true";
            var busyOperator = $(elem).data("busyoperator");

            // Machine is in use by someone else and we haven't confirmed yet
            if (isBusy && !force) {
                var confirmMsg = "This machine is currently used by " + busyOperator +
                    ". Do you want to log them out and take over this machine?";

                if (confirm(confirmMsg)) {
                    selectMachine(elem, true); // re-call with force = true
                }
                return;
            }

            // If I'm currently on a DIFFERENT machine, confirm the switch first
            var mySelectedElem = $(".machine-item.machine-selected").not(elem);

            if (mySelectedElem.length > 0 && !force) {
                var myCurrentMachineName = $.trim(mySelectedElem.first().clone().children().remove().end().text());

                var switchMsg = "You are currently working on " + myCurrentMachineName +
                    ". Do you want to switch to this machine? This will log you out of " + myCurrentMachineName + ".";

                if (confirm(switchMsg)) {
                    selectMachine(elem, true); // re-call with force = true, skip further confirms
                }
                return;
            }

            if ($(elem).hasClass("machine-processing")) return;
            $(elem).addClass("machine-processing");

            $.ajax({
                type: "POST",
                url: "Dashboard.aspx/SelectMachine",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    machineId: machineId,
                    stageId: stageId,
                    force: force === true
                }),
                success: function (response) {
                    var result = response.d;

                    if (!result.Success) {
                        alert(result.Message || "Failed to select machine.");
                        $(elem).removeClass("machine-processing");
                        return;
                    }

                    $(".machine-item")
                        .removeClass("machine-selected machine-unselected machine-busy-other");

                    $(".machine-item").each(function () {
                        if (this === elem) {
                            $(this).addClass("machine-selected")
                                .data("selected", "true")
                                .data("busy", "false");
                        } else {
                            $(this).addClass("machine-unselected");
                        }
                    });

                    $(elem).removeClass("machine-processing");
                    window.location.href = window.location.href;
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("Something went wrong selecting the machine.");
                    $(elem).removeClass("machine-processing");
                }
            });
        }

        // NEW: Logout from currently selected machine
        function logoutMachine(elem) {
            if ($(elem).hasClass("machine-processing")) return;
            $(elem).addClass("machine-processing");

            var machineId = $(elem).data("machineid");

            $.ajax({
                type: "POST",
                url: "Dashboard.aspx/LogoutMachine",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    machineId: machineId
                }),
                success: function (response) {
                    var result = response.d;

                    if (!result.Success) {
                        alert(result.Message || "Failed to log out.");
                        $(elem).removeClass("machine-processing");
                        return;
                    }

                    $(elem)
                        .removeClass("machine-selected")
                        .addClass("machine-unselected")
                        .data("selected", "false")
                        .data("busy", "false");

                    $(elem).removeClass("machine-processing");
                    window.location.href = window.location.href;
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("Something went wrong logging out.");
                    $(elem).removeClass("machine-processing");
                }
            });
        }


        function refreshDashboard() {

            var today = new Date().toISOString().split('T')[0];

            $("#txtFromDate").val(today);
            $("#txtToDate").val(today);

            loadDashboard();
        }

        function validateDateFilter() {

            var fromDate = $("#txtFromDate").val();
            var toDate = $("#txtToDate").val();

            // If From Date is empty, set today's date
            if (fromDate === "") {
                var today = new Date().toISOString().split('T')[0];
                $("#txtFromDate").val(today);
            }

            // If To Date is empty, set today's date
            if (toDate === "") {
                var today = new Date().toISOString().split('T')[0];
                $("#txtToDate").val(today);
            }
        }

        function loadDashboard() {
            validateDateFilter();

            var fromDate = $("#txtFromDate").val();
            var toDate = $("#txtToDate").val();

            $.ajax({
                type: "POST",
                url: "Dashboard.aspx/GetDashboard",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    fromDate: fromDate,
                    toDate: toDate
                }),
                success: function (response) {

                    var data = response.d;

                    bindStage1(data.Stage1);
                    bindStage2(data.Stage2);
                    bindPackaging(data.Packaging);
                    bindOrders(data.Orders);
                    bindRejected(data.Rejected);
                    bindDispatch(data.Dispatch);
                    bindDownTime(data.DownTime);
                    bindProductivity(data.Productivity);
                    bindMonthlyProduction(data.MonthlyProduction);
                    bindDealerCount(data.DealerCount);
                    bindProductionGraph(data.ProductionGraph);
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                }
            });
        }

        function bindStage1(data) {
            var html = "";
            $.each(data, function (i, item) {
                html += "<div class='list-item'>" +
                    item.DisplayText +
                    "</div>";
            });
            $("#stage1Container").html(html);

            if (data.length > 0) {

                var percentage = parseFloat(data[0].ProgressPercentage);

                $("#stage1ProgressBar").css("width", percentage + "%");

                $("#stage1Percentage").text(percentage.toFixed(2) + "%");

                // Optional: Show total completed/allocated
                $("#stage1Total").text(
                    data[0].TotalCompletedSqFt + " / " + data[0].TotalAllocatedSqFt
                );
            }
        }

        function bindStage2(data) {
            var html = "";
            $.each(data, function (i, item) {
                html += "<div class='list-item'>" +
                    item.DisplayText +
                    "</div>";
            });
            $("#stage2Container").html(html);


            if (data.length > 0) {

                var percentage = parseFloat(data[0].ProgressPercentage);

                $("#stage2ProgressBar").css("width", percentage + "%");

                $("#stage2Percentage").text(percentage.toFixed(2) + "%");

                // Optional: Show total completed/allocated
                $("#stage2Total").text(
                    data[0].TotalCompletedSqFt + " / " + data[0].TotalAllocatedSqFt
                );
            }
        }

        function bindPackaging(data) {

            var html = "";

            if (data && data.length > 0) {

                var item = data[0];

                var percentage = item.PackagingPercentage || "0.00%";
                var displayText = item.DisplayText || "<b>Sq.Ft</b> (0/0)&nbsp;&nbsp; <b>Qty</b> (0/0)";

                html = "<span class='packaging-percentage'>" + percentage + "</span><br/>" +
                    "<span class='packaging-text'>" + displayText + "</span>";

            }
            else {
                html = "<span class='packaging-percentage'>0.00%</span><br/>" +
                    "<span class='packaging-text'><b>Sq.Ft</b> (0/0)&nbsp;&nbsp; <b>Qty</b> (0/0)</span>";
            }

            $("#lblPackaging").html(html);

            // Manage CSS here
            $("#lblPackaging .packaging-percentage").css({
                "font-size": "17px",
                "font-weight": "900",
                "font-family": "Arial, sans-serif"
            });

            $("#lblPackaging .packaging-text").css({
                "font-size": "12px",
                "font-family": "Arial, sans-serif"
            });

            $("#lblPackaging .packaging-text b").css({
                "font-weight": "bold"
            });
        }

        function bindOrders(data) {
            if (data == null)
                return;
            var item = data[0];

            $("#lblNewOrders").text(item.NewOrders + " (" + item.NewOrdersSqFeet + " SqFeet)");
            $("#lblPendingOrders").text(item.PendingOrders + " (" + item.PendingOrdersSqFeet + " SqFeet)");
            $("#lblOverDueOrders").text(item.OverDueOrders + " (" + item.OverDueOrdersSqFeet + " SqFeet)");

            var totalCount = parseInt(item.NewOrders || 0) + parseInt(item.PendingOrders || 0) + parseInt(item.OverDueOrders || 0);
            var totalSqFeet = parseFloat(item.NewOrdersSqFeet || 0) + parseFloat(item.PendingOrdersSqFeet || 0) + parseFloat(item.OverDueOrdersSqFeet || 0);

            $("#lblTotalOrders").text(totalCount + " (" + totalSqFeet + " SqFeet)");
        }

        function bindRejected(data) {

            if (data == null)
                return;

            var item = data[0];
            $("#lblRejectedCount").text(item.ReturnCount || 0);

        }

        function bindDispatch(data) {

            if (data == null)
                return;

            var item = data[0];
            $("#lblDispatchCount").text(item.DispatchedCount || 0);

        }

        function bindDownTime(data) {
            var html = "";
            var machineStatusHtml = "";
            var totalSeconds = 0;

            $.each(data, function (index, item) {

                html += `
            <div class="list-item">
                ${item.MachineName} - ${item.TotalDownTime}
            </div>
        `;

                machineStatusHtml += `
            ${item.MachineStatus}
        `;

                totalSeconds += parseInt(item.TotalDownSeconds || 0);
            });

            $("#divDownTime").html(html);
            $("#divMachineStatus").html(machineStatusHtml);

            var hours = Math.floor(totalSeconds / 3600);
            var minutes = Math.floor((totalSeconds % 3600) / 60);
            var seconds = totalSeconds % 60;

            var totalTime =
                String(hours).padStart(2, '0') + ":" +
                String(minutes).padStart(2, '0') + ":" +
                String(seconds).padStart(2, '0');

            $("#lblTotalDownTime").text(totalTime);
        }

        document.addEventListener('click', function (e) {
            const badge = e.target.closest('.reason-badge');
            if (!badge) return;

            const reason = badge.getAttribute('data-reason') || 'No reason provided';

            const dialog = document.getElementById('ordersModalDialog');
            dialog.classList.remove('modal-xl', 'modal-lg');
            dialog.classList.add('modal-sm');

            document.getElementById('ordersModalTitle').innerText = 'Reason';
            document.getElementById('ordersModalBody').innerHTML =
                '<p style="font-size:15px; color:#333; margin:0;">' + reason + '</p>';

            document.getElementById('btnDownloadOrdersExcel').style.display = 'none';

            const modal = new bootstrap.Modal(document.getElementById('ordersModal'));
            modal.show();
        });

        function bindProductivity(data) {
            var html = "";
            var AllocatedSqFeet = 0;
            var CompletedSqFeet = 0;

            $.each(data, function (index, item) {

                html += `
                <div class="list-item">
                    ${item.DisplayText}
                </div>`;

                AllocatedSqFeet += parseInt(item.AllocatedSqFeet || 0);
                CompletedSqFeet += parseInt(item.CompletedSqFeet || 0);
            });

            $("#lblProductivity").html(html);

            $("#lblTotalProductivity").text(CompletedSqFeet + '/' + AllocatedSqFeet);
        }

        function bindMonthlyProduction(data) {

            if (data == null)
                return;

            var item = data[0];
            $("#lblMonthlyProduction").text(item.CurrentMonthProduction || 0);
        }

        function bindDealerCount(data) {

            if (data == null)
                return;

            var item = data[0];
            $("#lblDealerCount").text(item.DealersCount || 0);
        }

        var productionChartInstance = null;

        function parseAspNetDate(val) {
            if (typeof val === "string") {
                var match = /\/Date\((\d+)\)\//.exec(val);
                if (match) {
                    return new Date(parseInt(match[1], 10));
                }
            }
            return new Date(val);
        }

        function bindProductionGraph(data) {
            if (data == null || data.length === 0)
                return;

            var labels = data.map(function (item) {
                var d = parseAspNetDate(item.ProductionDate);
                return d.getDate();
            });

            var assignedQty = data.map(function (item) {
                return item.TotalQty || 0;
            });

            var completedQty = data.map(function (item) {
                return item.ProductionQty || 0;
            });

            var totalAssigned = assignedQty.reduce(function (sum, val) { return sum + val; }, 0);
            var totalCompleted = completedQty.reduce(function (sum, val) { return sum + val; }, 0);

            $("#lblProductionChartTitle").text(
                "Monthly Production (" + totalCompleted + "/" + totalAssigned + " Sq.ft)"
            );

            var isMobile = window.innerWidth < 576;
            var baseFontSize = isMobile ? 9 : 12;
            var titleFontSize = isMobile ? 10 : 13;

            var ctx = document.getElementById("productionChart").getContext("2d");

            if (productionChartInstance) {
                productionChartInstance.destroy();
            }

            productionChartInstance = new Chart(ctx, {
                type: "line",
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: "Assigned Qty",
                            data: assignedQty,
                            borderColor: "rgba(220,53,69,1)",
                            backgroundColor: "rgba(54,162,235,0.1)",
                            fill: false,
                            tension: 0.3,
                            pointRadius: isMobile ? 2 : 3,
                            pointHoverRadius: isMobile ? 3 : 5,
                            borderWidth: isMobile ? 1.5 : 2
                        },
                        {
                            label: "Completed Qty",
                            data: completedQty,
                            borderColor: "rgba(40,167,69,1)",
                            backgroundColor: "rgba(75,192,192,0.1)",
                            fill: false,
                            tension: 0.3,
                            pointRadius: isMobile ? 2 : 3,
                            pointHoverRadius: isMobile ? 3 : 5,
                            borderWidth: isMobile ? 1.5 : 2
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: "index",
                        intersect: false
                    },
                    layout: {
                        padding: isMobile ? { top: 4, right: 4, left: 0, bottom: 0 } : 0
                    },
                    scales: {
                        x: {
                            title: {
                                display: !isMobile,
                                text: "Day of Month",
                                font: { weight: "bold", size: titleFontSize }
                            },
                            ticks: {
                                font: { weight: "bold", size: baseFontSize },
                                maxRotation: 0,
                                autoSkip: true,
                                maxTicksLimit: isMobile ? 8 : 31
                            },
                            grid: {
                                display: false
                            }
                        },
                        y: {
                            beginAtZero: true,
                            min: 0,
                            ticks: {
                                stepSize: 20,
                                font: { weight: "bold", size: baseFontSize }
                            },
                            title: {
                                display: !isMobile,
                                text: "Sum of Qty (Sq.ft)",
                                font: { weight: "bold", size: titleFontSize }
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            position: "top",
                            align: "end",
                            labels: {
                                font: { weight: "bold", size: baseFontSize },
                                boxWidth: isMobile ? 12 : 20,
                                padding: isMobile ? 8 : 12
                            }
                        },
                        tooltip: {
                            mode: "index",
                            intersect: false,
                            titleFont: { weight: "bold", size: baseFontSize },
                            bodyFont: { weight: "bold", size: baseFontSize }
                        }
                    }
                }
            });
        }

        var lastOrdersData = [];
        var lastOrdersType = "";

        function showOrdersModal(type) {
            $("#ordersModalTitle").text(type);
            $("#ordersModalBody").html("<div class='text-center py-3'>Loading...</div>");

            lastOrdersData = [];
            lastOrdersType = type;

            var modal = new bootstrap.Modal(document.getElementById('ordersModal'));
            modal.show();

            $.ajax({
                type: "POST",
                url: "Dashboard.aspx/GetOrderDetails",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    fromDate: $("#txtFromDate").val(),
                    toDate: $("#txtToDate").val(),
                    type: type
                }),
                success: function (response) {
                    var data = response.d;

                    if (!data || data.length === 0) {
                        $("#ordersModalBody").html("<div class='text-center text-muted py-3'>No records found</div>");
                        return;
                    }

                    lastOrdersData = data;

                    var columns = Object.keys(data[0]);

                    var html = "<div class='table-responsive'><table class='table table-sm table-bordered align-middle text-center orders-table'><thead><tr>";

                    $.each(columns, function (i, col) {
                        html += "<th>" + col + "</th>";
                    });

                    html += "</tr></thead><tbody>";

                    $.each(data, function (i, item) {
                        html += "<tr>";

                        $.each(columns, function (j, col) {
                            var val = item[col];

                            if (plainColumns.indexOf(col) > -1) {
                                html += "<td><strong>" + formatDate(val) + "</strong></td>";
                            } else {
                                html += "<td>" + statusBadge(val) + "</td>";
                            }
                        });

                        html += "</tr>";
                    });

                    html += "</tbody></table></div>";

                    $("#ordersModalBody").html(html);

                    const dialog = document.getElementById('ordersModalDialog');
                    dialog.classList.remove('modal-sm', 'modal-lg');
                    dialog.classList.add('modal-xl');

                    document.getElementById('btnDownloadOrdersExcel').style.display = '';
                },
                error: function (xhr) {
                    $("#ordersModalBody").html("<div class='text-center text-danger py-3'>Failed to load</div>");
                    console.log(xhr.responseText);
                }
            });
        }

        function badgeColorHex(status) {
            // Reuses the same lookup logic as statusBadge, but returns just the hex for cell background
            if (status === null || status === undefined || status === "") {
                status = "-";
            }

            var exactColorMap = {
                "W/O On Hold": "#E8A33D", "W/O Canceled": "#E5566D", "-": "#9CA3AF",
                "Send For Design Approval": "#E8A33D", "Approved From Designer": "#1FA97A",
                "Rejected From Designer": "#E5566D", "Approved": "#1FA97A", "Rejected": "#E5566D",
                "Pending": "#E8A33D", "Not Scheduled": "#E8A33D", "Scheduled": "#1FA97A",
                "Work Not Started": "#E5566D", "Work Started": "#E8A33D", "W/O Not Allocated": "#E5566D",
                "Partially Active": "#E8A33D", "Active": "#2AAFD6", "Completed": "#1FA97A",
                "Not Packed": "#E5566D", "Packed": "#1FA97A", "Production Pending": "#E5566D",
                "In Production": "#E8A33D", "Production Completed": "#1FA97A", "Not Dispatched": "#E5566D",
                "Dispatched": "#2AAFD6", "Out For Delivery": "#E8A33D", "Delivered": "#1FA97A"
            };

            var bg = exactColorMap[status];

            if (!bg) {
                var s = status.toLowerCase();
                if (s.indexOf("not ") === 0 || s.indexOf("reject") > -1 || s.indexOf("cancel") > -1 || s.indexOf("hold") > -1) {
                    bg = "#E5566D";
                } else if (s.indexOf("complet") > -1 || s.indexOf("approved") > -1 || s.indexOf("delivered") > -1 || s.indexOf("packed") > -1 || s.indexOf("scheduled") > -1) {
                    bg = "#1FA97A";
                } else if (s.indexOf("pending") > -1 || s.indexOf("progress") > -1 || s.indexOf("partial") > -1 || s.indexOf("started") > -1) {
                    bg = "#E8A33D";
                } else {
                    bg = "#6b7280";
                }
            }

            return bg;
        }

        function downloadOrdersExcel() {
            if (!lastOrdersType) {
                alert("Open a report first.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "Dashboard.aspx/GetOrderDetailsExcel",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    fromDate: $("#txtFromDate").val(),
                    toDate: $("#txtToDate").val(),
                    type: lastOrdersType
                }),
                success: function (response) {
                    var result = response.d;

                    var byteCharacters = atob(result.FileContent);
                    var byteNumbers = new Array(byteCharacters.length);

                    for (var i = 0; i < byteCharacters.length; i++) {
                        byteNumbers[i] = byteCharacters.charCodeAt(i);
                    }

                    var byteArray = new Uint8Array(byteNumbers);
                    var blob = new Blob([byteArray], {
                        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    });

                    var link = document.createElement("a");
                    link.href = URL.createObjectURL(blob);
                    link.download = result.FileName;
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("Failed to generate Excel file.");
                }
            });
        }


        function formatDate(val) {
            if (typeof val === "string") {
                var match = /\/Date\((\d+)\)\//.exec(val);
                if (match) {
                    return new Date(parseInt(match[1], 10)).toLocaleDateString();
                }
            }
            return val;
        }

        // Columns that should stay as plain text/dates — everything else gets a badge
        var plainColumns = ["W/O No.", "W/O Date", "Estimated Delivery Date", "ScheduledDate"];

        function statusBadge(status) {
            if (status === null || status === undefined || status === "") {
                status = "-";
            }

            var exactColorMap = {
                // Hold / Cancel
                "W/O On Hold": "#E8A33D",
                "W/O Canceled": "#E5566D",
                "-": "#9CA3AF",

                // Design
                "Send For Design Approval": "#E8A33D",
                "Approved From Designer": "#1FA97A",
                "Rejected From Designer": "#E5566D",
                "Approved": "#1FA97A",
                "Rejected": "#E5566D",
                "Pending": "#E8A33D",

                // Scheduling
                "Not Scheduled": "#E8A33D",
                "Scheduled": "#1FA97A",

                // Stage 1 / Stage 2
                "Work Not Started": "#E5566D",
                "Work Started": "#E8A33D",
                "W/O Not Allocated": "#E5566D",
                "Partially Active": "#E8A33D",
                "Active": "#2AAFD6",
                "Completed": "#1FA97A",

                // Packaging
                "Not Packed": "#E5566D",
                "Packed": "#1FA97A",

                // Production
                "Production Pending": "#E5566D",
                "In Production": "#E8A33D",
                "Production Completed": "#1FA97A",

                // Dispatch / final status
                "Not Dispatched": "#E5566D",
                "Dispatched": "#2AAFD6",
                "Out For Delivery": "#E8A33D",
                "Delivered": "#1FA97A"
            };

            var bg = exactColorMap[status];

            // Fallback for raw values coming straight from MH.S1Status / MH.S2Status
            // that aren't in the exact map above (e.g. "Machine Allocated", custom stage names)
            if (!bg) {
                var s = status.toLowerCase();

                if (s.indexOf("not ") === 0 || s.indexOf("reject") > -1 || s.indexOf("cancel") > -1 || s.indexOf("hold") > -1) {
                    bg = "#E5566D"; // red
                } else if (s.indexOf("complet") > -1 || s.indexOf("approved") > -1 || s.indexOf("delivered") > -1 || s.indexOf("packed") > -1 || s.indexOf("scheduled") > -1) {
                    bg = "#1FA97A"; // green — completed states always win here
                } else if (s.indexOf("pending") > -1 || s.indexOf("progress") > -1 || s.indexOf("partial") > -1 || s.indexOf("started") > -1) {
                    bg = "#E8A33D"; // amber
                } else {
                    bg = "#6b7280"; // grey fallback
                }
            }

            return "<span style='background:" + bg + "; color:#fff; padding:3px 10px; border-radius:12px; font-size:13px; font-weight:600; white-space:nowrap; display:inline-block;'>" +
                status + "</span>";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="container-fluid dashboard" runat="server" visible="false" id="divAdmin">
                <div class="row mb-3 justify-content-center dashboard-filter">
                    <div class="col-12 col-md-2 mb-2 mb-md-0">
                        <input type="date" id="txtFromDate" class="form-control dark-filter" />
                    </div>

                    <div class="col-12 col-md-2 mb-2 mb-md-0">
                        <input type="date" id="txtToDate" class="form-control dark-filter" />
                    </div>

                    <div class="col-md-2">
                        <button id="btnRefresh" type="button" onclick="refreshDashboard(); return false;" style="background: linear-gradient(80deg, #e5e9f1, #bb131373);" class="btn btn-outline-danger">
                            <i class="bi bi-arrow-clockwise"></i>
                        </button>
                    </div>
                </div>

                <div class="row">
                    <!-- LEFT SIDE -->
                    <div class="col-lg-8">
                        <div class="row">
                            <!-- Stage 1 -->
                            <div class="col-md-6">
                                <div class="dashboard-card">
                                    <div class="card-top">
                                        <div class="icon-box blue">
                                            <i class="bi bi-gear"></i>
                                        </div>
                                        <div class="card-content">
                                            <div class="card-title">
                                                Production Stage 1 %
                                            </div>
                                            <div id="stage1Container"></div>
                                            <div id="stage1Total" class="fw-bold text-success mt-2 d-none"></div>
                                            <div class="progress mt-2">
                                                <div id="stage1ProgressBar"
                                                    class="progress-bar bg-primary"
                                                    style="width: 0%">
                                                </div>
                                            </div>

                                            <div id="stage1Percentage"
                                                class="text-end mt-1 text-primary fw-bold">
                                                0.00%
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- Stage 2 -->
                            <div class="col-md-6">
                                <div class="dashboard-card">
                                    <div class="card-top">
                                        <div class="icon-box blue">
                                            <i class="bi bi-gear"></i>
                                        </div>
                                        <div class="card-content">
                                            <div class="card-title">
                                                Production Stage 2 %
                                            </div>
                                            <div id="stage2Container"></div>
                                            <div id="stage2Total" class="fw-bold text-success mt-2 d-none"></div>
                                            <div class="progress mt-2">
                                                <div id="stage2ProgressBar"
                                                    class="progress-bar bg-success"
                                                    style="width: 38%">
                                                </div>
                                            </div>
                                            <div id="stage2Percentage"
                                                class="text-end mt-1 text-success fw-bold">
                                                0.00%
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Packaging / Rejected -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="dashboard-card">
                                    <div class="card-top">
                                        <div class="icon-box purple">
                                            <i class="bi bi-box-seam"></i>
                                        </div>
                                        <div class="card-content">
                                            <div class="card-title">
                                                Packaging %
                                            </div>
                                            <div id="lblPackaging" class="value"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <div class="dashboard-card">
                                    <div class="card-top">
                                        <div class="icon-box red">
                                            <i class="bi bi-x-octagon"></i>
                                        </div>
                                        <div class="card-content">
                                            <div class="card-title">
                                                Rejected Count
                                            </div>
                                            <div class="value" id="lblRejectedCount">0</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Dispatch / Production -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="dashboard-card">
                                    <div class="card-top">
                                        <div class="icon-box sky">
                                            <i class="bi bi-clipboard-check"></i>
                                        </div>
                                        <div class="card-content">
                                            <div class="card-title">
                                                Work Order Dispatch
                                            </div>
                                            <div class="value" id="lblDispatchCount">0</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="dashboard-card">
                                    <div class="card-top">
                                        <div class="icon-box purple">
                                            <i class="bi bi-building"></i>
                                        </div>
                                        <div class="card-content">
                                            <div class="card-title">
                                                Monthly Production
                                            </div>
                                            <div id="lblMonthlyProduction" class="value">0</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Dispatch Days / Dealers -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="dashboard-card">
                                    <div class="card-top">
                                        <div class="icon-box orange">
                                            <i class="bi bi-calendar-event"></i>
                                        </div>
                                        <div class="card-content">
                                            <div class="card-title">
                                                Average Dispatch Days
                                            </div>
                                            <div class="value">
                                                -
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="dashboard-card">
                                    <div class="card-top">
                                        <div class="icon-box blue">
                                            <i class="bi bi-people"></i>
                                        </div>
                                        <div class="card-content">
                                            <div class="card-title">
                                                No. Of Dealers
                                            </div>
                                            <div id="lblDealerCount" class="value">0</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Charts -->
                        <div class="row">
                            <div class="col-md-12">
                                <div class="dashboard-card">
                                    <div class="card-title mb-3" id="lblProductionChartTitle">
                                        Monthly Production (0/0 Sq.ft)       
                                    </div>
                                    <div class="chart-wrapper" style="position: relative; width: 100%;">
                                        <canvas id="productionChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- RIGHT SIDE -->
                    <div class="col-lg-4">
                        <!-- Down Time -->
                        <div class="dashboard-card">
                            <div class="card-top">
                                <div class="icon-box orange">
                                    <i class="bi bi-clock-history"></i>
                                </div>
                                <div class="card-content">
                                    <div class="card-title">
                                        Down Time 
                                    </div>
                                    <div id="divMachineStatus" class="mt-1"></div>
                                    <div id="divDownTime"></div>
                                </div>
                            </div>
                            <div class="total-down-time">
                                Total Down Time:
                                <span id="lblTotalDownTime"></span>
                            </div>
                        </div>
                        <!-- Productivity -->
                        <div class="dashboard-card">
                            <div class="card-top">
                                <div class="icon-box sky">
                                    <i class="bi bi-bar-chart"></i>
                                </div>
                                <div class="card-content">
                                    <div class="card-title">
                                        Operator Productivity
                                    </div>
                                    <div id="lblProductivity"></div>
                                </div>
                            </div>
                            <div class="total-productivity">
                                Total Productivity:
                              <span id="lblTotalProductivity"></span>
                            </div>
                        </div>
                        <!-- Orders -->

                        <div class="dashboard-card">
                            <div class="card-top">
                                <div class="icon-box green">
                                    <i class="bi bi-card-checklist"></i>
                                </div>
                                <div class="card-content">
                                    <div class="card-title">
                                        Orders
                                    </div>
                                    <div class="list-item order-clickable" onclick="showOrdersModal('New Orders')">
                                        New Orders -
                                         <span id="lblNewOrders">0</span>
                                    </div>
                                    <div class="list-item order-clickable" onclick="showOrdersModal('Pending Orders')">
                                        Pending Orders -
                                       <span id="lblPendingOrders">0</span>
                                    </div>
                                    <div class="list-item order-clickable" onclick="showOrdersModal('Over Due Orders')">
                                        Over Due Orders -
                                       <span id="lblOverDueOrders">0</span>
                                    </div>
                                </div>
                            </div>
                            <div class="total-orders order-clickable" onclick="showOrdersModal('Total Orders')">
                                Total Orders:
                                <span id="lblTotalOrders"></span>
                            </div>
                        </div>
                    </div>
                </div>


                <!-- Orders Modal -->
                <div class="modal fade" id="ordersModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable orders-modal-dialog" id="ordersModalDialog">
                        <div class="modal-content" style="border-radius: 14px; border: none;">
                            <div class="modal-header" style="border-bottom: 1px solid #eef0f5; justify-content: flex-start;">
                                <h5 class="modal-title flex-grow-1" style="font-weight: 700; color: #1c2033;"
                                    id="ordersModalTitle"></h5>
                                <button id="btnDownloadOrdersExcel" type="button" class="btn btn-success btn-sm me-2" onclick="downloadOrdersExcel()">
                                    <i class="bi bi-file-earmark-excel"></i>Download Excel
                                </button>
                                <button type="button" class="btn btn-danger btn-sm" data-bs-dismiss="modal" aria-label="Close">X</button>
                            </div>
                            <div class="modal-body" id="ordersModalBody">
                                <!-- filled by JS -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="container-fluid" runat="server" id="divOperator" visible="false">
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
                                            <div class="machine-item"
                                                data-machineid='<%# Eval("MachineId") %>'
                                                data-stageid='<%# Eval("StageId") %>'
                                                data-selected='<%# Eval("IsSelected").ToString().ToLower() %>'
                                                data-busy='<%# Eval("IsBusy").ToString().ToLower() %>'
                                                data-busyoperator='<%# Eval("OperatorName") %>'
                                                title='<%# string.IsNullOrEmpty(Eval("OperatorName").ToString()) ? "Available" : "In use by " + Eval("OperatorName") %>'
                                                onclick="selectMachine(this)">
                                                <%# Eval("MachineName") %>
                                                <%# string.IsNullOrEmpty(Eval("OperatorName").ToString()) ? "" : " (" + Eval("OperatorName") + ")" %>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
