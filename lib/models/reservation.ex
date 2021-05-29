defmodule Api.Models.Reservation do
    @db_name Application.get_env(:api_test, :db_db)
    @db_table "reservations"

use Api.Models.ReservationRepository

defstruct [
    :id,
    :is_active,
    :timestamp,
    :loaner,
    :parking_place
  ]
end
