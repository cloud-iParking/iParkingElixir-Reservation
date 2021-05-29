defmodule Api.Views.ReservationView do
    use JSONAPI.View

    def fields, do: [:id, :is_active, :timestamp, :loaner, :parking_place]
    def type, do: "reservation"
    def relationships, do: []
  end
