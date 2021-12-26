defmodule PlateSlateWeb.Schema.Menu do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers.{Category, Item}

  interface :search_result do
    field :name, :string

    resolve_type(fn
      %PlateSlate.Menu.Item{}, _ ->
        :item

      %PlateSlate.Menu.Category{}, _ ->
        :category

      _, _ ->
        nil
    end)
  end

  object :item_queries do
    @desc "The list of available items on the menu"

    field :items, list_of(:item) do
      arg(:filter, type: :item_filter)
      arg(:order, type: :sort_order, default_value: :asc)

      resolve(&Item.items/3)
    end
  end

  object :category_queries do
    @desc "The list of available categories on the menu"

    field :categories, list_of(:category) do
      arg(:filter, type: :category_filter)
      arg(:order, type: :sort_order, default_value: :asc)

      resolve(&Category.categories/3)
    end
  end
end
