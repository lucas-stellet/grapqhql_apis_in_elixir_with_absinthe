defmodule PlateSlateWeb.Schema.CustomScalar.Date do
  use Absinthe.Schema.Notation

  @desc "Date ISO 8601 default. Example: 2021-12-12 "
  scalar :date do
    parse(fn input ->
      case Date.from_iso8601(input.value) do
        {:ok, date} -> {:ok, date}
        _ -> :error
      end
    end)

    serialize(fn date ->
      Date.to_iso8601(date)
    end)
  end
end
