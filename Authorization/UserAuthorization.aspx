<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="UserAuthorization.aspx.cs" Inherits="UserAuthorization" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css" />
    <style>
        :root {
            --auth-accent: #4a63a0;
            --auth-accent-dark: #33477a;
            --auth-accent-light: #7b93cc;
            --auth-pending: #c9720a;
            --auth-pending-bg: #ffedd6;
            --auth-completed: #16824f;
            --auth-completed-bg: #d9f5e5;
            --auth-surface: #eef1f8;
        }

        /* subtle page backdrop so the card reads as elevated, not flat */
        .auth-page-bg {
            background: radial-gradient(circle at top left, #f3f5fc 0%, var(--auth-surface) 55%, #e6e9f4 100%);
            padding: 4px;
            border-radius: 16px;
        }

        .auth-card {
            border: 1px solid #e2e5f0;
            border-radius: 14px;
            box-shadow: 0 10px 34px rgba(35, 45, 90, 0.14), 0 2px 8px rgba(35, 45, 90, 0.08);
            overflow: hidden;
            width: 100%;
        }

            .auth-card .card-header {
                background: linear-gradient(135deg, var(--auth-accent) 0%, var(--auth-accent-dark) 100%);
                border: none;
                padding: 1.25rem 1.75rem;
                position: relative;
            }

                .auth-card .card-header::after {
                    content: "";
                    position: absolute;
                    inset: 0;
                    background: linear-gradient(180deg, rgba(255,255,255,.08), rgba(255,255,255,0));
                    pointer-events: none;
                }

        .auth-eyebrow {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .12em;
            color: rgba(255,255,255,.85);
            font-weight: 700;
        }

        .auth-card .card-header h3 {
            color: #fff;
            text-shadow: 0 1px 2px rgba(0,0,0,.15);
        }

        .auth-card .card-header i.bi {
            color: #fff;
            font-size: 1.7rem;
            background: rgba(255,255,255,.15);
            width: 46px;
            height: 46px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .auth-card .card-body {
            background-color: #fdfdff;
        }

        /* ---- Selection controls ---- */
        .field-label {
            font-weight: 700;
            font-size: 12.5px;
            text-transform: uppercase;
            letter-spacing: .05em;
            color: #1f2433;
            margin-bottom: 7px;
            display: block;
        }

        select.form-control,
        input.form-control {
            border-radius: 9px;
            border: 1.5px solid #ced2e0;
            box-shadow: 0 1px 3px rgba(20,30,60,.05);
            color: #1f2433 !important;
            font-weight: 600;
            background-color: #fff;
            transition: border-color .15s ease, box-shadow .15s ease;
        }

            select.form-control option {
                color: #1f2433;
            }

            select.form-control:focus,
            input.form-control:focus {
                border-color: var(--auth-accent);
                box-shadow: 0 0 0 3px rgba(74, 99, 160, .18);
            }

        /* ---- Summary strip ---- */
        .summary-strip {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 1.5rem;
            background: #fff;
            border: 1.5px solid #e2e5f0;
            box-shadow: 0 3px 10px rgba(35,45,90,.06);
            border-radius: 12px;
            padding: 1rem 1.25rem;
            margin-top: 1.25rem;
            animation: fadeSlideIn .25s ease;
        }

        .summary-item .summary-value {
            font-size: 1.6rem;
            font-weight: 800;
            line-height: 1;
            color: #1f2433;
        }

        .summary-item .summary-label {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .05em;
            color: #6b7280;
            margin-top: 3px;
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
                background-color: #e3e6f0;
                height: 9px !important;
            }

            .summary-progress .progress-bar {
                background: linear-gradient(90deg, var(--auth-completed), #2fd888);
                transition: width .4s ease;
            }

            .summary-progress .small {
                color: #555b6e !important;
                font-weight: 600;
            }

        /* ---- User picker ---- */
        .filter-pill-group .btn {
            border-radius: 20px !important;
            font-size: 12.5px;
            font-weight: 700;
            padding: 5px 16px;
            border: 1.5px solid #ced2e0;
            color: #4b5163;
            background: #fff;
        }

            .filter-pill-group .btn.active {
                background-color: var(--auth-accent);
                border-color: var(--auth-accent);
                color: #fff;
                box-shadow: 0 2px 8px rgba(74,99,160,.35);
            }

        .user-search-wrap {
            position: relative;
        }

            .user-search-wrap i.bi-search {
                position: absolute;
                left: 12px;
                top: 50%;
                transform: translateY(-50%);
                color: #8890a3;
            }

            .user-search-wrap input {
                padding-left: 34px;
            }

        .user-list {
            max-height: 320px;
            overflow-y: auto;
            border: 1.5px solid #e2e5f0;
            border-radius: 10px;
            background: #fff;
            box-shadow: inset 0 1px 3px rgba(20,30,60,.04);
        }

            .user-list::-webkit-scrollbar {
                width: 8px;
            }

            .user-list::-webkit-scrollbar-thumb {
                background: #c7cce0;
                border-radius: 8px;
            }

        .user-list-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 11px 14px;
            border: none;
            border-bottom: 1px solid #eef0f7;
            cursor: pointer;
            transition: background-color .12s ease;
        }

            .user-list-item:last-child {
                border-bottom: none;
            }

            .user-list-item:hover {
                background-color: #f2f4fb;
            }

            .user-list-item.active {
                background-color: #e7ecfa;
                box-shadow: inset 4px 0 0 var(--auth-accent);
            }

        .user-avatar {
            width: 33px;
            height: 33px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--auth-accent), var(--auth-accent-dark));
            color: #fff;
            font-size: 12px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            box-shadow: 0 2px 5px rgba(74,99,160,.3);
        }

        .user-name {
            font-weight: 700;
            font-size: 14px;
            color: #1f2433;
        }

        #selectedUserStatus {
            color: #4b5163 !important;
            font-weight: 600;
        }

        .status-pill {
            font-size: 10.5px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .03em;
            padding: 4px 10px;
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
            color: #9297a8;
            font-size: 13px;
        }

        /* ---- Permissions table ---- */
        #GridDiv {
            animation: fadeSlideIn .25s ease;
        }

        .selected-user-banner {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            background: linear-gradient(135deg, #f2f4fb, #e9edf9);
            border: 1.5px solid #dde1f0;
            border-radius: 10px;
            margin-bottom: 16px;
        }

            .selected-user-banner .user-avatar {
                width: 38px;
                height: 38px;
                font-size: 13px;
            }

        #selectedUserName {
            color: #1f2433 !important;
        }

        #tblAuth {
            border-radius: 10px;
            overflow: hidden;
            border: 1.5px solid #e2e5f0;
        }

            #tblAuth thead th {
                background: linear-gradient(135deg, var(--auth-accent), var(--auth-accent-dark));
                color: #fff;
                font-size: 12.5px;
                text-transform: uppercase;
                letter-spacing: .05em;
                font-weight: 700;
                border: none;
                padding: 13px 10px;
            }

            #tblAuth tbody tr {
                transition: background-color .12s ease;
                background-color: #fff;
            }

                #tblAuth tbody tr:nth-child(even) {
                    background-color: #f8f9fd;
                }

                #tblAuth tbody tr:hover {
                    background-color: #eef1fb;
                }

            #tblAuth td {
                padding: 11px 10px;
                font-size: 13.5px;
                color: #1f2433 !important;
                font-weight: 600;
                border-color: #edeff6;
            }

        .form-switch .form-check-input {
            width: 2.5em;
            height: 1.35em;
            cursor: pointer;
            border: 1.5px solid #c7cce0;
        }

            .form-switch .form-check-input:checked {
                background-color: var(--auth-completed);
                border-color: var(--auth-completed);
            }

        .auth-footer {
            display: flex;
            justify-content: center;
            padding-top: 20px;
            margin-top: 6px;
            border-top: 1px solid #edeff6;
        }

        #btnSubmit {
            border-radius: 9px;
            font-weight: 700;
            font-size: 14.5px;
            padding: 11px 40px;
            background: linear-gradient(135deg, var(--auth-completed), #1fae63);
            border: none;
            box-shadow: 0 6px 16px rgba(22,130,79,.35);
            transition: transform .12s ease, box-shadow .12s ease;
        }

            #btnSubmit:hover:not(:disabled) {
                transform: translateY(-1px);
                box-shadow: 0 8px 20px rgba(22,130,79,.45);
            }

            #btnSubmit:disabled {
                opacity: .75;
            }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: #8890a3;
        }

            .empty-state i.bi {
                font-size: 2.6rem;
                display: block;
                margin-bottom: .5rem;
                color: #c3c8dc;
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
            box-shadow: 0 8px 24px rgba(20,30,60,.2);
            color: #fff;
            font-size: 13.5px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: fadeSlideIn .2s ease;
        }

            .auth-toast.success {
                background: linear-gradient(135deg, var(--auth-completed), #1fae63);
            }

            .auth-toast.error {
                background: linear-gradient(135deg, #d9534f, #c0392b);
            }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <%-- ScriptManager is still required to enable PageMethods (static server calls from JS) --%>
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

    <div id="toastStack"></div>

    <div class="auth-page-bg">
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
                            <div class="selected-user-banner">
                                <div class="user-avatar" id="selectedUserAvatar">--</div>
                                <div>
                                    <div class="fw-bold" id="selectedUserName" style="font-size: 14px;"></div>
                                    <div class="small text-muted" id="selectedUserStatus"></div>
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
                <br />
                <br />
                <center>
                    <button type="button" id="btnSubmit" class="btn btn-success">
                        <i class="bi bi-check2-circle me-1"></i><span id="btnSubmitText">Save Authorization</span>
                    </button>
                </center>
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
