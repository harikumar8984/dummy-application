$(document).ready(function() {
	$('body').css('min-height', $(window).innerHeight())
	$('.rkv-search-bar').slideUp();
	$('.rkv-search-bar .rkv-close-btn, .rkv-menu-section ul a.rkv-search, .rkv-responsive-search-button').on('click', function(e) {
		$('.rkv-search-bar').slideToggle();
		e.preventDefault()
	})
	$('.rkv-responsive-menu-button').on('click', function() {
		$('.rkv-menu-section').slideToggle();
	})
})