import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dumbo_octopus, DumboOctopusWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "U0ZKjVhR5JAz0ZEcfBtI7NrjSG/p7AzWlQTFme7zJ+jii1KaAVbkEW912n7NiWZr",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
