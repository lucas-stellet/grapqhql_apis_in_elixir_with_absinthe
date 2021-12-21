defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  alias PlateSlate.Menu

  import_types(__MODULE__.Menu)
  import_types(__MODULE__.Item.Types)
  import_types(__MODULE__.Category.Types)

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

  @desc "Add an order to he list"
  enum :sort_order do
    value(:asc)
    value(:desc)
  end

  query do
    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))

      resolve(fn _, %{matching: term}, _ ->
        {:ok, Menu.search(term)}
      end)
    end

    import_fields(:item_queries)
    import_fields(:category_queries)
  end
end
