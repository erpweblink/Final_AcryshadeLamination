<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="PlaceOrder.aspx.cs" Inherits="PlaceOrder" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.js"></script>

    <style type="text/css">
        .product-card {
            transition: all 0.25s ease;
            cursor: pointer;
            border: 1px solid rgba(255,255,255,0.1);
        }

            /* Hover highlight */
            .product-card:hover {
                transform: translateY(-6px) scale(1.02);
                background: #f4f9ff;
                box-shadow: 0 12px 30px rgba(0,0,0,0.25);
                border: 4px solid #cfe3ff;
            }

            /* Image zoom effect */
            .product-card img {
                transition: transform 0.25s ease;
            }

            .product-card:hover img {
                transform: scale(1.05);
            }

            /* Text highlight */
            .product-card:hover .product-name {
                color: #1976d2;
            }


        .product-card {
            position: relative;
            overflow: hidden;
        }

            .product-card::before {
                content: "";
                position: absolute;
                left: 0;
                top: 0;
                height: 100%;
                width: 7px;
                background: transparent;
                transition: 0.25s;
            }

            .product-card:hover::before {
                background: linear-gradient(180deg, #4f7cff, #7c4dff);
            }


        /* ===== HEADER ===== */

        .title-line {
            display: flex;
            align-items: center;
            margin: 10px 0;
        }

            .title-line::after {
                content: "";
                flex: 1;
                height: 1px;
                background: #000;
                opacity: 0.4;
            }

        .header-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 14px 18px;
            border-radius: 14px;
            background: rgb(238 227 214 / 17%);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255,255,255,0.08);
            box-shadow: 0 10px 30px rgba(0,0,0,0.4);
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-left: auto;
        }

        .error-msg {
            display: block;
            color: #dc3545;
            font-size: 12px;
            margin-top: 3px;
            min-height: 16px;
        }

        .input-error {
            border: 1px solid #dc3545 !important;
        }


        /* optional styling for link h2 */
        .product-link a {
            text-decoration: none;
            font-size: 16px;
        }

        /* ===== SEARCH ===== */
        .search-box {
            flex: 1;
            min-width: 160px;
            max-width: 320px;
            padding: 10px 12px;
            border-radius: 2px;
            border-bottom: 3px solid #1471fc;
            background: rgba(255, 255, 255, 0.06);
            color: black;
            outline: none;
            transition: 0.25s;
        }

            .search-box:focus {
                border-color: #6ea8fe;
                box-shadow: 0 0 12px rgba(110,168,254,0.6);
            }

        /* ===== GRID ===== */
        .product-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
            gap: 14px;
            padding: 10px;
        }

        /* ===== PRODUCT CARD (GLASS EFFECT) ===== */
        .product-card {
            position: relative;
            overflow: hidden;
            border-radius: 18px;
            background: rgb(238 227 214 / 17%);
            padding: 10px;
            transition: all .35s ease;
            border: 1px solid rgba(255,255,255,.4);
            box-shadow: 0 10px 25px rgba(0,0,0,.12), 0 4px 10px rgba(0,0,0,.08);
        }

            .product-card:hover {
                transform: translateY(-8px);
                box-shadow: 0 20px 40px rgba(0,0,0,.18);
            }

            .product-card::before {
                content: "";
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 4px;
                background: linear-gradient( 90deg, #5b86ff, #7c4dff, #ff4da6 );
            }

            /* ===== IMAGE ===== */
            .product-card img {
                width: 100%;
                height: 220px;
                object-fit: cover;
                border-radius: 14px;
                transition: .4s;
            }

            .product-card:hover img {
                transform: scale(1.08);
            }

        /* ===== NAME ===== */
        .product-name {
            font-size: 13px;
            font-weight: 700;
            color: #1f2937;
            line-height: 1.4;
            min-height: 38px;
            margin-top: 10px;
        }

        /* ===== INPUTS ===== */
        select, input {
            width: 100%;
            margin-top: 10px;
            padding: 9px;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.15);
            background: rgb(159 154 154 / 25%);
            color: #000000;
            outline: none;
        }

            select:focus, input:focus {
                border-color: #6ea8fe;
                box-shadow: 0 0 10px rgba(110,168,254,0.5);
            }

        /* ===== BUTTON (NEON STYLE) ===== */
        .btnCart {
            width: 100%;
            margin-top: 12px;
            padding: 10px;
            border-radius: 12px;
            border: none;
            cursor: pointer;
            font-weight: 700;
            color: white;
            background: linear-gradient(135deg, #4f7cff, #7c4dff);
            box-shadow: 0 6px 18px rgba(124,77,255,0.35);
            transition: 0.25s;
        }

            .btnCart:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 25px rgba(124,77,255,0.5);
            }

        /* ===== BADGE ===== */
        #cartCount {
            background: linear-gradient(135deg, #ff3b3b, #ff0066);
            box-shadow: 0 0 10px rgba(255,0,102,0.5);
        }

        /* ===== MODAL ===== */
        .img-modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.9);
            justify-content: center;
            align-items: center;
            z-index: 99999;
        }

            .img-modal img {
                max-width: 90%;
                max-height: 90%;
                border-radius: 14px;
                box-shadow: 0 0 40px rgba(0,0,0,0.6);
            }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 768px) {
            .product-container {
                grid-template-columns: repeat(2, 1fr);
            }

            .product-card img {
                height: 150px;
            }
        }

        @media (max-width: 480px) {
            .product-container {
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
            }

            .header-row {
                flex-direction: column;
                align-items: stretch;
            }

            .header-right {
                width: 100%;
                justify-content: space-between;
            }
        }
    </style>
    <script type="text/javascript">
        let allProducts = [];
        document.addEventListener("DOMContentLoaded", function () {

            loadCartData();
            loadProducts();

            document.getElementById("txtSearch")
                .addEventListener("keyup", searchProducts);

        });

        function loadCartData() {

            fetch("PlaceOrder.aspx/GetCartData", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                }
            })
                .then(r => r.json())
                .then(data => {
                    var result = JSON.parse(data.d);  // result = [{ "Count": 3 }]
                    var count = result[0].Count;      // ✅ get the number

                    const badge = document.getElementById("cartCount");
                    if (count > 0) {
                        badge.innerText = count;
                        badge.style.display = "flex";
                    } else {
                        badge.innerText = "0";
                        badge.style.display = "flex";
                    }

                });
        }

        function loadProducts() {

            fetch("PlaceOrder.aspx/GetProducts", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                }
            })
                .then(r => r.json())
                .then(data => {

                    allProducts = JSON.parse(data.d);
                    allProducts.forEach(function (p) {

                        if (p.ImagenamePath) {
                            p.ImagenamePath =
                                p.ImagenamePath.replace("~/", "/Content/");
                        } else {
                            p.ImagenamePath = 'https://placehold.co/100x100?text=No-Image';
                        }

                    });

                    renderInitial();
                });
        }

        function renderInitial() {
            let trending =
                allProducts.filter(x => x.FavoriteProduct).sort((a, b) => a.FavoriteProductRank - b.FavoriteProductRank);

            let regular =
                allProducts.filter(x => !x.FavoriteProduct);


            renderCards(
                trending,
                "trendingContainer"
            );

            renderCards(
                regular,
                "regularContainer"
            );

            if (!trending || trending.length === 0) {
                document.getElementById("divTrending").style.display = "none";
            } else {
                document.getElementById("divTrending").style.display = "block";
            }
        }

        function renderCards(products, containerId) {
            let html = "";

            products.forEach(p => {

                let is8x2Regular = p.Size === "8x2";
                let is8x4Regular = p.Size === "8x4";

                html += `

                <div class="product-card">
                    <img id="img_${containerId}_${p.ID}" 
                        src="${p.ImagenamePath}"
                        onclick="openModal('${p.ImagenamePath}')">

                    <div class="product-name" id="name_${containerId}_${p.ID}">
                        ${p.ProductName}
                    </div>

                     <select id="type_${containerId}_${p.ID}" onchange="toggleSize(this, '${p.Size}')">
                        <option value="Regular" selected>Regular</option>
                        <option value="Custom">Custom</option>
                    </select>
                    <small id="typeErr_${containerId}_${p.ID}" class="error-msg"></small>

                    <select id="size_${containerId}_${p.ID}" disabled onchange="clearError('size',${p.ID})">
                        <option value="">Select Size</option>
                        <option value="8x2"  ${p.Size === "8x2" ? "selected" : ""}>8x2</option>
                        <option value="8x4"  ${p.Size === "8x4" ? "selected" : ""}>8x4</option>
                    </select>
                    <small id="sizeErr_${containerId}_${p.ID}" class="error-msg"></small>

                    <input id="qty_${containerId}_${p.ID}" autocomplete="off" placeholder="Quantity" oninput="clearError('qty','${containerId}',${p.ID})" onkeypress="return event.charCode >= 48 && event.charCode <= 57">
                    <small id="qtyErr_${containerId}_${p.ID}" class="error-msg"></small>
                  
                    <button type="button"
                        class="btnCart"
                        onclick="return addToCart(this,'${containerId}',${p.ID})">

                        Add To Cart

                    </button>
                </div>
                `;
            });

            document
                .getElementById(containerId)
                .innerHTML = html;
        }

        function reloadProductsFromMemory() {
            if (allProducts.length > 0) {
                renderInitial();
            }
        }

        function clearError(field, containerId, productId) {

            let err = document.getElementById(
                field + "Err_" + containerId + "_" + productId
            );

            let ctrl = document.getElementById(
                field + "_" + containerId + "_" + productId
            );

            if (err)
                err.innerHTML = "";

            if (ctrl)
                ctrl.classList.remove("input-error");
        }

        function toggleSize(ctrl, originalSize) {

            const parts = ctrl.id.split('_');

            const containerId = parts[1];
            const productId = parts[2];

            const card = ctrl.closest(".product-card");

            const type = card.querySelector(
                "#type_" + containerId + "_" + productId
            );

            const size = card.querySelector(
                "#size_" + containerId + "_" + productId
            );


            if (type.value === "Custom") {

                size.disabled = false;

            } else {

                size.disabled = true;
                size.value = originalSize;

            }
        }

        function searchProducts() {

            let text =
                document.getElementById("txtSearch")
                    .value
                    .toLowerCase()
                    .trim();

            if (text === "") {
                renderInitial();
                document.getElementById("divTrending").style.display = "block";
                document.getElementById("divRegular").style.display = "block";
                document.getElementById("divSearch").style.display = "none";

                return;
            }

            document.getElementById("divTrending").style.display = "none";
            document.getElementById("divRegular").style.display = "none";
            document.getElementById("divSearch").style.display = "block";

            let filtered =
                allProducts.filter(x =>
                    x.ProductName
                        .toLowerCase()
                        .includes(text)
                );

            renderCards(
                filtered,
                "searchContainer"
            );
        }

        function addToCart(btn, containerId, productId) {

            const card = btn.closest(".product-card");

            const typeCtrl = card.querySelector(
                "#type_" + containerId + "_" + productId
            );

            const sizeCtrl = card.querySelector(
                "#size_" + containerId + "_" + productId
            );

            const qtyCtrl = card.querySelector(
                "#qty_" + containerId + "_" + productId
            );

            const typeErr = card.querySelector(
                "#typeErr_" + containerId + "_" + productId
            );

            const sizeErr = card.querySelector(
                "#sizeErr_" + containerId + "_" + productId
            );

            const qtyErr = card.querySelector(
                "#qtyErr_" + containerId + "_" + productId
            );


            let Type = typeCtrl.value;
            let size = sizeCtrl.value;
            let qty = qtyCtrl.value.trim();


            // clear errors

            typeErr.innerHTML = "";
            sizeErr.innerHTML = "";
            qtyErr.innerHTML = "";

            typeCtrl.classList.remove("input-error");
            sizeCtrl.classList.remove("input-error");
            qtyCtrl.classList.remove("input-error");


            let valid = true;


            if (Type === "") {
                typeErr.innerHTML = "Please select type.";
                typeCtrl.classList.add("input-error");
                valid = false;
            }


            if (size === "") {
                sizeErr.innerHTML = "Please select size.";
                sizeCtrl.classList.add("input-error");
                valid = false;
            }


            if (qty === "" || parseInt(qty) <= 0) {
                qtyErr.innerHTML = "Please enter quantity.";
                qtyCtrl.classList.add("input-error");
                valid = false;
            }


            if (!valid) {
                return false;
            }

            let productName =
                card.querySelector(
                    "#name_" + containerId + "_" + productId
                ).innerText.trim();


            let imgN =
                card.querySelector(
                    "#img_" + containerId + "_" + productId
                ).src;


            imgN = "~/" + imgN.split("/Content/")[1];


            fetch("PlaceOrder.aspx/AddToCart", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    productId: productId,
                    productN: productName,
                    size: size,
                    productType: Type,
                    qty: qty,
                    imagename: imgN
                })
            })
                .then(r => r.json())
                .then(() => {

                    Swal.fire({
                        icon: "success",
                        title: "Added To Cart",
                        timer: 1200,
                        showConfirmButton: false
                    });


                    qtyCtrl.value = "";

                    loadCartData();
                    renderInitial();
                });
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

        function getconfirmation() {
            Swal.fire({
                title: 'Ready to Checkout?',
                html: `
            <div>
                Are you sure you don't want any more products?<br>
                You can continue shopping or proceed to your cart.
            </div>
        `,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Go to Cart',
                cancelButtonText: 'Keep Shopping',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = '/Admin/OrderList.aspx';
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="header-row">
        <div>
            <h2 class="fw-bold" style="margin: 0; white-space: nowrap;">Product List</h2>
            <div style="margin-top: 15px;">
                <h6 class="product-link">
                    <a href="/Admin/OrderHistory.aspx"><i>My Orders</i></a>
                </h6>
            </div>
        </div>

        <div class="header-right">
            <input type="text"
                id="txtSearch"
                class="search-box"
                autocomplete="off"
                placeholder="Search Product..." />

            <div style="position: relative; display: inline-block; flex-shrink: 0;">
                <button type="button" class="btn" onclick="getconfirmation()">
                    <i class="bi bi-cart" style="font-size: 20px;"></i>
                </button>
                <span id="cartCount" style="display: none; position: absolute; top: -6px; right: -6px; background: #e53935; color: #fff; font-size: 11px; font-weight: 600; min-width: 18px; height: 18px; border-radius: 50%; align-items: center; justify-content: center; padding: 0 3px;">0</span>
            </div>
        </div>
    </div>
    <br />
    <div id="divTrending">

        <div class="title-line"><i><b>Trending Products</b></i></div>

        <div id="trendingContainer"
            class="product-container">
        </div>

    </div>

    <div id="divRegular">

        <div class="title-line"><i><b>Regular Products</b></i></div>

        <div id="regularContainer"
            class="product-container">
        </div>

    </div>

    <div id="divSearch"
        style="display: none;">

        <div class="title-line"><i><b>Search Results</b></i></div>

        <div id="searchContainer"
            class="product-container">
        </div>

    </div>

    <div id="imgModal"
        class="img-modal"
        onclick="closeModal()">

        <img id="modalImg">
    </div>
</asp:Content>
