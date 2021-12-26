defmodule PlateSlateWeb.Schema.Item.Types do
  use Absinthe.Schema.Notation

  @desc "Filtering options for the menu item list"

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

  object :item do
    interfaces([:search_result])
    field :id, :id
    field :name, :string
    field :description, :string
    field :added_on, :date
  end
end
