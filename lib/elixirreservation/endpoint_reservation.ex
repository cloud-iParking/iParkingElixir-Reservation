defmodule Api.EndpointReservation do
    use Plug.Router

    alias Api.Views.ReservationView
    alias Api.Models.Reservation
    alias Api.Plugs.JsonTestPlug

    @api_port Application.get_env(:api_test, :api_port)
    @api_host Application.get_env(:api_test, :api_host)
    @api_scheme Application.get_env(:api_test, :api_scheme)

    plug :match
    plug :dispatch
    plug JsonTestPlug
    plug :encode_response
    plug Corsica, origins: "http://localhost:4200"

    defp encode_response(conn, _) do
        conn
        |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
    end

    get "/", private: %{view: ReservationView}  do
      params = Map.get(conn.params, "filter", %{})

      {_, reservations} =  Reservation.find(params)

      conn
      |> put_status(200)
      |> assign(:jsonapi, reservations)
    end

    get "/:id", private: %{view: ReservationView}  do
      {parsedId, ""} = Integer.parse(id)

      case Reservation.get(parsedId) do
        {:ok, reservation} ->
          conn
          |> put_status(200)
          |> assign(:jsonapi, reservation)

        :error ->
          conn
          |> put_status(404)
          |> assign(:jsonapi, %{"error" => "'reservation' not found"})
      end
    end


    post "/add", private: %{view: ReservationView}  do
        {id, is_active, timestamp, loaner, parking_place} = {
            Map.get(conn.params, "id", nil),
            Map.get(conn.params, "is_active", nil),
            Map.get(conn.params, "timestamp", nil),
            Map.get(conn.params, "loaner", nil),
            Map.get(conn.params, "parking_place", nil)
        }

        cond do
            is_nil (is_active) || is_nil (timestamp) || is_nil (loaner) || is_nil(parking_place)->
                conn
                |> put_status(400)
                |> assign(:jsonapi, %{error: "A field is missing!"})

            true ->
            case %Reservation{ id: id,
                   is_active: is_active,
                   timestamp: timestamp,
                   loaner: loaner,
                   parking_place: parking_place}|> Reservation.saveReservation do
                {:ok, returnedReservation} ->
                    uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"

                    conn
                    |> put_resp_header("location", "#{uri}#{id}")
                    |> put_status(200)
                    |> assign(:jsonapi, returnedReservation)
                :error ->
                    conn
                        |> put_status(500)
                        |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
            end
        end
      end

    post "/update", private: %{view: ReservationView}  do
      {id, is_active, timestamp, loaner, parking_place} = {
        Map.get(conn.params, "id", nil),
        Map.get(conn.params, "is_active", nil),
        Map.get(conn.params, "timestamp", nil),
        Map.get(conn.params, "loaner", nil),
        Map.get(conn.params, "parking_place", nil)
      }

      cond do
        is_nil (is_active) || is_nil (timestamp) || is_nil (loaner) || is_nil(parking_place)->
          conn
          |> put_status(400)
          |> assign(:jsonapi, %{error: "A field is missing!"})

        true ->
          case %Reservation{ id: id,
                 is_active: is_active,
                 timestamp: timestamp,
                 loaner: loaner,
                 parking_place: parking_place}|> Reservation.updateReservation do
            {:ok, returnedReservation} ->
              uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"

              conn
              |> put_resp_header("location", "#{uri}#{id}")
              |> put_status(200)
              |> assign(:jsonapi, returnedReservation)
            :error ->
              conn
              |> put_status(500)
              |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
          end
      end
    end
end
