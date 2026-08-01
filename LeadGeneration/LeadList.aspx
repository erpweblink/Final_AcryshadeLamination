<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="LeadList.aspx.cs" Inherits="LeadList" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.1.0-rc.0/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.1.0-rc.0/js/select2.min.js"></script>
    <style type="text/css">
        /* ===== Page & Card Container ===== */
        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            overflow: hidden;
        }

        .card-body {
            padding: 24px;
            background: #fafbfd;
        }

        /* ===== Filter Bar ===== */
        .filter-bar {
            background: #ffffff;
            border-radius: 10px;
            padding: 0px 0px;
            margin-bottom: 12px;
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
            border: 1px solid #e9ecef;
        }

            .filter-bar label {
                color: #495057;
                font-size: 13px;
                text-transform: uppercase;
                letter-spacing: 0.4px;
                margin-bottom: 6px;
            }

            .filter-bar .form-control {
                border: 1px solid #dee2e6 !important;
                border-radius: 8px;
                height: 42px;
                transition: border-color 0.2s, box-shadow 0.2s;
            }

                .filter-bar .form-control:focus {
                    border-color: #2d6be0 !important;
                    box-shadow: 0 0 0 3px rgba(45,107,224,0.15);
                    outline: none;
                }

        #btnRefresh {
            height: 42px;
            width: 42px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.2s;
        }

            #btnRefresh:hover {
                transform: rotate(-25deg);
            }

        /* ===== Table ===== */
        .leads-table {
            border: none !important;
            border-collapse: separate;
            border-spacing: 0;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 1px 6px rgba(0,0,0,0.06);
        }

            .leads-table thead tr {
                background: linear-gradient(135deg, #2d6be0 0%, #1e56c4 100%) !important;
            }

            .leads-table th {
                border: none !important;
                height: 52px;
                font-weight: 600;
                font-size: 13px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: #ffffff !important;
                vertical-align: middle;
            }

            .leads-table td {
                border: none !important;
                border-bottom: 1px solid #eef1f5 !important;
                vertical-align: middle;
                padding: 14px 12px;
                background: #ffffff;
            }

            .leads-table tbody tr {
                transition: background-color 0.15s;
            }

                .leads-table tbody tr:hover td {
                    background-color: #f4f8ff;
                }

                .leads-table tbody tr:last-child td {
                    border-bottom: none !important;
                }

        .scroll-box {
            max-height: 160px;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 4px 8px;
            line-height: 1.7;
            width: 100%;
            word-wrap: break-word;
            white-space: normal;
            font-size: 13.5px;
        }

            .scroll-box b {
                color: #1a4fb8;
            }

            .scroll-box::-webkit-scrollbar {
                width: 6px;
            }

            .scroll-box::-webkit-scrollbar-thumb {
                background: #c3cbd6;
                border-radius: 4px;
            }

            .scroll-box::-webkit-scrollbar-track {
                background: transparent;
            }

        /* ===== Status Badges (pill-style) ===== */
        .ddl-status {
            border-radius: 26px !important;
            text-align: center;
            text-align-last: center;
            font-size: 12px;
            letter-spacing: 0.3px;
            padding: 7px 11px !important;
            height: auto !important;
            cursor: pointer;
            width: 122px !important;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
        }

        .status-cold {
            background-color: #e7f1ff !important;
            color: #0a58ca !important;
            border: 1.5px solid #a8caff !important;
            font-weight: 700;
        }

        .status-warm {
            background-color: #fff3cd !important;
            color: #92700a !important;
            border: 1.5px solid #f0d075 !important;
            font-weight: 700;
        }

        .status-hot {
            background-color: #ffe0e3 !important;
            color: #c21f2e !important;
            border: 1.5px solid #f5a8ae !important;
            font-weight: 700;
        }

        .status-blank {
            background-color: #f1f3f5 !important;
            color: #495057 !important;
            border: 1.5px solid #dee2e6 !important;
            font-weight: 700;
        }

        .modal-header .close {
            color: #fff !important;
            opacity: 1 !important;
            font-size: 30px;
            text-shadow: none;
            margin-top: -5px;
        }

            .modal-header .close:hover {
                color: #fff;
                opacity: .8;
            }
        /* ===== Lead Date ===== */
        .lead-date-cell {
            color: #dc3545 !important;
            font-weight: 700;
            font-size: 13.5px;
        }

        /* ===== Select2 (Dealer) ===== */
        .select2-container {
            width: 100% !important;
        }

            .select2-container .select2-selection--single {
                height: 40px !important;
                border-radius: 8px !important;
                border: 1px solid #dee2e6 !important;
                display: flex;
                align-items: center;
                padding: 0 8px;
                background: #ffffff !important;
                color: #000000 !important;
            }

        /* Center placeholder text */
        .select2-container--default .select2-selection--single .select2-selection__placeholder {
            text-align: center;
            display: block;
            width: 100%;
        }

        .select2-container--default .select2-selection--single .select2-selection__rendered {
            line-height: 40px;
            color: #495057;
            text-align: center;
        }

        .select2-container--default .select2-selection--single .select2-selection__arrow {
            height: 38px;
        }

        .select2-dropdown {
            border-radius: 8px;
            border: 1px solid #dee2e6;
            box-shadow: 0 4px 16px rgba(0,0,0,0.12);
        }

        .select2-results__option--highlighted {
            background-color: #2d6be0 !important;
        }

        /* ===== Sr No. circle badge ===== */
        .sr-no-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 26px;
            height: 26px;
            border-radius: 50%;
            background: #eef2f9;
            color: #495057;
            font-size: 12px;
            font-weight: 700;
        }


        /* Fixed modal height */
        #followUpModal .modal-dialog {
            max-width: 900px;
        }

        #followUpModal .modal-body {
            overflow: hidden;
        }

        /* History section */
        #historySection {
            height: 100%;
        }

        /* Scrollable history */
        #historyDiv {
            height: 340px;
            overflow-y: auto;
            overflow-x: hidden;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 10px;
            background: #fff;
        }

            /* Nice scrollbar */
            #historyDiv::-webkit-scrollbar {
                width: 8px;
            }

            #historyDiv::-webkit-scrollbar-thumb {
                background: #b5b5b5;
                border-radius: 10px;
            }

                #historyDiv::-webkit-scrollbar-thumb:hover {
                    background: #888;
                }

        .role-hidden {
            display: none !important;
        }


        /* Hide default inline tags inside the select box itself */
        .select2-container--default .select2-selection--multiple .select2-selection__rendered {
            display: none !important;
        }

        /* Keep the box looking like a normal input with just the search/placeholder */
        .select2-container--default .select2-selection--multiple {
            border: 1px solid #dee2e6 !important;
            border-radius: 8px !important;
            height: 42px !important;
            padding: 0 8px;
            background: #ffffff !important;
            display: flex;
            align-items: center;
        }

        .select2-container--default .select2-search--inline {
            width: 100%;
        }

            .select2-container--default .select2-search--inline .select2-search__field {
                width: 100% !important;
                height: 40px;
                font-size: 16px;
                text-align: center;
                margin: 0;
            }

        /* Show a check style on already-selected options in the open dropdown */
        .select2-results__option[aria-selected="true"] {
            background-color: #e7f1ff !important;
            color: #0a58ca !important;
            font-weight: 600;
        }

            .select2-results__option[aria-selected="true"]::after {
                content: " ✓";
                color: #0a58ca;
            }

        /* ===== Badge grid BELOW the select box, 3 per row ===== */
        .dealer-badge-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 6px;
            margin-top: 8px;
        }

        .dealer-badge {
            background-color: #e7f1ff;
            border: 1px solid #a8caff;
            border-radius: 6px;
            color: #0a58ca;
            font-size: 12px;
            font-weight: 600;
            padding: 5px 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 6px;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
        }

            .dealer-badge span {
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .dealer-badge .dealer-badge-remove {
                cursor: pointer;
                font-weight: bold;
                color: #0a58ca;
                flex-shrink: 0;
                line-height: 1;
            }

                .dealer-badge .dealer-badge-remove:hover {
                    color: #c21f2e;
                }

        @media (max-width: 576px) {
            .dealer-badge-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }


        /* ===== Responsive rules (kept from before, lightly adjusted) ===== */
        @media (min-width: 993px) {
            .leads-table th.col-personal, .leads-table td.col-personal {
                width: 320px;
            }

            .leads-table th.col-other, .leads-table td.col-other {
                width: 480px;
            }

            .leads-table th.col-assign, .leads-table td.col-assign {
                width: 280px;
            }
        }

        @media (min-width: 577px) and (max-width: 992px) {
            .leads-table th.col-personal, .leads-table td.col-personal {
                width: 220px;
            }

            .leads-table th.col-other, .leads-table td.col-other {
                width: 300px;
            }

            .leads-table th.col-assign, .leads-table td.col-assign {
                width: 220px;
            }

            .scroll-box {
                max-height: 130px;
            }
        }

        @media (max-width: 576px) {
            .leads-table thead {
                display: none;
            }

            .leads-table, .leads-table tbody, .leads-table tr, .leads-table td {
                display: block;
                width: 100% !important;
            }

                .leads-table tr {
                    margin-bottom: 16px;
                    border: 1px solid #e5e9f0 !important;
                    border-radius: 10px;
                    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
                    padding: 8px;
                }

                .leads-table td {
                    border: none !important;
                    padding: 8px 6px;
                    text-align: left !important;
                }

                    .leads-table td::before {
                        content: attr(data-label);
                        display: block;
                        font-weight: 700;
                        color: #2d6be0;
                        font-size: 12px;
                        text-transform: uppercase;
                        margin-bottom: 4px;
                    }

            .scroll-box {
                max-height: 140px;
            }

            .select2-container {
                width: 100% !important;
            }
        }
    </style>
    <script type="text/javascript">
        var currentUserRole = "<%= System.Web.HttpContext.Current.Session["Role"] != null ? System.Web.HttpContext.Current.Session["Role"].ToString() : "" %>";
        var dealersList = [];

        function loadDealers(callback) {
            PageMethods.GetDealers(function (result) {
                dealersList = JSON.parse(result);
                if (callback) callback();
            }, function (error) {
                console.error("Failed to load dealers: " + error.get_message());
            });
        }

        function renderLeadsTable(leads) {
            // destroy existing select2 widgets so their body-appended dropdowns don't leak
            $(".ddl-dealer").each(function () {
                if ($(this).hasClass("select2-hidden-accessible")) {
                    $(this).select2("destroy");
                }
            });

            var tbody = $("#leadsTableBody");
            tbody.empty();

            if (leads.length === 0) {
                tbody.append('<tr><td colspan="6" class="text-center">No records found.</td></tr>');
                return;
            }

            leads.forEach(function (lead, index) {
                var personalHtml = formatKeyValueJson(lead.PersonalInfo);
                var otherHtml = formatOtherDetailsJson(lead.FormQuestion);

                var statusClass = "status-blank";
                if (lead.Status === "Cold") statusClass = "status-cold";
                if (lead.Status === "Warm") statusClass = "status-warm";
                if (lead.Status === "Hot") statusClass = "status-hot";

                var assignCellHtml;

                if (currentUserRole === "Dealer") {
                    // Dealer: read-only, just show the assigned dealer's name as plain text
                    var assignedDealer = dealersList.find(function (d) { return d.ID === lead.AssignedTo; });
                    var dealerName = assignedDealer ? escapeHtml(assignedDealer.DealerName) : "-";
                    assignCellHtml = '<span class="fw-bold">' + dealerName + '</span>';
                } else {
                    // Admin/other roles: full editable Select2 dropdown
                    var dealerOptions = '<option value="">-- Select Dealer --</option>';
                    dealersList.forEach(function (dealer) {
                        var selected = (dealer.ID === lead.AssignedTo) ? "selected" : "";
                        dealerOptions += '<option value="' + dealer.ID + '" ' + selected + '>' + escapeHtml(dealer.DealerName) + '</option>';
                    });
                    assignCellHtml =
                        '<select class="form-control ddl-dealer" data-lead-id="' + lead.ID + '">' +
                        dealerOptions +
                        '</select>';
                }

                var row =
                    '<tr>' +
                    '<td data-label="Sr No." style="text-align:center;">' + (index + 1) + '</td>' +
                    '<td class="col-personal" data-label="Personal Info"><div class="scroll-box">' + personalHtml + '</div></td>' +
                    '<td data-label="Lead Date" style="text-align:center;color:#1a4fc8;font-size: 14px;font-weight: 700;">' + lead.CreatedDate + '</td>' +
                    '<td class="col-other" data-label="Other Info"><div class="scroll-box">' + otherHtml + '</div></td>' +
                    '<td data-label="Status" style="text-align:center;">' +
                    '<select class="form-control ddl-status ' + statusClass + '" data-lead-id="' + lead.ID + '" onchange="UpdateLeadStatus(this);">' +
                    '<option value="" ' + (lead.Status === "" ? "selected" : "") + '>Select Status</option>' +
                    '<option value="Cold" ' + (lead.Status === "Cold" ? "selected" : "") + '>Cold</option>' +
                    '<option value="Warm" ' + (lead.Status === "Warm" ? "selected" : "") + '>Warm</option>' +
                    '<option value="Hot" ' + (lead.Status === "Hot" ? "selected" : "") + '>Hot</option>' +
                    '</select>' +
                    '</td>' +
                    '<td class="col-assign" data-label="Assign Lead" style="text-align:center;">' +
                    assignCellHtml +
                    '</td>' +
                    '<td style="text-align:center;">' +
                    '<button type="button" class="btn btn-primary btn-sm" onclick="OpenFollowUp(' + lead.ID + ')">' +
                    '<i class="fa fa-phone"></i> Follow Up' +
                    '</button>' +
                    '</td>' +
                    '</tr>';

                tbody.append(row);
            });

            initDealerDropdowns();
        }

        function formatKeyValueJson(jsonStr) {
            if (!jsonStr) return "";
            var obj = JSON.parse(jsonStr);
            var html = "";
            for (var key in obj) {
                html += "<b>" + escapeHtml(key) + "</b> : " + escapeHtml(obj[key]) + "<br/>";
            }
            return html;
        }

        function formatOtherDetailsJson(jsonStr) {
            if (!jsonStr) return "";
            var obj = JSON.parse(jsonStr);
            var html = "";
            for (var key in obj) {
                html += "<div style='margin-bottom:12px;'><b>" + escapeHtml(key) + "</b><br/>" + escapeHtml(obj[key]) + "</div>";
            }
            return html;
        }

        function escapeHtml(str) {
            return $('<div>').text(str).html();
        }

        function ChangeStatusColor(ctrl) {
            ctrl.classList.remove("status-cold", "status-warm", "status-hot", "status-blank");
            switch (ctrl.value) {
                case "Cold": ctrl.classList.add("status-cold"); break;
                case "Warm": ctrl.classList.add("status-warm"); break;
                case "Hot": ctrl.classList.add("status-hot"); break;
                default: ctrl.classList.add("status-blank"); break;
            }
        }

        function UpdateLeadStatus(ctrl) {
            ChangeStatusColor(ctrl);
            var leadId = ctrl.getAttribute("data-lead-id");
            var newStatus = ctrl.value;

            PageMethods.UpdateLeadStatus(leadId, newStatus, function () { }, function (error) {
                alert("Failed to update status: " + error.get_message());
            });
        }

        function AssignDealer(ctrl) {
            var leadId = $(ctrl).data("lead-id");
            var dealerId = $(ctrl).val();

            if (dealerId == "")
                return;

            $("#hdAssignLeadId").val(leadId);
            $("#hdDealerId").val(dealerId);
            $("#txtAdminReminder").val("");

            $("#assignDealerModal").modal("show");
        }

        function SaveDealerAssignment() {

            var leadId = $("#hdAssignLeadId").val();
            var dealerId = $("#hdDealerId").val();
            var reminder = $("#txtAdminReminder").val();

            if (reminder == "") {
                alert("Please select reminder date.");
                return;
            }

            PageMethods.AssignDealerToLead(
                leadId,
                dealerId,
                reminder,

                function (msg) {

                    alert(msg);

                    $("#assignDealerModal").modal("hide");

                    searchLeads();
                },

                function (err) {

                    alert(err.get_message());

                });

        }

        function initDealerFilterDropdown() {
            if (currentUserRole === "Dealer") return;

            var $ddl = $("#ddlDealerFilter");
            var previousSelection = $ddl.val() || [];

            if ($ddl.hasClass("select2-hidden-accessible")) {
                $ddl.select2("destroy");
            }

            $ddl.empty();

            dealersList.forEach(function (dealer) {
                var selected = previousSelection.indexOf(dealer.ID) > -1 ? "selected" : "";
                $ddl.append('<option value="' + dealer.ID + '" ' + selected + '>' + escapeHtml(dealer.DealerName) + '</option>');
            });

            $ddl.select2({
                width: '100%',
                placeholder: "Search dealers...",
                allowClear: true,
                closeOnSelect: true,
                dropdownAutoWidth: false
            });

            $ddl.off("change.dealerFilter").on("change.dealerFilter", function () {
                renderDealerBadges();
                searchLeads();
            });

            renderDealerBadges(); // show badges for the preserved selection right away
        }

        function renderDealerBadges() {
            var $ddl = $("#ddlDealerFilter");
            var $container = $("#selectedDealerBadges");
            $container.empty();

            var selectedIds = $ddl.val() || [];

            selectedIds.forEach(function (id) {
                var dealer = dealersList.find(function (d) { return d.ID === id; });
                if (!dealer) return;

                var $badge = $(
                    '<div class="dealer-badge" data-id="' + id + '">' +
                    '<span title="' + escapeHtml(dealer.DealerName) + '">' + escapeHtml(dealer.DealerName) + '</span>' +
                    '<span class="dealer-badge-remove" data-id="' + id + '">&times;</span>' +
                    '</div>'
                );
                $container.append($badge);
            });
        }

        $(document).on("click", ".dealer-badge-remove", function () {
            var idToRemove = $(this).data("id").toString();
            var $ddl = $("#ddlDealerFilter");
            var current = $ddl.val() || [];
            var updated = current.filter(function (id) { return id !== idToRemove; });

            $ddl.val(updated).trigger("change.select2").trigger("change");
        });

        function initDealerDropdowns() {

            $(".ddl-dealer").each(function () {
                if (!$(this).hasClass("select2-hidden-accessible")) {
                    $(this).select2({
                        width: '100% !important',
                        dropdownAutoWidth: false,
                        dropdownParent: $('body')
                    });
                }
            });
        }

        function searchLeads() {
            var searchTerm = $("#txtcompanyname").val();
            var pageSize = parseInt($("#ddlPageSize").val());
            var statusFilter = $("#ddlStatusFilter").val();
            var assignedFilter = $("#ddlAssignedFilter").val();

            var dealerFilter = "";
            if (currentUserRole !== "Dealer") {
                var selectedDealers = $("#ddlDealerFilter").val(); // array or null
                dealerFilter = selectedDealers ? selectedDealers.join(",") : "";
            }

            PageMethods.SearchLeads(searchTerm, pageSize, statusFilter, assignedFilter, dealerFilter, function (result) {
                renderLeadsTable(JSON.parse(result));
            }, function (error) {
                console.error("Search failed: " + error.get_message());
            });
        }

        function clearFilters() {
            $("#txtcompanyname").val("");
            $("#ddlStatusFilter").val("");
            $("#ddlAssignedFilter").val("Not Assigned");
            $("#ddlPageSize").val("25");

            if (currentUserRole !== "Dealer" && $("#ddlDealerFilter").hasClass("select2-hidden-accessible")) {
                $("#ddlDealerFilter").val(null).trigger("change.select2").trigger("change");
                // triggers "change.dealerFilter" above, which calls renderDealerBadges() + searchLeads()
            }

            searchLeads();
        }

        var searchDebounce;
        function debounceSearch() {
            clearTimeout(searchDebounce);
            searchDebounce = setTimeout(searchLeads, 300);
        }

        $(document).ready(function () {

            if (currentUserRole === "Dealer") {
                $("#ddlAssignedFilter").val("Assigned").prop("disabled", true);
                $("#rolewiseView").addClass("role-hidden");
                $("#dealerFilterWrapper").addClass("role-hidden");
            }

            loadDealers(function () {
                initDealerFilterDropdown();
                searchLeads(); // initial load
            });

            $("#txtcompanyname").on("keyup", function () {
                debounceSearch();
            });

            $("#ddlPageSize,#ddlAssignedFilter").on("change", function () {
                searchLeads();
            });

            $("#ddlStatusFilter").on("change", function () {
                searchLeads();
            });

            $("#btnSyncLeads").click(function () {
                $("#syncStatus").html("<span class='text-primary'>Syncing...</span>");
                $.ajax({
                    type: "POST",
                    url: "GetLeads.aspx/GenerateLongToken",   // Change path if needed
                    data: "{}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",

                    success: function (response) {
                        $("#syncStatus").html("<span class='text-success'>" + response.d + "</span>");
                        loadDealers(function () {
                            initDealerFilterDropdown();
                            searchLeads();   // refresh data without navigating away
                        });
                    },

                    error: function (xhr) {

                        console.log(xhr.responseText);

                        $("#syncStatus").html("<span class='text-danger'>Sync Failed</span>");

                        alert(xhr.responseText);

                    }

                });
            });
        });

        $(document).on("select2:select", ".ddl-dealer", function () {
            AssignDealer(this);
        });

        $(document).on("scroll", ".table-responsive", function () {
            $(".ddl-dealer").each(function () {
                if ($(this).hasClass("select2-hidden-accessible")) {
                    $(this).select2("close");
                }
            });
        });

        function ShowHistory() {

            $("#followUpForm").hide();

            $("#historySection").show();

            LoadHistory();

        }

        function ShowFollowUpForm() {

            $("#historySection").hide();

            $("#followUpForm").show();

        }

        function OpenFollowUp(id) {

            $("#hdLeadId").val(id);

            $("#txtFeedback").val("");

            $("#ddlCallStatus").val("");

            $("#txtReminder").val("");

            $("#historyDiv").html("");

            $("#historySection").hide();

            $("#followUpForm").show();

            $("#followUpModal").modal("show");
        }

        function SaveFollowUp() {

            var leadId = $("#hdLeadId").val();

            var feedback = $("#txtFeedback").val();

            var status = $("#ddlCallStatus").val();

            var reminder = $("#txtReminder").val();


            // Validation
            if (feedback == "") {
                alert("Please enter call feedback.");
                $("#txtFeedback").focus();
                return;
            }

            if (status == "") {
                alert("Please select call status.");
                $("#ddlCallStatus").focus();
                return;
            }

            // Reminder is mandatory only for Follow-Up
            if (status === "Follow-Up" && reminder == "") {
                alert("Please select the next reminder date.");
                $("#txtReminder").focus();
                return;
            }

            PageMethods.SaveFollowUp(
                leadId,
                feedback,
                status,
                reminder,
                function (msg) {
                    alert(msg);

                    $("#txtFeedback").val("");
                    $("#ddlCallStatus").val("");
                    $("#txtReminder").val("");
                },

                function (err) {
                    alert(err.get_message());
                });
        }

        $(document).on("change", "#ddlCallStatus", function () {

            if ($(this).val() === "Follow-Up") {
                $("#spReminder").show();
                $("#txtReminder").prop("required", true);
            }
            else {
                $("#spReminder").hide();
                $("#txtReminder").prop("required", false);
                $("#txtReminder").val("");
            }

        });

        function LoadHistory() {

            var leadId = $("#hdLeadId").val();

            PageMethods.GetFollowUpHistory(leadId,

                function (result) {

                    var data = JSON.parse(result);

                    var html = "";

                    if (data.length == 0) {
                        $("#historyDiv").html("<div class='alert alert-info'>No follow-up history found.</div>");
                        return;
                    }

                    html += "<table class='table table-bordered table-striped'>";
                    html += "<thead>";
                    html += "<tr>";
                    html += "<th>Date</th>";
                    html += "<th>Feedback</th>";
                    html += "<th>Status</th>";
                    html += "<th>Reminder</th>";
                    html += "<th>User</th>";
                    html += "</tr>";
                    html += "</thead><tbody>";

                    $.each(data, function (i, v) {

                        html += "<tr>";
                        html += "<td>" + (v.FollowDate || "") + "</td>";
                        html += "<td><div class='scroll-box'>" + (v.Feedback || "") + "</div></td>";
                        html += "<td>" + (v.Status || "") + "</td>";
                        html += "<td>" + (v.NextReminder || "") + "</td>";
                        html += "<td>" + (v.UserName || "") + "</td>";
                        html += "</tr>";

                    });

                    html += "</tbody></table>";

                    $("#historyDiv").html(html);

                },

                function (err) {
                    alert(err.get_message());
                });

        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex justify-content-between align-items-center">

                    <h3 class="m-0 font-weight-bold">
                        <b>Meta Lead List</b>
                    </h3>

                    <div class="d-flex align-items-center" id="rolewiseView">

                        <span id="syncStatus" class="me-3 text-success fw-bold"></span>

                        <button type="button" id="btnSyncLeads" class="btn btn-outline-dark">
                            <i class="fa fa-refresh"></i>Sync Leads Now
                        </button>

                    </div>

                </div>
                <div class="card-body">
                    <div class="filter-bar">
                        <div class="row align-items-end">
                            <div class="col-12 mb-2 mb-md-0 col-md-2">
                                <label class="form-label fw-bold">Search</label>
                                <input type="text" id="txtcompanyname" class="form-control" placeholder="Search by name, email..." autocomplete="off" />
                            </div>

                            <div class="col-12 col-md-1 mb-2 mb-md-0">
                                <label class="form-label fw-bold">Status</label>
                                <select id="ddlStatusFilter" class="form-control">
                                    <option value="">All</option>
                                    <option value="Cold">Cold</option>
                                    <option value="Warm">Warm</option>
                                    <option value="Hot">Hot</option>
                                </select>
                            </div>

                            <div class="col-12 col-md-2 mb-2 mb-md-0">
                                <label class="form-label fw-bold">Assigned/Not Assigned</label>
                                <select id="ddlAssignedFilter" class="form-control">
                                    <option value="Not Assigned">Not Assigned</option>
                                    <option value="Assigned">Assigned</option>
                                    <option value="">All</option>
                                </select>
                            </div>

                            <div class="col-12 col-md-3 mb-2 mb-md-0" id="dealerFilterWrapper">
                                <label class="form-label fw-bold">Dealer</label>
                                <select id="ddlDealerFilter" class="form-control" multiple="multiple">
                                </select>
                            </div>

                            <div class="col-12 col-md-1 mb-2 mb-md-0 d-flex align-items-end">
                                <button type="button" id="btnRefresh" class="btn btn-outline-danger" onclick="clearFilters();" title="Reset filters">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                            </div>

                            <div class="col-md-3 d-flex justify-content-end">
                                <div style="width: 130px;">
                                    <label class="form-label fw-bold d-block">Show</label>
                                    <select id="ddlPageSize" class="form-control">
                                        <option value="25" selected="selected">25 rows</option>
                                        <option value="50">50 rows</option>
                                        <option value="100">100 rows</option>
                                        <option value="0">All rows</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row align-items-center">
                            <div id="selectedDealerBadges" class="dealer-badge-grid"></div>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table leads-table" id="leadsTable">
                            <thead>
                                <tr>
                                    <th style="text-align: center;">Sr No.</th>
                                    <th class="col-personal" style="text-align: center;">Personal Info</th>
                                    <th style="text-align: center;">Lead Date</th>
                                    <th class="col-other" style="text-align: center;">Other Info</th>
                                    <th style="text-align: center;">Status</th>
                                    <th class="col-assign" style="text-align: center;">Assign Lead</th>
                                    <th style="text-align: center;">Follow Up</th>
                                </tr>
                            </thead>
                            <tbody id="leadsTableBody"></tbody>
                        </table>
                    </div>

                    <div class="modal fade" id="followUpModal" tabindex="-1">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <div class="modal-header bg-primary text-white">
                                    <h5 class="modal-title">
                                        <i class="fa fa-phone"></i>Lead Follow Up
                                    </h5>
                                    <button type="button"
                                        class="btn-close btn-close-white"
                                        data-bs-dismiss="modal">
                                    </button>
                                </div>
                                <div class="modal-body">

                                    <input type="hidden" id="hdLeadId" />

                                    <!-- ================= FOLLOW UP FORM ================= -->
                                    <div id="followUpForm">

                                        <div class="row">

                                            <div class="col-md-12 mb-3">
                                                <label class="form-label">Call Feedback</label>

                                                <textarea id="txtFeedback"
                                                    class="form-control"
                                                    rows="5"
                                                    placeholder="Enter call feedback..."></textarea>
                                            </div>

                                            <div class="col-md-6 mb-3">

                                                <label class="form-label">Status</label>

                                                <select id="ddlCallStatus"
                                                    class="form-select">

                                                    <option value="">-- Select Status --</option>
                                                    <option value="Follow-Up">Follow-Up</option>
                                                    <option value="Interested">Interested</option>
                                                    <option value="Not Interested">Not Interested</option>
                                                    <option value="Won">Won</option>
                                                    <option value="Lost">Lost</option>
                                                    <option value="Closed">Closed</option>

                                                </select>

                                            </div>

                                            <div class="col-md-6 mb-3">

                                                <label class="form-label">
                                                    Next Reminder
                                            <span id="spReminder"
                                                style="display: none; color: red">*</span>
                                                </label>

                                                <input type="date"
                                                    id="txtReminder"
                                                    class="form-control" />

                                            </div>

                                        </div>

                                        <hr />

                                        <div class="text-end">

                                            <button type="button"
                                                class="btn btn-success"
                                                onclick="SaveFollowUp()">

                                                <i class="fa fa-save"></i>
                                                Save Follow Up

                                            </button>

                                            <button type="button"
                                                class="btn btn-info"
                                                onclick="ShowHistory()">

                                                <i class="fa fa-history"></i>
                                                View History

                                            </button>

                                        </div>

                                    </div>

                                    <!-- ================= HISTORY ================= -->

                                    <div id="historySection" style="display: none;">

                                        <div class="d-flex justify-content-between align-items-center mb-3">

                                            <h5 class="mb-0">
                                                <i class="fa fa-history"></i>
                                                Follow Up History
                                            </h5>

                                            <button type="button"
                                                class="btn btn-secondary"
                                                onclick="ShowFollowUpForm()">

                                                <i class="fa fa-arrow-left"></i>
                                                Back

                                            </button>

                                        </div>

                                        <div id="historyDiv"></div>

                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="modal fade" id="assignDealerModal" tabindex="-1">
                        <div class="modal-dialog">
                            <div class="modal-content">

                                <div class="modal-header bg-primary text-white">
                                    <h5 class="modal-title">
                                        <i class="fa fa-user-plus"></i>
                                        Assign Dealer
                                    </h5>
                                    <button type="button"
                                        class="btn-close btn-close-white"
                                        data-dismiss="modal" data-bs-dismiss="modal">
                                    </button>
                                </div>

                                <div class="modal-body">

                                    <input type="hidden" id="hdAssignLeadId" />
                                    <input type="hidden" id="hdDealerId" />

                                    <label>Next Reminder <span style="color: red">*</span></label>

                                    <input type="date"
                                        id="txtAdminReminder"
                                        class="form-control" />

                                </div>

                                <div class="modal-footer">

                                    <button class="btn btn-success"
                                        onclick="SaveDealerAssignment();">
                                        Assign Dealer
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
