document.querySelectorAll(".dropdown-toggle-menu").forEach(function (menu) {

    menu.addEventListener("click", function (e) {

        e.preventDefault();
        e.stopPropagation();

        let parent = this.parentElement;

        parent.classList.toggle("active");

    });

});

function autoClearProductImages() {
    debugger;
    Object.keys(localStorage).forEach(function (key) {

        if (key.startsWith("ProductImage_")) {
            hasImageData = true;
            localStorage.removeItem(key);
        }
    });
}