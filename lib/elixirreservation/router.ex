defmodule Api.Router do
  use Plug.Router

  plug Corsica, origins: "http://localhost:4200"
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )
  plug(:dispatch)

  forward("/reservation", to: Api.EndpointReservation)

  match _ do
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end
