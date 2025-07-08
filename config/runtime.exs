import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/signbank start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :signbank, SignbankWeb.Endpoint, server: true
end

config :signbank, SimpleS3Upload,
  access_key_id: System.get_env("S3_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("S3_SECRET_ACCESS_KEY"),
  bucket: System.get_env("S3_BUCKET"),
  region: System.get_env("S3_REGION"),
  scheme: System.get_env("S3_SCHEME"),
  host: System.get_env("S3_HOST"),
  port: System.get_env("S3_PORT")

config :signbank, :media_url, System.get_env("MEDIA_URL")
config :signbank, :corpus_root, System.get_env("CORPUS_ROOT")
config :signbank, :upload_staging, System.get_env("UPLOAD_STAGING_DIR") || "/var/tmp/signbank"

config :signbank,
  application_name: System.get_env("APPLICATION_NAME") || "Signbank"

config :signbank, Signbank.Mailer, from_address: System.get_env("MAIL_FROM") || "info@example.org"

config :ex_aws,
  http_client: ExAws.Request.Req,
  access_key_id: System.get_env("S3_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("S3_SECRET_ACCESS_KEY"),
  region: System.get_env("S3_REGION")

config :ex_aws, :s3,
  scheme: System.get_env("S3_SCHEME"),
  port: System.get_env("S3_PORT"),
  host: System.get_env("S3_HOST")

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :signbank, Signbank.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # :systemd or :console, defaults to :console
  config :signbank,
    logger: :systemd

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :signbank, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :signbank, SignbankWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # NOTE: only postmark has been tested, but this *should* work
  cond do
    System.get_env("POSTMARK_API_KEY") ->
      config :signbank, Signbank.Mailer,
        adapter: Swoosh.Adapters.Postmark,
        api_key: System.get_env("POSTMARK_API_KEY")

    System.get_env("MAILGUN_API_KEY") ->
      config :signbank, Signbank.Mailer,
        adapter: Swoosh.Adapters.Mailgun,
        api_key: System.get_env("MAILGUN_API_KEY"),
        domain: System.get_env("MAILGUN_DOMAIN")

    System.get_env("SENDGRID_API_KEY") ->
      config :signbank, Signbank.Mailer,
        adapter: Swoosh.Adapters.Sendgrid,
        api_key: System.get_env("SENDGRID_API_KEY")
  end
end
