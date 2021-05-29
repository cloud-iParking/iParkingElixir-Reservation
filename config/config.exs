use Mix.Config

config :elixirreservation,
  db_host: "localhost",
  db_port: 27017,
  db_db: "reservation",
  db_tables: [
    "reservations"
  ],

api_host: "localhost",
api_port: 8080,
api_scheme: "http"
