var subscription;

$(document).ready(function () {
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
    return subscription.setupForm();
});
subscription = {
    setupForm: function (i) {
        return $('.stripe_payment-btn').bind('click', (function (e) {
            $('.stripe_payment-btn').attr('disabled', 'disabled');
            if ($('#card_number').length) {
                subscription.processCard();
                return false;
            } else {
                $is_submitted = true;
                return true;

            }
        }));

    },
    processCard: function () {
        var card;
        card = {
            number: $('#card_number').val(),
            cvc: $('#card_code').val(),
            expMonth: $('#card_month').val(),
            expYear: $('#card_year').val()
        };
        return Stripe.createToken(card, subscription.handleStripeResponse);

    },
    handleStripeResponse: function (status, response) {

        if (status === 200) {
            $('#card_id').val(response.id);
            $('.stripe_payment-btn').attr('disabled', 'disabled');
            $('#subscription_payment_form')[0].submit();
            mixpanel_transaction_entry();

        }
        else {
            $('#payment_error').text(response.error.message);
            return $('.stripe_payment-btn').attr('disabled', false);
        }
    }
};


