defmodule Api.Models.ReservationRepository do

    alias Api.Helpers.MapHelper

    use Timex

    defmacro __using__(_) do
      quote do

        def get(id) do
          case Mongo.find_one(:mongo, @db_table, %{id: id}) do
            nil ->
              :error
            doc ->
              {:ok, doc |> MapHelper.string_keys_to_atoms |> merge_to_struct}
          end
        end

        def find(filters) when is_map(filters) do
          cursor = Mongo.find(:mongo, @db_table, filters)

          case cursor |> Enum.to_list do
            [] ->
                {:error, []}
              saved_docs ->
                {:ok, saved_docs |> Enum.map(&(merge_to_struct(MapHelper.string_keys_to_atoms(&1))))}
          end
        end

        def saveReservation(reservation) when is_map(reservation) do
          # Saving document
          case Mongo.insert_one(:mongo, @db_table, reservation) do
            {:ok, _} ->
              {:ok, reservation}
            _ ->
              :error
          end
        end

        def updateReservation(reservation) when is_map(reservation) do
          case Mongo.find_one_and_update(:mongo, @db_table, %{id: reservation.id}, %{"$set": %{is_active: reservation.is_active}}) do
            {:ok, _} ->
              {:ok, reservation}
            _ ->
              :error
          end
        end

        defp merge_to_struct(document) when is_map(document) do
          __struct__ |> Map.merge(document)
       end
      end
    end
  end
