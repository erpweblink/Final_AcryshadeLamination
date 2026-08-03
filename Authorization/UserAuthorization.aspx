<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="UserAuthorization.aspx.cs" Inherits="UserAuthorization" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css" />
    <style>
        :root {
            --auth-accent: #5b78b1;
            --auth-accent-dark: #465e8f;
            --auth-pending: #e08a00;
            --auth-pending-bg: #fff3e0;
            --auth-completed: #1e9e5a;
            --auth-completed-bg: #e7f8ee;
        }

        .auth-card {
            border: none;
            border-radius: 14px;
            box-shadow: 0 2px 16px rgba(20, 30, 60, 0.08);
            overflow: hidden;
            width: 100%
        }

            .auth-card .card-header {
                background: linear-gradient(135deg, var(--auth-accent) 0%, var(--auth-accent-dark) 100%);
                border: none;
                padding: 1.15rem 1.5rem;
            }

        .auth-eyebrow {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .09em;
            color: rgba(255,255,255,.75);
            font-weight: 600;
        }

        .auth-card .card-header h3 {
            color: #fff;
        }

        .auth-card .card-header i.bi {
            color: #fff;
            font-size: 1.6rem;
        }

        /* ---- Selection controls ---- */
        .field-label {
            font-weight: 600;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: .04em;
            color: #212529; /* Dark text */
            margin-bottom: 6px;
            display: block;
        }

        select.form-control,
        input.form-control {
            border-radius: 8px;
            border: 1px solid #dde1e8;
            box-shadow: none;
            transition: border-color .15s ease, box-shadow .15s ease;
        }

        select.form-control,
        input.form-control {
            color: #212529 !important;
            font-weight: 500;
        }

            select.form-control option {
                color: #212529;
            }

            select.form-control:focus,
            input.form-control:focus {
                border-color: var(--auth-accent);
                box-shadow: 0 0 0 3px rgba(91, 120, 177, .15);
            }

        /* ---- Summary strip ---- */
        .summary-strip {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 1.75rem;
            background: #f8f9fc;
            border: 1px solid #eef0f5;
            border-radius: 12px;
            padding: 1rem 1.25rem;
            margin-top: 1.25rem;
            animation: fadeSlideIn .25s ease;
        }

        .summary-item .summary-value {
            font-size: 1.5rem;
            font-weight: 700;
            line-height: 1;
            color: #2c3345;
        }

        .summary-item .summary-label {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .05em;
            color: #8a90a2;
            margin-top: 2px;
        }

        .summary-item.completed .summary-value {
            color: var(--auth-completed);
        }

        .summary-item.pending .summary-value {
            color: var(--auth-pending);
        }

        .summary-progress {
            flex: 1 1 220px;
            min-width: 180px;
        }

            .summary-progress .progress {
                border-radius: 10px;
                background-color: #e9ecf3;
            }

            .summary-progress .progress-bar {
                background: linear-gradient(90deg, var(--auth-completed), #38c17a);
                transition: width .4s ease;
            }

        /* ---- User picker ---- */
        .filter-pill-group .btn {
            border-radius: 20px !important;
            font-size: 12.5px;
            font-weight: 600;
            padding: 5px 14px;
            border-color: #dde1e8;
            color: #6b7280;
        }

            .filter-pill-group .btn.active {
                background-color: var(--auth-accent);
                border-color: var(--auth-accent);
                color: #fff;
            }

        .user-search-wrap {
            position: relative;
        }

            .user-search-wrap i.bi-search {
                position: absolute;
                left: 12px;
                top: 50%;
                transform: translateY(-50%);
                color: #a3a9b7;
            }

            .user-search-wrap input {
                padding-left: 34px;
            }

        .user-list {
            max-height: 320px;
            overflow-y: auto;
            border: 1px solid #eef0f5;
            border-radius: 10px;
        }

            .user-list::-webkit-scrollbar {
                width: 8px;
            }

            .user-list::-webkit-scrollbar-thumb {
                background: #d7dbe6;
                border-radius: 8px;
            }

        .user-list-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 14px;
            border: none;
            border-bottom: 1px solid #f1f2f6;
            cursor: pointer;
            transition: background-color .12s ease;
        }

            .user-list-item:last-child {
                border-bottom: none;
            }

            .user-list-item:hover {
                background-color: #f6f8fc;
            }

            .user-list-item.active {
                background-color: #eef2fb;
                box-shadow: inset 3px 0 0 var(--auth-accent);
            }

        .user-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: var(--auth-accent);
            color: #fff;
            font-size: 12px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .user-list-item.active .user-avatar {
            background: var(--auth-accent-dark);
        }

        .user-name {
            font-weight: 600;
            font-size: 14px;
            color: #000;
        }

        #selectedUserStatus {
            color: #495057 !important;
            font-weight: 500;
        }

        .status-pill {
            font-size: 10.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .03em;
            padding: 3px 9px;
            border-radius: 20px;
            margin-left: auto;
            white-space: nowrap;
        }

            .status-pill.pending {
                background-color: var(--auth-pending-bg);
                color: var(--auth-pending);
            }

            .status-pill.completed {
                background-color: var(--auth-completed-bg);
                color: var(--auth-completed);
            }

        .user-list-empty {
            padding: 28px 16px;
            text-align: center;
            color: #a3a9b7;
            font-size: 13px;
        }

        /* ---- Permissions table ---- */
        #GridDiv {
            animation: fadeSlideIn .25s ease;
        }

        .selected-user-banner {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 14px;
            background: #f6f8fc;
            border: 1px solid #eef0f5;
            border-radius: 10px;
            margin-bottom: 14px;
        }

            .selected-user-banner .user-avatar {
                width: 36px;
                height: 36px;
                font-size: 13px;
            }

        #tblAuth {
            border-radius: 10px;
            overflow: hidden;
        }

            #tblAuth thead th {
                background-color: var(--auth-accent);
                color: #fff;
                font-size: 12.5px;
                text-transform: uppercase;
                letter-spacing: .04em;
                font-weight: 600;
                border: none;
                padding: 12px 10px;
            }

            #tblAuth tbody tr {
                transition: background-color .12s ease;
            }

                #tblAuth tbody tr:hover {
                    background-color: #f6f8fc;
                }

            #tblAuth td {
                padding: 10px;
                font-size: 13.5px;
                color: #000 !important;
                font-weight: 500;
            }

        .form-switch .form-check-input {
            width: 2.4em;
            height: 1.3em;
            cursor: pointer;
        }

            .form-switch .form-check-input:checked {
                background-color: var(--auth-completed);
                border-color: var(--auth-completed);
            }

        #btnSubmit {
            border-radius: 8px;
            font-weight: 600;
            padding: 9px 28px;
        }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: #a3a9b7;
        }

            .empty-state i.bi {
                font-size: 2.4rem;
                display: block;
                margin-bottom: .5rem;
                color: #ccd1de;
            }

        @keyframes fadeSlideIn {
            from {
                opacity: 0;
                transform: translateY(6px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Toasts */
        #toastStack {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1080;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .auth-toast {
            min-width: 280px;
            border-radius: 10px;
            padding: 12px 16px;
            box-shadow: 0 8px 24px rgba(20,30,60,.15);
            color: #fff;
            font-size: 13.5px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: fadeSlideIn .2s ease;
        }

            .auth-toast.success {
                background: var(--auth-completed);
            }

            .auth-toast.error {
                background: #d9534f;
            }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <%-- ScriptManager is still required to enable PageMethods (static server calls from JS) --%>
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

    <div id="toastStack"></div>

    <div class="card auth-card">
        <div class="card-header d-flex align-items-center gap-3">
            <i class="bi bi-shield-lock-fill"></i>
            <div>
                <div class="auth-eyebrow">Access Control</div>
                <h3 class="m-0 fw-bold">User Authorization</h3>
            </div>
        </div>

        <div class="card-body p-4">
            <div class="row">
                <div class="col-md-4">
                    <div class="row g-3">
                        <label class="field-label"><i class="bi bi-people-fill me-1"></i>User Role</label>
                        <select id="ddlUserRole" class="form-control">
                            <option value="">Select a role...</option>
                        </select>
                    </div>

                    <!-- Summary strip: total / completed / pending / progress -->
                    <div id="summaryStrip" class="summary-strip d-none">
                        <div class="summary-item">
                            <div class="summary-value" id="sumTotal">0</div>
                            <div class="summary-label">Total Users</div>
                        </div>
                        <div class="summary-item completed">
                            <div class="summary-value" id="sumCompleted">0</div>
                            <div class="summary-label">Completed</div>
                        </div>
                        <div class="summary-item pending">
                            <div class="summary-value" id="sumPending">0</div>
                            <div class="summary-label">Pending</div>
                        </div>
                        <div class="summary-progress">
                            <div class="progress" style="height: 8px;">
                                <div class="progress-bar" id="progressBar" role="progressbar" style="width: 0%"></div>
                            </div>
                            <div class="small text-muted mt-1" id="progressLabel">0% configured</div>
                        </div>
                    </div>

                    <!-- Searchable / filterable user picker -->
                    <div id="userPickerDiv" class="mt-4 d-none">
                        <label class="field-label"><i class="bi bi-person-lines-fill me-1"></i>Select User</label>

                        <div class="d-flex flex-wrap gap-2 align-items-center mb-2">
                            <div class="btn-group filter-pill-group" role="group">
                                <button type="button" class="btn active" data-filter="All">All</button>
                                <button type="button" class="btn" data-filter="Pending">Pending</button>
                                <button type="button" class="btn" data-filter="Completed">Completed</button>
                            </div>
                            <div class="flex-grow-1 user-search-wrap">
                                <i class="bi bi-search"></i>
                                <input type="text" id="userSearch" class="form-control form-control-sm" placeholder="Search by name..." />
                            </div>
                        </div>

                        <div id="userList" class="user-list"></div>
                    </div>

                </div>
                <div class="col-md-8">
                    <!-- Permissions grid for the selected user -->
                    <div id="GridDiv" class="mt-4 d-none">
                        <div class="selected-user-banner d-flex align-items-center">
                            <div class="user-avatar" id="selectedUserAvatar">--</div>
                            <div>
                                <div class="fw-bold" id="selectedUserName" style="font-size: 14px;"></div>
                                <div class="small text-muted" id="selectedUserStatus"></div>
                            </div>
                            <!-- Push button to the end -->
                            <div class="ms-auto">
                                <button type="button" id="btnSubmit" class="btn btn-success">
                                    <i class="bi bi-check2-circle me-1"></i><span id="btnSubmitText">Save Authorization</span>
                                </button>
                            </div>
                        </div>
                        <div class="table-responsive" style="height: 562px !important;">
                            <table id="tblAuth" class="table table-bordered mb-0">
                                <thead>
                                    <tr>
                                        <th style="width: 70px;">Sr. No.</th>
                                        <th>Menu Name</th>
                                        <th>Page Name</th>
                                        <th style="width: 120px;"><i class="bi bi-eye-fill me-1"></i>Access</th>
                                        <th style="width: 120px;"><i class="bi bi-pencil-fill me-1"></i>Edit</th>
                                    </tr>
                                </thead>
                                <tbody id="tblAuthBody">
                                </tbody>
                            </table>
                        </div>

                    </div>
                </div>
            </div>
            <!-- Empty state before a role is chosen -->
            <div id="emptyState" class="empty-state">
                <i class="bi bi-shield-lock"></i>
                Select a role above to see its users and manage page access.
           
            </div>

        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script type="text/javascript">
        var allUsers = [];          // full user list for the selected role (cached client-side)
        var currentFilter = 'All';
        var selectedUserId = null;
        var selectedUserName = null;

        $(document).ready(function () {
            LoadRoles();

            $('#ddlUserRole').on('change', function () {
                var roleId = $(this).val();
                resetBelowRole();
                if (roleId) {
                    LoadUsers(roleId);
                }
            });

            $(document).on('click', '.filter-pill-group .btn', function () {
                $('.filter-pill-group .btn').removeClass('active');
                $(this).addClass('active');
                currentFilter = $(this).data('filter');
                RenderUserList();
            });

            $('#userSearch').on('input', function () {
                RenderUserList();
            });

            $(document).on('click', '.user-list-item', function () {
                var userId = $(this).data('userid');
                var userName = $(this).data('username');
                var status = $(this).data('status');

                $('.user-list-item').removeClass('active');
                $(this).addClass('active');

                selectedUserId = userId;
                selectedUserName = userName;

                $('#selectedUserName').text(userName);
                $('#selectedUserAvatar').text(initials(userName));
                $('#selectedUserStatus').html(
                    status === 'Completed'
                        ? '<i class="bi bi-check-circle-fill" style="color:var(--auth-completed);"></i> Already configured - review or update below'
                        : '<i class="bi bi-exclamation-circle-fill" style="color:var(--auth-pending);"></i> Not yet configured'
                );

                LoadUserPages(userId);
            });

            $('#btnSubmit').on('click', function () {
                SaveAuthorization();
            });
        });

        function resetBelowRole() {
            selectedUserId = null;
            selectedUserName = null;
            allUsers = [];
            $('#summaryStrip').addClass('d-none');
            $('#userPickerDiv').addClass('d-none');
            $('#GridDiv').addClass('d-none');
            $('#userList').empty();
            $('#emptyState').removeClass('d-none');
        }

        function initials(name) {
            if (!name) return '?';
            var parts = name.trim().split(' ');
            var i = parts[0] ? parts[0].charAt(0) : '';
            var j = parts.length > 1 ? parts[parts.length - 1].charAt(0) : '';
            return (i + j).toUpperCase();
        }

        function LoadRoles() {
            PageMethods.GetRoles(function (result) {
                var roles = JSON.parse(result);
                var ddl = $('#ddlUserRole');
                ddl.empty().append('<option value="">Select a role...</option>');
                $.each(roles, function (i, r) {
                    ddl.append('<option value="' + r.ID + '">' + r.Roles + '</option>');
                });
            }, function (error) {
                showToast('error', 'Error loading roles: ' + error.get_message());
            });
        }

        function LoadUsers(roleId) {
            PageMethods.GetUsers(roleId, function (result) {
                allUsers = JSON.parse(result);
                currentFilter = 'All';
                $('.filter-pill-group .btn').removeClass('active');
                $('.filter-pill-group .btn[data-filter="All"]').addClass('active');
                $('#userSearch').val('');

                UpdateSummary();
                RenderUserList();

                $('#emptyState').addClass('d-none');
                $('#summaryStrip').removeClass('d-none');
                $('#userPickerDiv').removeClass('d-none');
                $('#GridDiv').addClass('d-none');
            }, function (error) {
                showToast('error', 'Error loading users: ' + error.get_message());
            });
        }

        function UpdateSummary() {
            var total = allUsers.length;
            var completed = allUsers.filter(function (u) { return u.Status === 'Completed'; }).length;
            var pending = total - completed;
            var pct = total > 0 ? Math.round((completed / total) * 100) : 0;

            $('#sumTotal').text(total);
            $('#sumCompleted').text(completed);
            $('#sumPending').text(pending);
            $('#progressBar').css('width', pct + '%');
            $('#progressLabel').text(pct + '% of users configured for this role');
        }

        function RenderUserList() {
            var term = ($('#userSearch').val() || '').toLowerCase().trim();

            var filtered = allUsers.filter(function (u) {
                var matchesFilter = currentFilter === 'All' || u.Status === currentFilter;
                var matchesSearch = !term || u.FullName.toLowerCase().indexOf(term) !== -1;
                return matchesFilter && matchesSearch;
            });

            var container = $('#userList');
            container.empty();

            if (filtered.length === 0) {
                container.html('<div class="user-list-empty"><i class="bi bi-search d-block mb-1" style="font-size:1.4rem;"></i>No users match this filter/search.</div>');
                return;
            }

            $.each(filtered, function (i, u) {
                var pillClass = u.Status === 'Completed' ? 'completed' : 'pending';
                var activeClass = (selectedUserId == u.ID) ? 'active' : '';

                var item = $('<div class="user-list-item ' + activeClass + '"></div>')
                    .attr('data-userid', u.ID)
                    .attr('data-username', u.FullName)
                    .attr('data-status', u.Status);

                item.append('<div class="user-avatar">' + initials(u.FullName) + '</div>');
                item.append('<div class="user-name">' + u.FullName + '</div>');
                item.append('<span class="status-pill ' + pillClass + '">' + u.Status + '</span>');

                container.append(item);
            });
        }

        function LoadUserPages(userId) {
            PageMethods.GetUserPages(userId, function (result) {
                var pages = JSON.parse(result);
                var tbody = $('#tblAuthBody');
                tbody.empty();

                $.each(pages, function (i, p) {
                    var checkedPage = (p.PageAccess === 'True' || p.PageAccess === true) ? 'checked' : '';
                    var checkedView = (p.PageButtonAccess === 'True' || p.PageButtonAccess === true) ? 'checked' : '';

                    var row = $('<tr>')
                        .attr('data-menuid', p.MenuId)
                        .attr('data-menuname', p.MenuName)
                        .attr('data-pagename', p.PageName);

                    row.append('<td class="text-center text-muted">' + (i + 1) + '</td>');
                    row.append('<td>' + p.MenuName + '</td>');
                    row.append('<td>' + p.PageName + '</td>');
                    row.append(
                        '<td class="text-center"><div class="form-check form-switch d-flex justify-content-center">' +
                        '<input type="checkbox" class="form-check-input chkPages" ' + checkedPage + ' /></div></td>'
                    );
                    row.append(
                        '<td class="text-center"><div class="form-check form-switch d-flex justify-content-center">' +
                        '<input type="checkbox" class="form-check-input chkPagesView" ' + checkedView + ' /></div></td>'
                    );

                    tbody.append(row);
                });

                $('#GridDiv').removeClass('d-none');
                $('html, body').animate({ scrollTop: $('#GridDiv').offset().top - 90 }, 250);
            }, function (error) {
                showToast('error', 'Error loading pages: ' + error.get_message());
            });
        }

        function SaveAuthorization() {
            if (!selectedUserId) {
                showToast('error', 'Please select a user first.');
                return;
            }

            var pages = [];
            $('#tblAuthBody tr').each(function () {
                var row = $(this);
                pages.push({
                    MenuId: row.data('menuid'),
                    MenuName: row.data('menuname'),
                    PageName: row.data('pagename'),
                    PageAccess: row.find('.chkPages').is(':checked'),
                    PageButtonAccess: row.find('.chkPagesView').is(':checked')
                });
            });

            var $btn = $('#btnSubmit');
            $btn.prop('disabled', true);
            $('#btnSubmitText').html('<span class="spinner-border spinner-border-sm me-1"></span>Saving...');

            PageMethods.SaveAuthorization(selectedUserId, selectedUserName, JSON.stringify(pages), function (result) {
                $btn.prop('disabled', false);
                $('#btnSubmitText').text('Save Authorization');
                showToast('success', 'Authorization saved for ' + selectedUserName + '.');

                // Refresh status pills/summary in the background without losing the open grid
                PageMethods.GetUsers($('#ddlUserRole').val(), function (result2) {
                    allUsers = JSON.parse(result2);
                    UpdateSummary();
                    RenderUserList();
                });
            }, function (error) {
                $btn.prop('disabled', false);
                $('#btnSubmitText').text('Save Authorization');
                showToast('error', 'Error saving: ' + error.get_message());
            });
        }

        function showToast(type, message) {
            var icon = type === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill';
            var toast = $('<div class="auth-toast ' + type + '"><i class="bi ' + icon + '"></i><span>' + message + '</span></div>');
            $('#toastStack').append(toast);
            setTimeout(function () {
                toast.fadeOut(200, function () { $(this).remove(); });
            }, 3500);
        }
    </script>

</asp:Content>
