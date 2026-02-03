// language=JQuery-CSS
(function () {
    $(function () {
        $('#create-type-field').customSelect($('#create-type-list').find('li'));
        return $("#advanced-toggle").click(function () {
            var advanced_toggle = $('#advanced-toggle');
            var advanced_open = $('#advanced-open');
            advanced_toggle.find(".more").toggleClass("d-none");
            advanced_toggle.find(".less").toggleClass("d-none");
            $("#advanced-closed").toggleClass("d-none");
            advanced_open.toggleClass("d-none");
            advanced_open.hide().fadeIn(); // bit of effect
            return false;
        });
    });

}).call();
