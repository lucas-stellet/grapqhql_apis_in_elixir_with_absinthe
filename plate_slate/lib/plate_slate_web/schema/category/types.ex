defmodule PlateSlateWeb.Schema.Category.Types do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers.Item

  input_object :category_filter do
    @desc "Matching a name"
    field :name, :string

    @desc "Matching a category description"
    field :description, :string
  end

  object :category do
    interfaces([:search_result])
    field :id, :id
    field :name, :string
    field :description, :string

    field :items, list_of(:item) do
      resolve(&Item.items_for_category/3)
    end
  end
end
