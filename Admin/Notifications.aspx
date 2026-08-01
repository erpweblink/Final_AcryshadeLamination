<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="Notifications.aspx.cs" Inherits="Notifications" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style type="text/css">
        .order-headerss {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

            .order-headerss h2 {
                margin: 0;
                white-space: nowrap;
            }

        .product-link a {
            text-decoration: none;
            font-size: 18px;
        }

        .order-container {
            width: 95%;
            margin: auto;
            padding: 20px;
        }

        .order-card {
            background: #fff;
            border-radius: 10px;
            margin-bottom: 20px;
            padding: 15px;
            box-shadow: 0 2px 10px rgb(0 0 0 / 15%);
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 10px;
            cursor: pointer;
        }

            .order-header:hover {
                background: #f8f8f8;
            }

            .order-header > div:nth-child(2) {
                flex: 1;
                min-width: 180px;
            }

        .order-details {
            display: none;
            margin-top: 10px;
        }

        .order-status {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 10px;
            flex-wrap: wrap;
            background: transparent;
            padding: 0;
            color: inherit;
        }

            .order-status a {
                display: flex;
                align-items: center;
                justify-content: center;
                text-decoration: none;
            }

            .order-status i {
                font-size: 28px;
            }

        .products-container {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-top: 10px;
        }

        .product-row {
            display: flex;
            align-items: center;
            gap: 15px;
            border: 1px solid #f1f1f1;
            border-radius: 8px;
            padding: 10px;
            background: #fafafa;
            transition: all .2s ease;
            cursor: pointer;
            border-left: 4px solid transparent;
        }

            .product-row:hover {
                transform: scale(1.02);
                background: #eef6ff;
                box-shadow: 0 4px 12px rgba(0,0,0,.12);
                border-left: 4px solid #2196f3;
            }

                .product-row:hover .product-name {
                    color: #1976d2;
                }

            .product-row img {
                width: 80px;
                height: 80px;
                object-fit: cover;
                border-radius: 6px;
                border: 1px solid #ddd;
                flex-shrink: 0;
            }

        .product-info {
            flex: 1;
        }

        .product-name {
            font-weight: bold;
            margin-bottom: 5px;
            word-break: break-word;
        }

        .product-meta {
            font-size: 13px;
            color: #666;
        }

        .delivery {
            font-size: 13px;
            color: #333;
        }

        .product-note {
            font-size: 12px;
            color: #666;
            margin: 5px 0;
            line-height: 1.4;
            background: #f9f9f9;
            padding: 6px 8px;
            border-radius: 5px;
            max-height: 60px;
            overflow: hidden;
        }

            .product-note:hover {
                max-height: none;
            }

        #orderList span[id^="icon_"] {
            font-size: 18px;
            font-weight: bold;
            margin-right: 10px;
        }

        .btn-accept,
        .btn-reject {
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 110px;
            height: 42px;
            padding: 0 18px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: .2s;
        }

        .btn-accept {
            background: #198754;
            color: #fff;
        }

            .btn-accept:hover {
                background: #157347;
            }

        .btn-reject {
            background: #dc3545;
            color: #fff;
        }

            .btn-reject:hover {
                background: #bb2d3b;
            }

        /* Image Modal */

        .img-modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,.9);
            justify-content: center;
            align-items: center;
            z-index: 99999;
        }

            .img-modal img {
                max-width: 90%;
                max-height: 90%;
                border-radius: 12px;
                box-shadow: 0 0 30px rgba(0,0,0,.5);
            }

        /* Reject Reason Modal */

        .reject-modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,.6);
            justify-content: center;
            align-items: center;
            z-index: 99999;
            padding: 15px;
        }

        .reject-modal-box {
            background: #fff;
            width: 100%;
            max-width: 420px;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,.3);
        }

            .reject-modal-box h4 {
                margin: 0 0 6px 0;
                font-weight: 700;
            }

            .reject-modal-box p {
                margin: 0 0 12px 0;
                font-size: 13px;
                color: #666;
            }

        .reject-modal-textarea {
            width: 100%;
            min-height: 100px;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 10px;
            font-size: 14px;
            resize: vertical;
            box-sizing: border-box;
        }

            .reject-modal-textarea:focus {
                outline: none;
                border-color: #dc3545;
                box-shadow: 0 0 0 3px rgba(220,53,69,.15);
            }

        .reject-modal-error {
            color: #dc3545;
            font-size: 12px;
            margin-top: 6px;
            display: none;
        }

        .reject-modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 16px;
        }

        .btn-modal-cancel {
            background: #f1f1f1;
            color: #333;
            border: none;
            border-radius: 8px;
            padding: 10px 18px;
            font-weight: 600;
            cursor: pointer;
        }

            .btn-modal-cancel:hover {
                background: #e4e4e4;
            }

        .btn-modal-confirm {
            background: #dc3545;
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 10px 18px;
            font-weight: 600;
            cursor: pointer;
        }

            .btn-modal-confirm:hover {
                background: #bb2d3b;
            }

            .btn-modal-confirm:disabled {
                opacity: .6;
                cursor: not-allowed;
            }

        /* =======================
   Tablet
======================= */

        @media (max-width:992px) {

            .products-container {
                grid-template-columns: 1fr;
            }

            .order-status {
                width: 100%;
                justify-content: flex-start;
                margin-top: 10px;
            }

            .order-header {
                align-items: flex-start;
            }
        }

        /* =======================
   Mobile
======================= */

        @media (max-width:768px) {

            .order-container {
                width: 100%;
                padding: 10px;
            }

            .order-card {
                padding: 12px;
            }

            .order-header {
                flex-direction: column;
                align-items: flex-start;
            }

                .order-header > div:nth-child(2) {
                    width: 100%;
                }

            .order-status {
                width: 100%;
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 8px;
            }

                .order-status a {
                    width: 40px;
                    height: 40px;
                }

            .btn-accept,
            .btn-reject {
                flex: 1;
                min-width: auto;
            }

            .product-row {
                align-items: flex-start;
            }

                .product-row img {
                    width: 70px;
                    height: 70px;
                }

            .product-name {
                font-size: 15px;
            }

            .product-meta,
            .product-note {
                font-size: 12px;
            }
        }

        /* =======================
   Small Mobile
======================= */

        @media (max-width:480px) {

            .order-container {
                padding: 8px;
            }

            .order-card {
                padding: 10px;
            }

            .order-header b {
                font-size: 16px;
            }

            .order-header small {
                font-size: 12px;
            }

            .order-status {
                flex-direction: column;
                align-items: stretch;
            }

                .order-status a {
                    align-self: center;
                    margin-bottom: 8px;
                }

            .btn-accept,
            .btn-reject {
                width: 100%;
            }

            .products-container {
                gap: 10px;
            }

            .product-row {
                padding: 8px;
            }

                .product-row img {
                    width: 60px;
                    height: 60px;
                }

            .product-name {
                font-size: 14px;
            }

            .product-meta {
                font-size: 11px;
            }

            .product-note {
                font-size: 11px;
            }
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            loadOrders();
        });

        function toggleOrder(orderId) {
            $("#details_" + orderId).slideToggle();

            let icon = $("#icon_" + orderId);

            if (icon.text() === "▼")
                icon.text("▲");
            else
                icon.text("▼");

        }

        function loadOrders() {
            var orderID = $("#<%= hdnOrderID.ClientID %>").val();
            $.ajax({
                type: "POST",
                url: "Notifications.aspx/GetOrders",
                data: JSON.stringify({ orderID: orderID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    let orders = response.d;
                    renderOrders(orders);
                },
                error: function (err) {
                    console.log(err);
                }
            });
        }

        function renderOrders(orders) {
            let html = "";

            orders.forEach(o => {

                html += `
                 <div class="order-card">

                     <div class="order-header" onclick="toggleOrder('${o.ID}')">
                         <span id="icon_${o.ID}">▼</span>

                         <div>
                                 <b>${o.DealerName}</b> <br/>
                             <small>Placed on: ${o.CreatedDate}</small>
                             <small style="color:red;"><b>${o.HoldStatus}</b></small>
                         </div>

                        <div class="order-status">

                            <a href="${o.AttachedPath ? '/Content/' + o.AttachedPath.replace('~/', '') : '#'}"
                               target="_blank"
                               onclick="event.stopPropagation();"
                               title="${o.AttachedPath ? 'View Invoice' : 'No PDF Available'}"
                               style="margin-right:10px;">

                                <i class="bi bi-file-pdf"
                                   style="font-size:26px;
                                          color:${o.AttachedPath ? '#0d6efd' : '#555'};
                                          cursor:${o.AttachedPath ? 'pointer' : 'default'};">
                                </i>

                            </a>

                            <button class="btn-accept" type="button"
                                    onclick="event.preventDefault();event.stopPropagation();acceptOrder('${o.EnID}')">
                                ✓ Approve
                            </button>

                            <button class="btn-reject" type="button"
                                    onclick="event.stopPropagation();rejectOrder('${o.EnID}')">
                                ✕ Reject
                            </button>

                        </div>
                     </div>

                     <div id="details_${o.ID}" class="order-details">

                         <div>
                              <b>Order ID:</b> ${o.OrderID}<br/>
                         </div>

                         <div class="products-container">
                 `;

                o.Products.forEach(p => {
                    var Image = '/Content/' + p.ImagePathName.replace('~/', '');

                    html += `
                     <div class="product-row">
                         <img src="${Image}" onclick="openModal('${Image}')" />

                         <div class="product-info">
                             <div class="product-name">${p.ProductName}</div>
                     `;

                    if (p.ProductNote && p.ProductNote.trim() !== "") {
                        html += `
                         <div class="product-note">
                             ${p.ProductNote}
                         </div>
                     `;
                    }

                    html += `
                         <div class="product-meta">
                             Type: ${p.ProductType} | Size: ${p.Size}
                         </div>

                         <div class="product-meta">
                             Qty: ${p.Qty}
                         </div>
                     </div>
                 </div>
                 `;
                });

                html += `
                     </div>
                 </div>
                 </div>
                 `;
            });

            $("#orderList").html(html);
        }


        function openModal(src) {

            document.getElementById("imgModal")
                .style.display = "flex";

            document.getElementById("modalImg")
                .src = src;
        }

        function closeModal() {

            document.getElementById("imgModal")
                .style.display = "none";
        }

        function acceptOrder(EnID) {
            window.location.replace('WorkOrderMaster.aspx?OrderID=' + EnID);
        }

        // ---------------- Reject reason modal ----------------

        var pendingRejectId = null;

        function rejectOrder(id) {
            pendingRejectId = id;

            $("#txtRejectRemark").val("");
            $("#rejectRemarkError").hide();
            $("#btnConfirmReject").prop("disabled", false);

            document.getElementById("rejectModal").style.display = "flex";
            setTimeout(function () { $("#txtRejectRemark").focus(); }, 50);
        }

        function closeRejectModal() {
            document.getElementById("rejectModal").style.display = "none";
            pendingRejectId = null;
        }

        function confirmRejectOrder() {
            var remark = $("#txtRejectRemark").val().trim();

            if (remark === "") {
                $("#rejectRemarkError").text("Please enter a reason for rejecting this order.").show();
                $("#txtRejectRemark").focus();
                return;
            }

            if (!pendingRejectId) {
                closeRejectModal();
                return;
            }

            $("#btnConfirmReject").prop("disabled", true).text("Rejecting...");

            $.ajax({
                type: "POST",
                url: "Notifications.aspx/RejectOrder",
                data: JSON.stringify({ id: pendingRejectId, remark: remark }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function () {
                    window.location.href = window.location.href;
                },
                error: function (err) {
                    console.log(err);
                    $("#rejectRemarkError").text("Something went wrong. Please try again.").show();
                    $("#btnConfirmReject").prop("disabled", false).text("Reject Order");
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:HiddenField ID="hdnOrderID" runat="server" />
            <div class="order-container">
                <div class="order-headerss">
                    <h2 class="fw-bold">Notifications</h2>
                </div>
                <br />
                <br />
                <div id="orderList"></div>
            </div>

            <div id="imgModal"
                class="img-modal"
                onclick="closeModal()">

                <img id="modalImg">
            </div>

            <div id="rejectModal" class="reject-modal">
                <div class="reject-modal-box" onclick="event.stopPropagation();">
                    <h4>Reject Order</h4>
                    <p>Please add a remark explaining why this order is being rejected.</p>

                    <textarea id="txtRejectRemark" class="reject-modal-textarea" placeholder="e.g. Out of stock, incorrect quantity, dealer requested cancellation..."></textarea>
                    <div id="rejectRemarkError" class="reject-modal-error"></div>

                    <div class="reject-modal-actions">
                        <button type="button" class="btn-modal-cancel" onclick="closeRejectModal()">Cancel</button>
                        <button type="button" id="btnConfirmReject" class="btn-modal-confirm" onclick="confirmRejectOrder()">Reject Order</button>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
