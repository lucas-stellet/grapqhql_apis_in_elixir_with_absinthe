defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  alias PlateSlate.Menu
  alias PlateSlateWeb.Resolvers.Item

  import_types(__MODULE__.Menu)
  import_types(__MODULE__.Item.Types)
  import_types(__MODULE__.Category.Types)
  import_types(__MODULE__.CustomScalar.Date)
  import_types(__MODULE__.CustomScalar.Decimal)

  query do
    @desc "Search query for itens and categories."
    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))

      resolve(fn _, %{matching: term}, _ ->
        {:ok, Menu.search(term)}
      end)
    end

    import_fields(:item_queries)
    import_fields(:category_queries)
  end

  mutation do
    field :create_item, :item_result do
      arg(:input, non_null(:item_input))
      resolve(&Item.create_item/3)
    end
  end

  @desc "Add an order to he list"
  enum :sort_order do
    value(:asc)
    value(:desc)
  end

  object :input_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end
end
