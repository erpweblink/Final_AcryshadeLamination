<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master"
    AutoEventWireup="true"
    CodeFile="WhatsAppLeads.aspx.cs"
    Inherits="WhatsAppLeads" %>

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

        /* ===== Status Badges (pill-style) ===== */
        .ddl-status {
            border-radius: 20px !important;
            text-align: center;
            text-align-last: center;
            font-size: 13px;
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

        /* Feedback history entries (server already renders these as HTML) */
        #historyDiv div {
            font-size: 13.5px;
            line-height: 1.7;
        }

        #historyDiv hr {
            margin: 8px 0;
            border-color: #eef1f5;
        }

        /* Fixed modal height */
        #followUpModal .modal-dialog {
            max-width: 700px;
        }

        #historyDiv {
            max-height: 340px;
            overflow-y: auto;
            overflow-x: hidden;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 12px;
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
        var dealersList = [];

        function loadDealers(callback) {
            PageMethods.GetDealers(function (result) {
                dealersList = JSON.parse(result);
                if (callback) callback();
            }, function (error) {
                console.error("Failed to load dealers: " + error.get_message());
            });
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
            window.__lastLeads = leads || [];

            var tbody = $("#leadsTableBody");
            tbody.empty();

            if (!leads || leads.length === 0) {
                tbody.append('<tr><td colspan="8" class="text-center">No records found.</td></tr>');
                return;
            }

            leads.forEach(function (lead, index) {

                var statusClass = statusClassFor(lead.Status);

                var dealerOptions = '<option value="">-- Select Dealer --</option>';
                dealersList.forEach(function (dealer) {
                    var selected = (dealer.ID === lead.AssignTo) ? "selected" : "";
                    dealerOptions += '<option value="' + dealer.ID + '" ' + selected + '>' + escapeHtml(dealer.DealerName) + '</option>';
                });

                var urlCell = lead.CustomerURL
                    ? '<a class="url-chip" href="' + escapeHtml(lead.CustomerURL) + '" target="_blank"><i class="bi bi-box-arrow-up-right"></i>View Website</a>'
                    : '<span class="text-muted">&mdash;</span>';

                var row =
                    '<tr>' +
                    '<td data-label="Sr No." style="text-align:center;">' + (index + 1) + '</td>' +
                    '<td data-label="Name">' + escapeHtml(lead.Name) + '</td>' +
                    '<td data-label="Mobile Number">' + escapeHtml(lead.MobileNumber) + '</td>' +
                    '<td data-label="Service">' + escapeHtml(lead.Service) + '</td>' +
                    '<td data-label="Inquiry Date" class="lead-date-cell">' + escapeHtml(lead.CreatedAt) + '</td>' +
                    '<td data-label="Website">' + urlCell + '</td>' +
                    '<td data-label="Status" style="text-align:center;">' +
                    '<select class="form-control ddl-status ' + statusClass + '" data-lead-id="' + lead.LeadID + '" onchange="UpdateLeadStatus(this);">' +
                    '<option value="" ' + (!lead.Status ? "selected" : "") + '>Select Status</option>' +
                    '<option value="Hot" ' + (lead.Status === "Hot" ? "selected" : "") + '>Hot</option>' +
                    '<option value="Warm" ' + (lead.Status === "Warm" ? "selected" : "") + '>Warm</option>' +
                    '<option value="Cold" ' + (lead.Status === "Cold" ? "selected" : "") + '>Cold</option>' +
                    '</select>' +
                    '</td>' +
                    '<td data-label="Assign Dealer" style="text-align:center;">' +
                    '<select class="form-control ddl-dealer" data-lead-id="' + lead.LeadID + '">' +
                    dealerOptions +
                    '</select>' +
                    '</td>' +
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

        function ChangeStatusColor(ctrl) {
            ctrl.classList.remove("status-cold", "status-warm", "status-hot", "status-blank");
            ctrl.classList.add(statusClassFor(ctrl.value));
        }

        function UpdateLeadStatus(ctrl) {
            ChangeStatusColor(ctrl);
            var leadId = ctrl.getAttribute("data-lead-id");
            var newStatus = ctrl.value;

            PageMethods.UpdateLeadStatus(parseInt(leadId, 10), newStatus, function () {
                // status saved silently, matches original page behaviour
            }, function (error) {
                alert("Status Update Failed: " + error.get_message());
            });
        }

        function AssignDealer(ctrl) {
            var leadId = ctrl.getAttribute("data-lead-id");
            var dealerId = ctrl.value;

            if (!dealerId) return;

            PageMethods.AssignDealerToLead(leadId, dealerId, function (result) {
                if (result && result.indexOf("Error") === 0) {
                    alert(result);
                }
            }, function (error) {
                alert("Failed to assign dealer: " + error.get_message());
            });
        }

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
            var searchTerm = $("#txtSearch").val();
            var pageSize = parseInt($("#ddlPageSize").val());
            var statusFilter = $("#ddlStatusFilter").val();

            PageMethods.SearchLeads(searchTerm, pageSize, statusFilter, function (result) {
                renderLeadsTable(JSON.parse(result));
            }, function (error) {
                console.error("Search failed: " + error.get_message());
            });
        }

        function clearFilters() {
            $("#txtSearch").val("");
            $("#ddlStatusFilter").val("");
            $("#ddlPageSize").val("25");
            searchLeads();
        }

        var searchDebounce;
        function debounceSearch() {
            clearTimeout(searchDebounce);
            searchDebounce = setTimeout(searchLeads, 300);
        }

        $(document).ready(function () {
            loadDealers(function () {
                searchLeads(); // initial load
            });

            $("#txtSearch").on("keyup", function () {
                debounceSearch();
            });

            $("#ddlPageSize").on("change", function () {
                searchLeads();
            });

            $("#ddlStatusFilter").on("change", function () {
                searchLeads();
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

        // ================= Follow Up modal =================

        function OpenFollowUp(id) {
            $("#hdLeadId").val(id);
            $("#txtFeedback").val("");
            $("#txtFollowDate").val("");
            $("#ddlCallStatus").val("");
            $("#spReminder").hide();

            $("#followUpForm").show();
            $("#historySection").hide();

            $("#followUpModal").modal("show");
        }

        $(document).on("change", "#ddlCallStatus", function () {
            if ($(this).val() === "Follow-Up") {
                $("#spReminder").show();
            } else {
                $("#spReminder").hide();
            }
        });

        function ShowHistory() {
            $("#followUpForm").hide();
            $("#historySection").show();

            LoadHistory($("#hdLeadId").val());
        }

        function ShowFollowUpForm() {
            $("#historySection").hide();
            $("#followUpForm").show();
        }

        function LoadHistory(leadId) {
            // FeedbackHistory comes back from SearchLeads already as built HTML,
            // so we just find it on the row we already rendered rather than a
            // second round trip.
            var lead = window.__lastLeads && window.__lastLeads.find(function (l) { return l.LeadID == leadId; });
            var html = lead && lead.FeedbackHistory ? lead.FeedbackHistory : "";

            $("#historyDiv").html(html || '<div class="text-muted">No follow-up history yet.</div>');
        }

        function saveFeedback() {
            var leadId = $("#hdLeadId").val();
            var status = $("#ddlCallStatus").val();
            var feedback = $("#txtFeedback").val();
            var followDate = $("#txtFollowDate").val();

            if (feedback.trim() === "") {
                alert("Please enter feedback");
                $("#txtFeedback").focus();
                return;
            }

            if (status === "") {
                alert("Please select a status");
                $("#ddlCallStatus").focus();
                return;
            }

            if (status === "Follow-Up" && followDate === "") {
                alert("Please select the follow up date");
                $("#txtFollowDate").focus();
                return;
            }

            PageMethods.SaveFeedback(parseInt(leadId, 10), status, feedback, followDate, function (result) {
                if (result === "Success") {
                    alert("Feedback Saved Successfully");
                    $("#txtFeedback").val("");
                    $("#txtFollowDate").val("");
                    $("#ddlCallStatus").val("");
                    $("#spReminder").hide();
                    $("#followUpModal").modal("hide");
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
            <h3 class="m-0 font-weight-bold"><b>WhatsApp Leads List</b></h3>
        </div>

        <div class="card-body">

            <div class="filter-bar">
                <div class="row align-items-end">
                    <div class="col-12 mb-2 mb-md-0 col-md-4">
                        <label class="form-label fw-bold">Search</label>
                        <input type="text" id="txtSearch" class="form-control" placeholder="Search by name, mobile, service..." autocomplete="off" />
                    </div>

                    <div class="col-12 col-md-2 mb-2 mb-md-0">
                        <label class="form-label fw-bold">Status</label>
                        <select id="ddlStatusFilter" class="form-control">
                            <option value="">All</option>
                            <option value="Hot">Hot</option>
                            <option value="Warm">Warm</option>
                            <option value="Cold">Cold</option>
                        </select>
                    </div>

                    <div class="col-12 col-md-2 mb-2 mb-md-0 d-flex align-items-end">
                        <button type="button" id="btnRefresh" class="btn btn-outline-danger" onclick="clearFilters();" title="Reset filters">
                            <i class="bi bi-arrow-clockwise"></i>
                        </button>
                    </div>

                    <div class="col-md-4 d-flex justify-content-end">
                        <div style="width: 150px;">
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
            </div>

            <div class="table-responsive">
                <table class="table leads-table" id="leadsTable">
                    <thead>
                        <tr>
                            <th style="text-align: center;">Sr No.</th>
                            <th style="text-align: center;">Name</th>
                            <th style="text-align: center;">Mobile Number</th>
                            <th style="text-align: center;">Service</th>
                            <th style="text-align: center;">Inquiry Date</th>
                            <th style="text-align: center;">Website</th>
                            <th style="text-align: center;">Status</th>
                            <th style="text-align: center;">Assign Dealer</th>
                            <th style="text-align: center;">Follow Up</th>
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

        </div>
    </div>
</asp:Content>
