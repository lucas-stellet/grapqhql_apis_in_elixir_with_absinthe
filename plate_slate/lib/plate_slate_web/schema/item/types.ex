defmodule PlateSlateWeb.Schema.Item.Types do
  use Absinthe.Schema.Notation

  @desc "Filtering options for the item list"
  input_object :item_filter do
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

  @desc "Input parameters for create item mutation."
  input_object :item_input do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:decimal)
    field :category_id, non_null(:id)
  end

  @desc "Item's representation."
  object :item do
    interfaces([:search_result])

    field :id, :id
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :added_on, :date
  end

  object :item_result do
    field :item, :item
    field :errors, list_of(:input_error)
  end
end
