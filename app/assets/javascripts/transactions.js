$(document).ready(function () {
    $('.rkv_choose_plan').click(function(){
        show_payment_form($(this))
    });
    if ( window.location.search.indexOf('payment_error=true') > 0) {
        $('#plan_select_form').hide();
        $('#payment_form').show();
        $('#payment_form .rkv_items_list_container .rkv_susbcription_title').text('Nuryl ' +  $('#payment_form #subscription_type').val() + ' Subscription')
        $('#payment_form .rkv_items_list_container .rkv_price').text( $('#payment_form #amount').val());
        $('#payment_form .rkv_subscription_table .rkv_total_amount').text( $('#payment_form #amount').val());
    }
});
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
            $('#payment_error .message').text(json['data']['base'][0]);
        }
    });
}
function show_payment_form(this_evt){
    $('#plan_select_form').hide();
    $('#payment_form').show();
    $('#payment_form #subscription_type').val((this_evt).parent().find('.rkv_plan_name').text());
    $('#payment_form #amount').val(parseFloat((this_evt).parent().find('.nuryl_price').text()));
    $('#payment_form .rkv_items_list_container .rkv_susbcription_title').text('Nuryl ' + (this_evt).parent().find('.rkv_plan_name').text() + ' Subscription')
    $('#payment_form .rkv_items_list_container .rkv_price').text((this_evt).parent().find('.nuryl_price').text());
    $('#payment_form .rkv_subscription_table .rkv_total_amount').text((this_evt).parent().find('.nuryl_price').text());
    //mix panel show page tracking
    mixpanel.identify(distinct_id);
    mixpanel.track(
        "W payment show"
    );
}
function mixpanel_transaction_entry(){
    mixpanel.identify(distinct_id);
    mixpanel.people.set({
        "$subscription_type": $('#payment_form #subscription_type').val(),
        "$amount": $('#payment_form #amount').val(),
        "$payment_type": 'Stripe'
    });
    mixpanel.track(
        "W payment creation"
    );
}