<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Designed for Acryshade Laminates Pvt. Ltd.">
    <link rel="icon" type="image/png" href="../Content/assets/images/CompanyLogo/CompLogo.jpg">
    <title>Acryshade Laminates</title>
    <link rel="stylesheet" href="../Content/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="../Content/assets/vendors/bootstrap-icons/bootstrap-icons.css">
    <link rel="stylesheet" href="../Content/assets/css/login.css">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <style>
        /* --- Forgot password panel styles (kept local so nothing in login.css needs to change) --- */
        .fp-step {
            display: none;
        }

            .fp-step.active {
                display: block;
            }

        .fp-otp-input {
            letter-spacing: 8px;
            font-size: 1.4rem;
            text-align: center;
        }

        .fp-back-link {
            display: inline-block;
            margin-top: 12px;
            cursor: pointer;
            font-size: 0.9rem;
        }

        #loginSection.d-none,
        #forgotSection.d-none {
            display: none !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <%-- Required so PageMethods (SendOtp / VerifyOtp / ResetPassword) can be called from JS below --%>
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" EnablePartialRendering="true"></asp:ScriptManager>

        <div class="login-page">

            <!-- Left: product photo panel. Swap the background-image path
                 in login.css (.login-left) for your own laminate sheet photo. -->
            <div class="login-left">
                <div class="login-left-scrim"></div>
                <div class="brand-badge">
                    <img src="../Content/assets/images/CompanyLogo/BlackLogo.png" alt="Acryshade Laminates" />
                </div>
                <div class="login-left-caption d-none">
                    <h2>Where Laminate<br />
                        Shine With Style</h2>
                    <p class="d-none">Acrylic laminate sheet production, managed end to end.</p>
                </div>
            </div>

            <!-- Right: sign-in form -->
            <div class="login-right">
                <div class="login-form-wrap">
                    <div class="auth-box card">
                        <div class="card-block">

                            <!-- ============ SIGN IN SECTION ============ -->
                            <div id="loginSection">
                                <div class="row m-b-20">
                                    <div class="col-md-12">
                                        <h3 class="text-left">Welcome Back</h3>
                                        <p class="login-subtitle">Enter your credentials to access the dashboard</p>
                                    </div>
                                </div>
                                <div class="form-group form-primary">
                                    <asp:TextBox ID="txtUsername" runat="server" class="form-control" placeholder="Your Email Address" autocomplete="off"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" Display="Dynamic" ErrorMessage="Please Enter Your Email Address"
                                        ControlToValidate="txtUsername" ValidationGroup="form1" ForeColor="Red" SetFocusOnError="true"></asp:RequiredFieldValidator>
                                    <span class="form-bar"></span>
                                </div>
                                <div class="form-group form-primary mt-3">
                                    <asp:TextBox ID="txtPassword" runat="server" class="form-control" placeholder="Password" TextMode="Password" autocomplete="off"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" Display="Dynamic" ErrorMessage="Please Enter Your Password"
                                        ControlToValidate="txtPassword" ValidationGroup="form1" ForeColor="Red" SetFocusOnError="true"></asp:RequiredFieldValidator>
                                    <span class="form-bar"></span>
                                </div>
                                <div class="row m-t-25 text-left">
                                    <div class="col-12">
                                        <div class="checkbox-fade fade-in-primary d-">
                                            <label>
                                                <asp:CheckBox ID="chkremember" runat="server" />
                                                <span class="cr"><i class="cr-icon icofont icofont-ui-check txt-primary"></i></span>
                                                <span class="text-inverse">Remember me</span>
                                            </label>
                                        </div>
                                        <div class="forgot-phone text-right f-right">
                                        </div>
                                    </div>
                                </div>
                                <div class="row m-t-20">
                                    <div class="col-md-12">
                                        <asp:Button ID="btnsave" OnClick="btnsave_Click" runat="server" Text="Sign in" ValidationGroup="form1" CssClass="btn btn-light-primary btn-md btn-block waves-effect waves-light text-center m-b-2" />
                                    </div>
                                    <div class="col-md-12 text-end">
                                        <a class="fp-back-link" id="lnkForgotPassword" style="cursor: pointer;">Forget Password</a>
                                    </div>
                                </div>
                            </div>

                            <!-- ============ FORGOT PASSWORD SECTION ============ -->
                            <div id="forgotSection" class="d-none">

                                <!-- Step 1: Email / Username -->
                                <div id="fpStep1" class="fp-step active">
                                    <div class="row m-b-20">
                                        <div class="col-md-12">
                                            <h3 class="text-left">Forgot Password</h3>
                                            <p class="login-subtitle">Enter your registered email address, we'll send you an OTP</p>
                                        </div>
                                    </div>
                                    <div class="form-group form-primary">
                                        <input type="text" id="fpEmail" class="form-control" placeholder="Your Register Email Address" autocomplete="off" />
                                        <span class="form-bar"></span>
                                        <span id="fpEmailFeedback" class="fp-email-feedback"></span>
                                    </div>
                                    <div class="row m-t-20">
                                        <div class="col-md-12">
                                            <button type="button" id="btnSendOtp" class="btn btn-light-primary btn-md btn-block waves-effect waves-light text-center m-b-2">Send OTP</button>
                                        </div>
                                        <div class="col-md-12 text-end">
                                            <a class="fp-back-link" id="lnkBackToLogin1">&larr; Back to Sign in</a>
                                        </div>
                                    </div>
                                </div>

                                <!-- Step 2: OTP -->
                                <div id="fpStep2" class="fp-step">
                                    <div class="row m-b-20">
                                        <div class="col-md-12">
                                            <h3 class="text-left">Enter OTP</h3>
                                            <p class="login-subtitle">We've sent a 6-digit code to <span id="fpEmailDisplay"></span></p>
                                        </div>
                                    </div>
                                    <div class="form-group form-primary">
                                        <input type="text" id="fpOtp" class="form-control fp-otp-input" placeholder="------" maxlength="6" inputmode="numeric" pattern="[0-9]*" autocomplete="off" />
                                        <span class="form-bar"></span>
                                    </div>
                                    <div class="row m-t-20">
                                        <div class="col-md-12">
                                            <button type="button" id="btnVerifyOtp" class="btn btn-light-primary btn-md btn-block waves-effect waves-light text-center m-b-2">Verify OTP</button>
                                        </div>
                                        <div class="col-md-12 text-end">
                                            <a class="fp-back-link" id="lnkResendOtp">Resend OTP</a>
                                            &nbsp;|&nbsp;
                                            <a class="fp-back-link" id="lnkBackToLogin2">Back to Sign in</a>
                                        </div>
                                    </div>
                                </div>

                                <!-- Step 3: New password -->
                                <div id="fpStep3" class="fp-step">
                                    <div class="row m-b-20">
                                        <div class="col-md-12">
                                            <h3 class="text-left">Reset Password</h3>
                                            <p class="login-subtitle">Enter and confirm your new password</p>
                                        </div>
                                    </div>
                                    <div class="form-group form-primary">
                                        <input type="password" id="fpNewPassword" class="form-control" placeholder="New Password" autocomplete="off" />
                                        <span class="form-bar"></span>
                                    </div>
                                    <div class="form-group form-primary mt-3">
                                        <input type="password" id="fpConfirmPassword" class="form-control" placeholder="Confirm Password" autocomplete="off" />
                                        <span class="form-bar"></span>
                                    </div>
                                    <div class="row m-t-20">
                                        <div class="col-md-12">
                                            <button type="button" id="btnUpdatePassword" class="btn btn-light-primary btn-md btn-block waves-effect waves-light text-center m-b-2">Update Password</button>
                                        </div>
                                        <div class="col-md-12 text-end">
                                            <a class="fp-back-link" id="lnkBackToLogin3">&larr; Back to Sign in</a>
                                        </div>
                                    </div>
                                </div>

                            </div>
                            <!-- ============ /FORGOT PASSWORD SECTION ============ -->

                        </div>
                    </div>
                </div>
            </div>

        </div>
    </form>

    <script type="text/javascript">

        document.addEventListener('DOMContentLoaded', function () {
            LoadLeads();

            // Refresh every minute
            setInterval(LoadLeads, 80000);
        });

        function LoadLeads() {
            $.ajax({
                type: "POST",
                url: "LeadGeneration/GetLeads.aspx/GenerateLongToken",   // Change path if needed
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                },
                error: function (xhr) {
                }
            });
        }


        (function () {
            var loginSection = document.getElementById("loginSection");
            var forgotSection = document.getElementById("forgotSection");

            var step1 = document.getElementById("fpStep1");
            var step2 = document.getElementById("fpStep2");
            var step3 = document.getElementById("fpStep3");

            var fpEmail = document.getElementById("fpEmail");
            var fpEmailFeedback = document.getElementById("fpEmailFeedback");
            var fpEmailDisplay = document.getElementById("fpEmailDisplay");
            var fpOtp = document.getElementById("fpOtp");
            var fpNewPassword = document.getElementById("fpNewPassword");
            var fpConfirmPassword = document.getElementById("fpConfirmPassword");
            var btnSendOtp = document.getElementById("btnSendOtp");

            var emailIsRegistered = false; // gate flag; Send OTP re-checks anyway, this just drives UI state

            function showLogin() {
                forgotSection.classList.add("d-none");
                loginSection.classList.remove("d-none");
            }

            function showForgot() {
                loginSection.classList.add("d-none");
                forgotSection.classList.remove("d-none");
                goToStep(step1);
                fpEmail.value = "";
                fpOtp.value = "";
                fpNewPassword.value = "";
                fpConfirmPassword.value = "";
                setEmailFeedback("", "");
                emailIsRegistered = false;
            }

            function goToStep(step) {
                [step1, step2, step3].forEach(function (s) { s.classList.remove("active"); });
                step.classList.add("active");
            }

            function isValidEmail(value) {
                return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
            }

            function setEmailFeedback(text, state) {
                fpEmailFeedback.textContent = text;
                fpEmailFeedback.classList.remove("checking", "valid", "invalid");
                if (state) {
                    fpEmailFeedback.classList.add(state);
                }
            }

            document.getElementById("lnkForgotPassword").addEventListener("click", function (e) {
                e.preventDefault();
                showForgot();
            });

            document.getElementById("lnkBackToLogin1").addEventListener("click", function (e) { e.preventDefault(); showLogin(); });
            document.getElementById("lnkBackToLogin2").addEventListener("click", function (e) { e.preventDefault(); showLogin(); });
            document.getElementById("lnkBackToLogin3").addEventListener("click", function (e) { e.preventDefault(); showLogin(); });

            // ---- On blur: check whether the entered email is registered ----
            fpEmail.addEventListener("blur", function () {
                var email = fpEmail.value.trim();
                emailIsRegistered = false;

                if (email === "") {
                    setEmailFeedback("", "");
                    return;
                }

                if (!isValidEmail(email)) {
                    setEmailFeedback("Please enter a valid email address.", "invalid");
                    return;
                }

                setEmailFeedback("Checking...", "checking");

                PageMethods.CheckEmailExists(email,
                    function (result) {
                        // Ignore stale responses if the user already changed the field again
                        if (fpEmail.value.trim() !== email) { return; }

                        if (result === true) {
                            emailIsRegistered = true;
                            setEmailFeedback("Email found. You can send an OTP.", "valid");
                        } else {
                            emailIsRegistered = false;
                            setEmailFeedback("No account found with this email address.", "invalid");
                        }
                    },
                    function (error) {
                        setEmailFeedback("Could not verify email right now. Please try again.", "invalid");
                    }
                );
            });

            // Clear stale feedback as soon as the user edits the field again
            fpEmail.addEventListener("input", function () {
                emailIsRegistered = false;
            });

            // ---- Step 1: send OTP ----
            btnSendOtp.addEventListener("click", function () {
                var email = fpEmail.value.trim();
                if (!isValidEmail(email)) {
                    Swal.fire("Invalid Email", "Please enter a valid email address.", "warning");
                    return;
                }

                if (!emailIsRegistered) {
                    Swal.fire("Not Registered", "This email is not registered with us.", "warning");
                    return;
                }

                PageMethods.SendOtp(email,
                    function (result) {
                        if (result === "OK") {
                            fpEmailDisplay.textContent = email;
                            goToStep(step2);
                            Swal.fire("OTP Sent", "Please check your inbox for the 6-digit code.", "success");
                        } else {
                            Swal.fire("Error", result, "error");
                        }
                    },
                    function (error) {
                        Swal.fire("Error", "Could not send OTP. Please try again.", "error");
                    }
                );
            });

            document.getElementById("lnkResendOtp").addEventListener("click", function (e) {
                e.preventDefault();
                btnSendOtp.click();
            });

            // ---- Step 2: verify OTP ----
            document.getElementById("btnVerifyOtp").addEventListener("click", function () {
                var email = fpEmail.value.trim();
                var otp = fpOtp.value.trim();

                if (!/^\d{6}$/.test(otp)) {
                    Swal.fire("Invalid OTP", "Please enter the 6-digit OTP.", "warning");
                    return;
                }

                PageMethods.VerifyOtp(email, otp,
                    function (result) {
                        if (result === "OK") {
                            goToStep(step3);
                        } else {
                            Swal.fire("Incorrect OTP", result, "error");
                        }
                    },
                    function (error) {
                        Swal.fire("Error", "Could not verify OTP. Please try again.", "error");
                    }
                );
            });

            // ---- Step 3: update password ----
            document.getElementById("btnUpdatePassword").addEventListener("click", function () {
                var email = fpEmail.value.trim();
                var pass = fpNewPassword.value;
                var confirm = fpConfirmPassword.value;

                if (!pass || pass.length < 6) {
                    Swal.fire("Weak Password", "Password must be at least 6 characters.", "warning");
                    return;
                }
                if (pass !== confirm) {
                    Swal.fire("Mismatch", "Password and Confirm Password do not match.", "warning");
                    return;
                }

                PageMethods.ResetPassword(email, pass, confirm,
                    function (result) {
                        if (result === "OK") {
                            Swal.fire("Success", "Your password has been updated. Please sign in.", "success")
                                .then(function () { showLogin(); });
                        } else {
                            Swal.fire("Error", result, "error");
                        }
                    },
                    function (error) {
                        Swal.fire("Error", "Could not update password. Please try again.", "error");
                    }
                );
            });
        })();

   </script>
</body>
</html>
