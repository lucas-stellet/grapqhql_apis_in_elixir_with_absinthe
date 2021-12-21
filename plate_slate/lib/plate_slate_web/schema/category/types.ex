defmodule PlateSlateWeb.Schema.Category.Types do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers.Category

  input_object :category_filter do
    @desc "Matching a name"
    field :name, :string

    @desc "Matching a category description"
    field :description, :string
  end

  object :category do
    field :name, :string
    field :description, :string

    field :categories, list_of(:category) do
      resolve(&Category.categories/3)
    end
  end
end
