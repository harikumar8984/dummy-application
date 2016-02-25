
$(document).ready(function () {

    $(".clndr-cls").datepicker({
        clearBtn: true,
        autoclose: true,
        format: 'mm/dd/yyyy'
    });

    $('#input_email').focusout(function(event){
        is_email_unique();
    });

    $('#input_email').on('keyup', (function(event) {
        $('.error-email-label').text('');
    }));

    $('#signup-modal').on('shown.bs.modal', function() {
        $('#input_email').val('');
    })

});

function is_email_unique(){
    var email_str = $('#input_email').val()
    $.ajax({
        type: "GET",
        url: '/api/v1/users/validate_unique_email?email='+email_str, //sumbits it to the given url of the form
        dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
    }).success(function (json) {
        if (json['success'] == false){
            $('.error-email-label').text(json['messages'][0]);
            $('.sign-up-button').prop('disabled', true);
        }
        else{
            $('.sign-up-button').prop('disabled', false);
        }
    });
}