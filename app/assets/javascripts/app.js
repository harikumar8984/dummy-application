(function($) {
   $(function() {
      var app = {};

      app.tabComponent = {
         showTab: function(selector) {
            var $tab = $(selector);
            // find that matches the selector on the link
            var $tabLink = $('a.tab-link[href="' + selector + '"]');

            // set current tab link and hides all the siblings tab link
            $tabLink.parent().children().removeClass('active');
            $tabLink.addClass('active');

            // open/sets current tab and hides all the siblings tab
            $tab.parent().children().removeClass('active');
            $tab.addClass('active');
         }
      };
      // returns an object if it's viewed from the mobile
      // others returns undefined
      app.isMobile = function() {
         var userAgent = window.navigator.userAgent;
         var
            ios = /webOS|iPhone|iPad|iPod/i,
            android = /Android/i,
            blackberry = /BlackBerry/i,
            ie = /IEMobile/i,
            opera = /Opera Mini/i,
            mobile,
            match;

         mobile = new RegExp(
                     android.source + '|' +
                     ios.source + '|' +
                     blackberry.source + '|' +
                     ie.source + '|' +
                     opera.source, 'i');
         match = userAgent.match(mobile);

         if ( match ) {
            var o = {};

            match = match[0];

            if( match.search(ios) > -1 ) {
               o.ios = true;
            }else if( match.search(android) > -1) {
               o.android = true;
            }else if( match.search(blackberry) > -1) {
               o.blackberry = true
            }else if( match.search(ie) > -1) {
               o.ie = true;
            }else if( match.search(opera) > -1) {
               o.opera = true;
            }

            return o;
         }
      };

      $('.tab-link').on('click', function(e) {
         e.preventDefault();
         if( $(this).hasClass('external') )
            return;

         $('#tab-links').attr('data-name', this.dataset.name);
         app.tabComponent.showTab($(this).attr('href'));
          $('.error-email-label').hide();
          $('#user_registration_form').find('input[type=text]').val('');
          $('#user_registration_form').find('input[type=email]').val('');
          $('#user_registration_form').find('input[type=password]').val('');
      });

      if( app.isMobile() ) {
         FastClick.attach(document.body);
      }
   });
})(window.jQuery);