require 'active_support/core_ext/integer/time'

Rails.application.configure do

  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Add the following line to disable forgery_protection_origin_check
  config.action_controller.forgery_protection_origin_check = false

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Set mailer default URL options for localhost
  host = 'localhost:3000'
  config.action_mailer.default_url_options = { host:, protocol: 'http' }

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # iframe設定
  config.action_dispatch.default_headers = {
    'X-Frame-Options' => 'ALLOW-FROM http://localhost:3000'
  }

  config.action_cable.disable_request_forgery_protection = true # CSRF保護の無効化

  config.importmap.enabled = true

  # WebSocketのリクエストの許可リスト
  config.action_cable.allowed_request_origins = ['http://localhost:3000']

  config.hosts.clear

  config.assets.debug = true
  config.assets.digest = false
  config.assets.compile = true

end
