var subscription;
var pagelod = false;

$(document).ready(function () {
    if(pagelod) return;
    get_subscription_amount('Monthly');
    $('.subscription_type').on("change",function() {
        $('#stripe_error .message').text('');
        get_subscription_amount($(this).val());
    });
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
    pagelod = true;
    return subscription.setupForm();

});

subscription = {
    setupForm: function(i) {
            return $('.payment-btn').bind('click', (function (e) {
                $('.payment-btn').attr('disabled', 'disabled');
                if ($('#card_number').length) {
                    subscription.processCard();
                    return false;
                } else {
                    $is_submitted = true;
                    return true;
                }
            }));

    },
    processCard: function() {
        var card;
        card = {
            number: $('#card_number').val(),
            cvc: $('#card_code').val(),
            expMonth: $('#card_month').val(),
            expYear: $('#card_year').val()
        };
        return Stripe.createToken(card, subscription.handleStripeResponse);
    },
    handleStripeResponse: function(status, response) {

        if (status === 200) {
            $('#card_id').val(response.id);
            $('.payment-btn').attr('disabled', 'disabled');
            $('#stripe_registration')[0].submit();
        }
        else {
            $('#stripe_error').text(response.error.message);
            return  $('.payment-btn').attr('disabled', false);
        }
    }
};


function get_subscription_amount(type){
    $.ajax({
        type: "GET",
        url: '/api/v1/transactions/subscription_amount?subscription_type='+type+'&auth_token='+ $('#auth_token').val(), //sumbits it to the given url of the form
        dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
    }).success(function (json) {
        if (json['success'] == true){
            $('#input_sub_amount').val('$'+parseFloat(json['data']['amount']).toFixed(2));
        }
        else{
            $('#stripe_error .message').text(json['data']['base'][0]);
        }
    });
}