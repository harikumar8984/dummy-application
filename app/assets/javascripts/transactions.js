var subscription;
var paymentInitialized = false;

jQuery(function() {
    if(paymentInitialized) return;
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
    paymentInitialized = true;
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