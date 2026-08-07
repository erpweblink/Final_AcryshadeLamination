<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master"
    AutoEventWireup="true"
    CodeFile="EnquiryList.aspx.cs"
    Inherits="EnquiryList" %>

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

        #btnAssign:hover {
            transform: rotate(-25deg);
        }

        #btnSearch:hover {
            transform: rotate(-25deg);
        }

        #btnTrash:hover {
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
            table-layout: fixed;
            width: 100%;
        }

        .col-checkbox {
            width: 40px;
        }

        .col-sr {
            width: 60px;
        }

        .col-personal {
            width: 200px;
        }

        .col-other {
            width: 480px;
        }

        .col-sales {
            width: 180px;
        }

        .col-status {
            width: 140px;
        }

        .col-assign {
            width: 280px;
        }

        .col-follow {
            width: 140px;
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

        /* ===== Status Badges (pill-style) ===== */
        .ddl-status {
            border-radius: 20px !important;
            text-align: center;
            text-align-last: center;
            font-size: 11px;
            letter-spacing: 0.3px;
            padding: 6px 12px !important;
            height: auto !important;
            cursor: pointer;
            box-shadow: 0 1px 3px rgba(0,0,0,0.15);
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
            color: #1a4fc8 !important;
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

        .select2-container--default .select2-selection--single .select2-selection__rendered {
            line-height: 40px;
            color: #495057;
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

        /* ===== Website link chip ===== */
        .url-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 20px;
            background: #eef2f9;
            color: #2d6be0 !important;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            border: 1px solid #d7e2f6;
            transition: background-color .15s;
        }

            .url-chip:hover {
                background: #dfe8fb;
                text-decoration: none;
                color: #1a4fc8 !important;
            }

        /* Fixed modal height */
        #followUpModal .modal-dialog {
            max-width: 900px;
        }

        #followUpModal .modal-body {
            overflow: hidden;
        }

        #historySection {
            height: 100%;
        }

        #historyDiv {
            height: 340px;
            overflow-y: auto;
            overflow-x: hidden;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 10px;
            background: #fff;
        }

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
                margin-top: 16px;
            }

        .select2-results__option[aria-selected="true"] {
            background-color: #e7f1ff !important;
            color: #0a58ca !important;
            font-weight: 600;
        }

            .select2-results__option[aria-selected="true"]::after {
                content: " \2713";
                color: #0a58ca;
            }

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

        .lead-checkbox, #chkSelectAll {
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        /* ===== Responsive: stack the table on small screens ===== */
        @media (max-width: 768px) {
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

            .select2-container {
                width: 100% !important;
            }
        }
    </style>

    <script type="text/javascript">
        var currentUserRole = "<%= System.Web.HttpContext.Current.Session["Role"] != null ? System.Web.HttpContext.Current.Session["Role"].ToString() : "" %>";
        var dealersList = [];
        var salesPersonList = [];

        function loadDealers(callback) {
            PageMethods.GetDealers(function (result) {
                dealersList = JSON.parse(result);
                if (callback) callback();
            }, function (error) {
                console.error("Failed to load dealers: " + error.get_message());
            });
        }

        function loadSalesPerson(callback) {
            PageMethods.GetSalesPerson(function (result) {
                salesPersonList = JSON.parse(result);
                if (callback) callback();
            }, function (error) {
                console.error("Failed to load Sales Person: " + error.get_message());
            });
        }

        function initSalesFilterDropdown() {
            if (currentUserRole === "Dealer" || currentUserRole === "Sales") return;

            var $ddl = $("#ddlSalesPerson");

            $ddl.empty();
            $ddl.append('<option value="" selected>Select Sales Person</option>');

            $.each(salesPersonList, function (i, dealer) {
                $ddl.append(
                    $('<option>', {
                        value: dealer.ID,
                        text: dealer.SalesPerson
                    })
                );
            });

            $ddl.select2({
                width: '100%',
                closeOnSelect: true,
                dropdownAutoWidth: false
            });

            $ddl.val("");
        }

        function escapeHtml(str) {
            return $('<div>').text(str || "").html();
        }

        function statusClassFor(status) {
            if (status === "Hot") return "status-hot";
            if (status === "Warm") return "status-warm";
            if (status === "Cold") return "status-cold";
            return "status-blank";
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

            // Reset "select all" whenever the grid is re-rendered/re-searched
            $("#chkSelectAll").prop("checked", false);

            var showCheckboxColumn = (currentUserRole !== "Sales" && currentUserRole !== "Dealer");
            var showSalesPersonColumn = (currentUserRole !== "Sales" && currentUserRole !== "Dealer");
            var showAssignColumn = (currentUserRole !== "Dealer");

            if (!leads || leads.length === 0) {
                var colCount = 6; // Sr No, Name, Mobile, Message, Date, Status, Follow Up
                if (showCheckboxColumn) colCount++;
                if (showSalesPersonColumn) colCount++;
                if (showAssignColumn) colCount++;
                tbody.append('<tr><td colspan="' + colCount + '" class="text-center">No records found.</td></tr>');
                return;
            }

            leads.forEach(function (lead, index) {

                var statusClass = statusClassFor(lead.Status);

                var checkboxCellHtml = "";
                if (showCheckboxColumn) {
                    checkboxCellHtml =
                        '<td class="col-checkbox" data-label="Select" style="text-align:center;">' +
                        '<input type="checkbox" class="lead-checkbox" data-lead-id="' + lead.LeadID + '" />' +
                        '</td>';
                }

                var salesPersonTdHtml = "";
                if (showSalesPersonColumn) {
                    var salesPersonName = "N/A";
                    if (lead.SalesPerson) {
                        var assignedSalesPerson = salesPersonList.find(function (s) { return s.ID === lead.SalesPerson; });
                        if (assignedSalesPerson) salesPersonName = escapeHtml(assignedSalesPerson.SalesPerson);
                    }
                    salesPersonTdHtml =
                        '<td data-label="Sales Person" style="text-align:center;"><small class="fw-bold" style="color: #63769b !important;"><i>' + salesPersonName + '</i></small></td>';
                }

                var assignTdHtml = "";
                if (showAssignColumn) {
                    var dealerOptions = '<option value="">-- Select Dealer --</option>';
                    dealersList.forEach(function (dealer) {
                        var selected = (dealer.ID === lead.AssignedTo) ? "selected" : "";
                        dealerOptions += '<option value="' + dealer.ID + '" ' + selected + '>' + escapeHtml(dealer.DealerName) + '</option>';
                    });

                    // Show copy icon immediately if a dealer is already assigned on render
                    var copyIconDisplay = lead.AssignedTo ? "inline-block" : "none";

                    var assignCellHtml =
                        '<div style="display:flex; align-items:center; gap:6px;">' +
                        '<select class="form-control ddl-dealer" data-lead-id="' + lead.ID + '">' +
                        dealerOptions +
                        '</select>' +
                        '<i class="bi bi-copy copy-dealer-icon" ' +
                        'data-lead-id="' + lead.ID + '" ' +
                        'title="Copy dealer details" ' +
                        'style="cursor:pointer; color:#1a4fc8; font-size:19px; display:' + copyIconDisplay + ';"></i>' +
                        '</div>';

                    assignTdHtml =
                        '<td class="col-assign" data-label="Assign Lead" style="text-align:center;">' +
                        assignCellHtml +
                        '</td>';
                }

                var urlCell = lead.CustomerURL
                    ? '<a class="url-chip" href="' + escapeHtml(lead.CustomerURL) + '" target="_blank"><i class="bi bi-box-arrow-up-right"></i>View Website</a>'
                    : '<span class="text-muted">&mdash;</span>';

                var row =
                    '<tr>' +
                    checkboxCellHtml +
                    '<td data-label="Sr No." style="text-align:center;">' + (index + 1) + '</td>' +
                    '<td data-label="Name">' + escapeHtml(lead.Name) + '</td>' +
                    '<td data-label="Mobile Number">' + formatMobileNumberCell(lead.MobileNumber) + '</td>' +
                    '<td data-label="Message"><div class="scroll-box">' + escapeHtml(lead.Service) + '</div></td>' +
                    '<td data-label="Inquiry Date" class="lead-date-cell">' + lead.CreatedAt + '</td>' +
                    salesPersonTdHtml +
                    '<td data-label="Status" style="text-align:center;">' +
                    '<select class="form-control ddl-status ' + statusClass + '" data-lead-id="' + lead.LeadID + '" onchange="UpdateLeadStatus(this);">' +
                    '<option value="" ' + (!lead.Status ? "selected" : "") + '>Select Status</option>' +
                    '<option value="Cold" ' + (lead.Status === "Cold" ? "selected" : "") + '>Cold</option>' +
                    '<option value="Warm" ' + (lead.Status === "Warm" ? "selected" : "") + '>Warm</option>' +
                    '<option value="Hot" ' + (lead.Status === "Hot" ? "selected" : "") + '>Hot</option>' +
                    '</select>' +
                    '</td>' +
                    assignTdHtml +
                    '<td data-label="Follow Up" style="text-align:center;">' +
                    '<button type="button" class="btn btn-primary btn-sm" onclick="OpenFollowUp(' + lead.LeadID + ');">' +
                    '<i class="fa fa-phone"></i> Follow Up' +
                    '</button>' +
                    '</td>' +
                    '</tr>';

                tbody.append(row);
            });

            initDealerDropdowns();
        }

        function formatMobileNumberCell(mobileNumber) {
            if (!mobileNumber) return "";

            var waLink = getWhatsappLink(mobileNumber);
            if (!waLink) {
                return escapeHtml(mobileNumber);
            }

            return '<a href="' + waLink + '" target="_blank" style="text-decoration:none; display:inline-flex; align-items:center; gap:4px; color:#2d6be0; font-weight:600;">' +
                escapeHtml(mobileNumber) +
                getWhatsappIconSvg() +
                '</a>';
        }

        function getWhatsappIconSvg() {
            return '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 32 32" style="vertical-align:middle;">' +
                '<path fill="#25D366" d="M16.001 3C9.373 3 4 8.373 4 15c0 2.386.7 4.61 1.902 6.481L4 29l7.72-1.87A11.94 11.94 0 0 0 16.001 27C22.629 27 28 21.627 28 15S22.629 3 16.001 3z"/>' +
                '<path fill="#FFF" d="M22.32 19.29c-.29.82-1.44 1.51-2.35 1.7-.63.13-1.45.24-4.22-.91-3.54-1.47-5.82-5.05-6-5.29-.17-.24-1.44-1.92-1.44-3.66 0-1.74.9-2.6 1.22-2.95.29-.32.66-.4.88-.4.22 0 .44.002.63.01.2.01.47-.08.74.56.29.68.97 2.35 1.06 2.52.09.17.15.36.03.6-.12.24-.18.38-.36.58-.18.2-.38.44-.54.6-.18.17-.37.36-.16.7.21.35.93 1.53 2 2.48 1.37 1.22 2.53 1.6 2.88 1.78.35.17.55.15.76-.09.21-.24.9-1.05 1.14-1.4.24-.35.47-.29.79-.17.32.12 2.02.95 2.37 1.12.35.17.58.26.66.4.09.16.09.87-.2 1.69z"/>' +
                '</svg>';
        }

        function getWhatsappLink(value) {
            if (!value) return null;

            var cleaned = String(value).trim();
            var digitsOnly = cleaned.replace(/[^\d+]/g, "");

            var withCountryCodeMatch = digitsOnly.match(/^\+(\d{1,3})(\d{10})$/);
            if (withCountryCodeMatch) {
                return "https://wa.me/" + withCountryCodeMatch[1] + withCountryCodeMatch[2];
            }

            var noPlusMatch = digitsOnly.match(/^(91|1|44|61|971)(\d{10})$/);
            if (noPlusMatch) {
                return "https://wa.me/" + noPlusMatch[1] + noPlusMatch[2];
            }

            var plainTenDigit = digitsOnly.match(/^\d{10}$/);
            if (plainTenDigit) {
                return "https://wa.me/91" + digitsOnly;
            }

            return null;
        }

        function ChangeStatusColor(ctrl) {
            ctrl.classList.remove("status-cold", "status-warm", "status-hot", "status-blank");
            ctrl.classList.add(statusClassFor(ctrl.value));
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

            // Same as LeadList: clearing the dealer removes the assignment immediately, no modal needed
            if (dealerId == "") {
                PageMethods.AssignDealerToLead(
                    leadId,
                    dealerId,
                    "",
                    function (msg) {
                        $("#assignDealerModal").modal("hide");
                        searchLeads();
                        alert(msg);
                    },
                    function (err) {
                        alert(err.get_message());
                    });
                return;
            }

            $("#hdAssignLeadId").val(leadId);
            $("#hdDealerId").val(dealerId);
            $("#txtAdminReminder").val("");

            $("#assignDealerModal").modal("show");
        }

        function SaveDealerAssignment() {
            var leadId = $("#hdAssignLeadId").val();
            var dealerId = $("#hdDealerId").val();
            var reminder = $("#txtAdminReminder").val();

            if (reminder === "") {
                alert("Please select reminder date.");
                return;
            }

            PageMethods.AssignDealerToLead(leadId, dealerId, reminder, function (msg) {
                $("#assignDealerModal").modal("hide");
                searchLeads();
                alert(msg);
            }, function (error) {
                alert("Failed to assign dealer: " + error.get_message());
            });
        }

        $(document).on('hidden.bs.modal', function () {
            if ($('.modal:visible').length === 0) {
                $('body').removeClass('modal-open');
                $('.modal-backdrop').remove();
            }
        });

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

            renderDealerBadges();
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

        function toggleSelectAll(ctrl) {
            $(".lead-checkbox").prop("checked", ctrl.checked);
        }

        function getSelectedLeadIds() {
            var ids = [];
            $(".lead-checkbox:checked").each(function () {
                ids.push($(this).data("lead-id").toString());
            });
            return ids;
        }

        function assignSalesPerson() {
            var salesPersonId = $("#ddlSalesPerson").val();

            if (!salesPersonId) {
                alert("Please select a Sales Person.");
                return;
            }

            var selectedLeadIds = getSelectedLeadIds();

            if (selectedLeadIds.length === 0) {
                alert("Please select at least one lead using the checkboxes.");
                return;
            }

            if (!confirm("Assign " + selectedLeadIds.length + " lead(s) to the selected Sales Person?")) {
                return;
            }

            PageMethods.AssignSalesPersonToLeads(
                selectedLeadIds.join(","),
                salesPersonId,
                function (msg) {
                    alert(msg);
                    $("#chkSelectAll").prop("checked", false);
                    searchLeads();
                },
                function (error) {
                    alert("Failed to assign Sales Person: " + error.get_message());
                }
            );
        }

        function removeData() {

            var selectedLeadIds = getSelectedLeadIds();

            if (selectedLeadIds.length === 0) {
                alert("Please select at least one lead using the checkboxes.");
                return;
            }

            PageMethods.RemoveLeads(
                selectedLeadIds.join(","),
                function (msg) {
                    alert(msg);
                    $("#chkSelectAll").prop("checked", false);
                    searchLeads();
                },
                function (error) {
                    alert("Failed to assign Sales Person: " + error.get_message());
                }
            );
        }

        function searchData() {
            searchLeads();
        }

        var searchRequestId = 0;
        function searchLeads() {
            var thisRequestId = ++searchRequestId;

            var searchTerm = $("#txtSearch").val();
            var pageSize = parseInt($("#ddlPageSize").val());
            var statusFilter = $("#ddlStatusFilter").val();
            var assignedFilter = $("#ddlAssignedFilter").val();
            var fromDate = $("#txtFromDate").val();
            var toDate = $("#txtToDate").val();

            var dealerFilter = "";
            if (currentUserRole !== "Dealer") {
                var selectedDealers = $("#ddlDealerFilter").val(); // array or null
                dealerFilter = selectedDealers ? selectedDealers.join(",") : "";
            }

            var salesPersonFilter = "";
            if (currentUserRole !== "Sales" && currentUserRole !== "Dealer") {
                salesPersonFilter = $("#ddlSalesPerson").val() || "";
            }

            PageMethods.SearchLeads(searchTerm, pageSize, statusFilter, assignedFilter, dealerFilter, fromDate, toDate, salesPersonFilter, function (result) {
                if (thisRequestId !== searchRequestId) return;
                renderLeadsTable(JSON.parse(result));
            }, function (error) {
                console.error("Search failed: " + error.get_message());
            });
        }

        function clearFilters() {
            $("#txtSearch").val("");
            $("#ddlStatusFilter").val("");
            $("#txtFromDate").val("");
            $("#txtToDate").val("");

            if (currentUserRole === "Dealer") {
                $("#ddlAssignedFilter").val("Assigned");
            } else {
                $("#ddlAssignedFilter").val("Not Assigned");
            }
            $("#ddlPageSize").val("25");

            if (currentUserRole !== "Dealer" && $("#ddlDealerFilter").hasClass("select2-hidden-accessible")) {
                $("#ddlDealerFilter").val(null).trigger("change.select2");
                renderDealerBadges();
            }

            if (currentUserRole !== "Sales" && currentUserRole !== "Dealer" && $("#ddlSalesPerson").hasClass("select2-hidden-accessible")) {
                $("#ddlSalesPerson").val("").trigger("change");
            }

            $("#chkSelectAll").prop("checked", false);

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
                $("#salesPersonWrapper").addClass("role-hidden");
                $("#dealerFilterWrapper").addClass("role-hidden");
                $("#dealerBadgesWrapper").addClass("role-hidden");
                $("#thCheckbox").addClass("role-hidden");
                $("#thSalesPerson").addClass("role-hidden");
                $("#thAssign").addClass("role-hidden");
                $("#lblAssignedFilter").text("Assigned/Not Assigned");
            } else if (currentUserRole === "Sales") {
                $("#salesPersonWrapper").addClass("role-hidden");
                $("#thCheckbox").addClass("role-hidden");
                $("#thSalesPerson").addClass("role-hidden");
                $("#lblAssignedFilter").text("Dealer Assigned/Not Assigned");
            } else {
                $("#lblAssignedFilter").text("Sales Assigned/Not Assigned");
            }

            loadSalesPerson(function () {
                initSalesFilterDropdown();

                loadDealers(function () {
                    initDealerFilterDropdown();
                    searchLeads(); // initial load - runs only once both lookup lists are ready
                });
            });

            $("#txtSearch").on("keyup", function () {
                debounceSearch();
            });

            $("#ddlPageSize, #ddlAssignedFilter").on("change", function () {
                searchLeads();
            });

            $("#ddlStatusFilter,#txtFromDate,#txtToDate").on("change", function () {
                searchLeads();
            });
        });

        // Show/hide copy icon whenever a dealer is picked/cleared
        $(document).on("change", ".ddl-dealer", function () {
            var $icon = $(this).closest("div").find(".copy-dealer-icon");
            var dealerId = $(this).val();
            $icon.css("display", dealerId ? "inline-block" : "none");
        });

        // Copy dealer details when the icon is clicked
        $(document).on("click", ".copy-dealer-icon", function () {
            var $icon = $(this);
            var $select = $icon.closest("div").find(".ddl-dealer");
            var dealerId = $select.val();

            if (!dealerId) return;

            var originalClass = $icon.attr("class");
            $icon.removeClass("bi-copy").addClass("bi-hourglass-split");

            PageMethods.GetDealerDetails(dealerId, function (result) {
                var dealer = JSON.parse(result);
                var formatted = formatDealerDetails(dealer);

                copyRichTextToClipboard(formatted.html, formatted.plainText);

                $icon.attr("class", originalClass);
                $icon.removeClass("bi-copy").addClass("bi-check2").css("color", "#28a745");
                setTimeout(function () {
                    $icon.attr("class", originalClass).css("color", "#1a4fc8");
                }, 1200);
            }, function (error) {
                $icon.attr("class", originalClass);
                alert("Failed to fetch dealer details: " + error.get_message());
            });
        });

        function formatDealerDetails(dealer) {
            var labelMap = {
                DealerName: "Dealer Name",
                CompanyName: "Company Name",
                MobileNo: "Mobile",
                Email: "Email",
                Address: "Address",
                City:"City"
            };

            var dealerName = (dealer.DealerName || "").trim();
            var companyName = (dealer.CompanyName || "").trim();
            var showCompanyName = companyName && companyName.toLowerCase() !== dealerName.toLowerCase();

            var order = ["DealerName", "CompanyName", "MobileNo", "Email", "Address", "City"];

            var htmlLines = [];
            var textLines = [];

            order.forEach(function (key) {
                if (key === "CompanyName" && !showCompanyName) return;

                if (!dealer.hasOwnProperty(key)) return;
                var value = dealer[key];
                if (!value) return;

                var label = labelMap[key] || key;

                htmlLines.push(
                    '<div style="margin-bottom:8px; line-height:1.6;">' +
                    '<b>' + escapeHtml(label) + ':</b> ' + escapeHtml(value) +
                    '</div>'
                );

                textLines.push(label + ": " + value);
            });

            return {
                html: htmlLines.join(""),
                plainText: textLines.join("\n\n")
            };
        }

        function copyRichTextToClipboard(html, plainText) {
            if (navigator.clipboard && window.ClipboardItem) {
                var htmlBlob = new Blob([html], { type: "text/html" });
                var textBlob = new Blob([plainText], { type: "text/plain" });

                var item = new ClipboardItem({
                    "text/html": htmlBlob,
                    "text/plain": textBlob
                });

                navigator.clipboard.write([item]).catch(function () {
                    fallbackCopy(plainText);
                });
            } else {
                fallbackCopy(plainText);
            }
        }

        function fallbackCopy(text) {
            var $temp = $("<textarea>").val(text).css({ position: "fixed", left: "-9999px" }).appendTo("body");
            $temp[0].select();
            try { document.execCommand("copy"); } catch (e) { }
            $temp.remove();
        }

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

        // ================= Follow Up modal =================

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
            $("#txtFollowDate").val("");
            $("#spReminder").hide();
            $("#historyDiv").html("");

            $("#historySection").hide();
            $("#followUpForm").show();

            $("#followUpModal").modal("show");
        }

        $(document).on("change", "#ddlCallStatus", function () {
            if ($(this).val() === "Follow-Up") {
                $("#spReminder").show();
                $("#txtFollowDate").prop("required", true);
            } else {
                $("#spReminder").hide();
                $("#txtFollowDate").prop("required", false);
                $("#txtFollowDate").val("");
            }
        });

        function LoadHistory() {
            var leadId = $("#hdLeadId").val();

            PageMethods.GetFollowUpHistory(leadId,
                function (result) {
                    var data = JSON.parse(result);

                    if (data.length == 0) {
                        $("#historyDiv").html("<div class='alert alert-info'>No follow-up history found.</div>");
                        return;
                    }

                    var html = "<table class='table table-bordered table-striped'>";
                    html += "<thead><tr>";
                    html += "<th>Date</th><th>Feedback</th><th>Status</th><th>Follow Up</th><th>User</th>";
                    html += "</tr></thead><tbody>";

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

        function saveFeedback() {
            var leadId = $("#hdLeadId").val();
            var status = $("#ddlCallStatus").val();
            var feedback = $("#txtFeedback").val();
            var followDate = $("#txtFollowDate").val();

            if (feedback.trim() === "") {
                $("#txtFeedback").focus();
                alert("Please enter feedback");
                return;
            }

            if (status === "") {
                $("#ddlCallStatus").focus();
                alert("Please select a status");
                return;
            }

            if (status === "Follow-Up" && followDate === "") {
                $("#txtFollowDate").focus();
                alert("Please select the follow up date");
                return;
            }

            PageMethods.SaveFeedback(parseInt(leadId, 10), status, feedback, followDate, function (result) {
                if (result === "Success") {
                    $("#txtFeedback").val("");
                    $("#txtFollowDate").val("");
                    $("#ddlCallStatus").val("");
                    $("#spReminder").hide();
                    alert("Feedback Saved Successfully");
                    searchLeads();
                } else {
                    alert(result);
                }
            }, function (error) {
                alert("Feedback Save Failed: " + error.get_message());
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

    <div class="card">
        <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
            <h3 class="m-0 font-weight-bold"><b>Website Enquiry List</b></h3>
        </div>

        <div class="card-body">

            <div class="filter-bar">
                <div class="row align-items-end">
                    <div class="col-12 mb-2 mb-md-0 col-md-2">
                        <label class="form-label fw-bold">Search</label>
                        <input type="text" id="txtSearch" class="form-control" placeholder="Search by name, mobile, service..." autocomplete="off" />
                    </div>
                    <div class="col-12 col-md-1 mb-2 mb-md-0">
                        <label class="form-label fw-bold">Status</label>
                        <select id="ddlStatusFilter" class="form-control">
                            <option value="">All</option>
                            <option value="Hot">Hot</option>
                            <option value="Warm">Warm</option>
                            <option value="Cold">Cold</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-3 mb-2 mb-md-0">
                        <label class="form-label fw-bold" id="lblAssignedFilter">Assigned/Not Assigned</label>
                        <select id="ddlAssignedFilter" class="form-control">
                            <option value="Not Assigned">Not Assigned</option>
                            <option value="Assigned">Assigned</option>
                            <option value="">All</option>
                        </select>
                    </div>
                    <div class="col-12 mb-2 mb-md-0 col-md-2">
                        <label class="form-label fw-bold">From Date</label>
                        <input type="date" id="txtFromDate" class="form-control" />
                    </div>
                    <div class="col-12 mb-2 mb-md-0 col-md-2">
                        <label class="form-label fw-bold">To Date</label>
                        <input type="date" id="txtToDate" class="form-control" />
                    </div>

                    <div class="col-md-2 col-12 mb-2 mb-md-0 d-flex justify-content-end ms-md-auto">
                        <div style="width: 130px;">
                            <label class="form-label fw-bold d-block">Show</label>
                            <select id="ddlPageSize" class="form-control">
                                <option value="25" selected="selected">25 rows</option>
                                <option value="50">50 rows</option>
                                <option value="100">100 rows</option>
                                <option value="0">All rows</option>
                            </select>
                        </div>
                        &nbsp;&nbsp;&nbsp;
                       
                        <div class="mt-4">
                            <button type="button" id="btnRefresh" class="btn btn-outline-danger" onclick="clearFilters();" title="Reset filters">
                                <i class="bi bi-arrow-clockwise"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <div class="row align-items-center">
                    <div class="col-12 col-md-5 mb-2 mb-md-0" id="salesPersonWrapper">
                        <div class="row align-items-end">
                            <div class="col-12 col-md-6 mb-2 mb-md-0">
                                <label class="form-label fw-bold">Sales Person</label>
                                <select id="ddlSalesPerson" class="form-control"></select>
                            </div>
                            <div class="col-12 col-md-3 d-flex justify-content-start gap-2">
                                <button type="button" id="btnAssign" class="btn btn-outline-success"
                                    title="Assign selected leads to this Sales Person" onclick="assignSalesPerson();">
                                    <i class="bi bi-person-check-fill"></i>
                                </button>
                                <button type="button" id="btnSearch" class="btn btn-outline-primary d-none" title="Search leads assigned to this Sales Person"
                                    onclick="searchData();">
                                    <i class="bi bi-search"></i>
                                </button>
                                <button type="button" id="btnTrash" class="btn btn-outline-danger" title="Delete Lead"
                                    onclick="removeData();">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 col-md-3 mb-2 mb-md-0" id="dealerFilterWrapper">
                        <label class="form-label fw-bold">Dealer</label>
                        <select id="ddlDealerFilter" class="form-control" multiple="multiple"></select>
                    </div>
                    <div class="col-12 col-md-4 mb-2 mb-md-0" id="dealerBadgesWrapper">
                        <div id="selectedDealerBadges" class="dealer-badge-grid"></div>
                    </div>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table leads-table" id="leadsTable">
                    <thead>
                        <tr>
                            <th id="thCheckbox" class="col-checkbox text-center">
                                <input type="checkbox"
                                    id="chkSelectAll"
                                    onclick="toggleSelectAll(this)"
                                    title="Select all" />
                            </th>
                            <th class="col-sr text-center">Sr No.</th>
                            <th class="col-personal text-center">Name</th>
                            <th class="col-status text-center">Mobile Number</th>
                            <th class="col-other text-center">Message</th>
                            <th class="col-status text-center">Enquiry Date</th>
                            <th id="thSalesPerson" class="col-sales text-center">Sales Person</th>
                            <th class="col-status text-center">Status</th>
                            <th id="thAssign" class="col-assign text-center">Assign Dealer</th>
                            <th class="col-follow text-center">Follow Up</th>
                        </tr>
                    </thead>
                    <tbody id="leadsTableBody"></tbody>
                </table>
            </div>

            <!-- Follow Up / Feedback Modal -->
            <div class="modal fade" id="followUpModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">

                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i class="fa fa-phone"></i>
                                Lead Feedback
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
                                        <label class="form-label">Feedback</label>

                                        <textarea id="txtFeedback"
                                            class="form-control"
                                            rows="5"
                                            placeholder="Enter feedback..."></textarea>
                                    </div>

                                    <div class="col-md-6 mb-3">

                                        <label class="form-label">Status</label>

                                        <select id="ddlCallStatus"
                                            class="form-select form-control">

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
                                            Follow Up Date
                                           
                                            <span id="spReminder"
                                                style="display: none; color: red">*</span>
                                        </label>

                                        <input type="date"
                                            id="txtFollowDate"
                                            class="form-control" />

                                    </div>

                                </div>

                                <hr />

                                <div class="text-end">

                                    <button type="button"
                                        class="btn btn-success"
                                        onclick="saveFeedback();">

                                        <i class="fa fa-save"></i>
                                        Save Follow Up
                                   
                                    </button>

                                    <button type="button"
                                        class="btn btn-info"
                                        onclick="ShowHistory();">

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
                                        Feedback History
                                    </h5>

                                    <button type="button"
                                        class="btn btn-secondary"
                                        onclick="ShowFollowUpForm();">

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

            <!-- Assign Dealer Modal -->
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

                            <input type="date" id="txtAdminReminder" class="form-control" />
                        </div>

                        <div class="modal-footer">
                            <button class="btn btn-success" onclick="SaveDealerAssignment();">
                                Assign Dealer
                           
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
