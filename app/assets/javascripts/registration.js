$(document).ready(function () {

    $('#input_zipcode').blur(function(){
        var zipcode = $(this).val();
        var zipRegex = /^((\d{5}-\d{4})|(\d{5})|([AaBbCcEeGgHhJjKkLlMmNnPpRrSsTtVvXxYy]\d[A-Za-z]\s?\d[A-Za-z]\d))$/;
        
        if (zipRegex.test(zipcode) || zipcode == '')
            $('#zipcode').text('');
        else   
          $('#zipcode').text('Invalid Format');
    });

    $('#input_email').focusout(function(event){
        is_email_unique();
    });

    $('#input_email').on('keyup', (function(event) {
        $('.error-email-label').hide();
    }));

    //if (!Modernizr.touch || !Modernizr.inputtypes.date) {
    //    $('input[type=date]')
    //        .attr('type', 'text')
    //        .datepicker({deide
    //            // Consistent format with the HTML5 picker
    //            format: 'mm/dd/yyyy'
    //        });
    //}

    $('#sign-up-link').click(function(){
        $('#sign-in-form').hide();
        $('#sign-up-form').show();
        $('.message').text('');
    });
    $('#sign-in-link').click(function(){
        $('#sign-up-form').hide();
        $('#sign-in-form').show();
        $('.message').text('');
    });

    if ( window.location.search.indexOf('invalid_login=true') > 0) {
        $('#sign-up-form').hide();
        $('#sign-in-form').show();
    }

});


function is_email_unique(){
    var email_str = $('#input_email').val();
    $.ajax({
        type: "GET",
        url: '/api/v1/users/validate_unique_email?email='+email_str, //sumbits it to the given url of the form
        dataType: "JSON", // you want a difference between normal and ajax-calls, and json is standard
        success: function (data) {
            if (data['success'] == false){
                $('.error-email-label').show();
                $('.error-email-label').text(data['messages'][0]);
                $('.sign-up-button').prop('disabled', true);
            }
            else{
                $('.error-email-label').hide();
                $('.sign-up-button').prop('disabled', false);
            }
        },
        error: function () {
        }
    });

}