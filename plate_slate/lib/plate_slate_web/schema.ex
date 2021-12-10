defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  import Ecto.Query

  alias PlateSlateWeb.Resolvers.{Menu}

  query do
    @desc "The list of available items on the menu"
    field :menu_items, list_of(:menu_item) do
      arg(:matching, :string)

      resolve(&Menu.menu_items/3)
    end
  end

  object :menu_item do
    field :id, :id
    field :name, :string
    field :description, :string
  end
end
