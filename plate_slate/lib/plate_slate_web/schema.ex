defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  import_types(PlateSlateWeb.Types.Date)

  alias PlateSlateWeb.Resolvers.{Menu}

  @desc "Add an order to he list"
  enum :sort_order do
    value(:asc)
    value(:desc)
  end

  @desc "FIltering options for the menu items list"

  input_object :menu_item_filter do
    @desc "Matching a name"
    field :name, :string

    @desc "Matching a category name"
    field :category, :string

    @desc "Matching a tag"
    field :tag, :string

    @desc "Priced above a value"
    field :priced_above, :float

    @desc "Priced below a value"
    field :priced_below, :float

    @desc "Added to the menu after this date"
    field :added_after, :date

    @desc "Added to the menu before this date"
    field :added_before, :date
  end

  query do
    @desc "The list of available items on the menu"
    field :menu_items, list_of(:menu_item) do
      arg(:filter, type: :menu_item_filter)
      arg(:order, type: :sort_order, default_value: :asc)

      resolve(&Menu.menu_items/3)
    end
  end

  object :menu_item do
    field :id, :id
    field :name, :string
    field :description, :string
    field :added_on, :date
  end
end
