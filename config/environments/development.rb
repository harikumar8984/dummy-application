Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address: 'localhost',
      port: 1025
  }
  ENV['S3_KEY'] = 'AKIAIK6UMPMPMJE5ZNJQ'
  ENV['S3_BUCKET_NAME'] = 'nuryl-qa'
  ENV['S3_SECRET'] = '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'
  ENV['Stripe_Api_Key'] = 'sk_test_vlIezxokqfZIJzW0YxCHxpRm'
  ENV['Stripe_Public_Key'] = 'pk_test_S7wpepqd0twI3CST8yiVPFUh'
  ENV['FreshDesk_Url'] = 'https://nuryl.freshdesk.com/'
  ENV['FreshDesk_Api_Key'] = 'euXCFjG0kIMOlNRzuuU'
  ENV['Support_Email'] = 'harikumar8984@gmail.com'
  ENV['In_App_Purchase_Subscription'] = 'com.nuryl.subscribe.'
  ENV['VTIGER_USERNAME'] = 'HARI'
  ENV['VTIGER_KEY'] = 'JZSpZjKgqfpha2v'
  ENV['VTIGER_URL'] = 'vtiger.nuryl.com'
  ENV['VIDEO_URL_LEARN_MORE'] = 'https://player.vimeo.com/video/158950941'
  ENV['VIDEO_URL_HOW_TO'] = 'https://player.vimeo.com/video/158950941'
  ENV['AFTER_SUBSCRIPTION_URL'] = 'http://www.nuryl.com/welcome-nuryl-user/'
  ENV['MIX_PANEL_TOKEN'] = 'de2017bc175cdbd26153202678cf2bdd'

end
