$(document).ready(function () {
    $('#input_email').focusout(function(event){
        is_email_unique();
    });

    $('#input_email').on('keyup', (function(event) {
        $('.error-email-label').hide();
    }));

    if (!Modernizr.touch || !Modernizr.inputtypes.date) {
        $('input[type=date]')
            .attr('type', 'text')
            .datepicker({
                // Consistent format with the HTML5 picker
                format: 'mm/dd/yyyy'
            });
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