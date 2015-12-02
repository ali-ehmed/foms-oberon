// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require bootstrap-sprockets

//= require bootstrapValidator.min

//= require jquery.purr
//= require best_in_place
//= require best_in_place.jquery-ui
//= require best_in_place.purr

//= require bootstrap-switch.min
//= require bootstrap-switch

//= require jquery.bootstrap-touchspin
//= require jquery.bootstrap-touchspin.min

//= require bootstrap-datepicker

//= require sweetalert-dev
//= require sweetalert.min

//= require jasny-bootstrap.min
//= require jasny-bootstrap

//= require underscore.min

//= require bootstrap-notify

//= require turbolinks
//= require_tree .

// Purr Alert Plugin
(function($) {
  $.extend({
    purrAlert: function(text_value, options) {
      var settings;
      var $purrAlert = $(".purrAlert");

      if (text_value == null) {
        text_value = '';
      }

      if ($purrAlert.length) {
        $purrAlert.remove();
      }

      $("body").prepend('<div class="purrAlert" style="display:none;"><div class="row"><div class="col-md-2 col-xs-3 col-sm-2 purr-left"><div class="purr-icon"><span><i class="glyphicon glyphicon-ok-sign"></i></span>  </div></div><div class="col-md-9 col-xs-9 col-sm-10"><div class="purr-msg"></div></div></div></div>');
      var $new_purr = $(".purrAlert");

      settings = $.extend({
        html: false,
        text: text_value,
        text_bold: true,
        purr_type: "error"
      }, options);

      if (settings.html === true) {
        $new_purr.find(".purr-msg").html(settings.text);
      } else {
        $new_purr.find(".purr-msg").text(settings.text);
      }
      
      if (settings.text_bold === true) {
        $new_purr.css("font-weight", "bold");
      } else {
        $new_purr.css("font-weight", "normal");
      }

      switch(settings.purr_type) {
        case "error":
          $new_purr.addClass("purr_danger");
          $new_purr.find(".purr-icon span").html("<i class='fa fa-exclamation-triangle'></i> ");
          break;
        case "success":
          $new_purr.addClass("purr_success");
          $new_purr.find(".purr-icon span").html("<i class='glyphicon glyphicon-ok-sign'></i> ");
          break;
        case "warning":
          $new_purr.addClass("purr_warning");
          $new_purr.find(".purr-icon span").html("<i class='fa fa-ban'></i> ");
          break;
        case "info":
          $new_purr.addClass("purr_info");
          $new_purr.find(".purr-icon span").html("<i class='glyphicon glyphicon-info-sign'></i> ");
          break;
      }

      $new_purr.fadeIn(1000, function() {
        setTimeout(function() {
          $new_purr.fadeOut(1000, function() {
          	$(this).remove();
          });
        }, 5000);
      });
    }
  });
})(jQuery);