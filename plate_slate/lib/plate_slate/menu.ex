defmodule PlateSlate.Menu do
  import Ecto.Query

  alias PlateSlate.Menu.{Category, Item}
  alias PlateSlate.Repo

  def list_items(args) do
    args
    |> Enum.reduce(Item, fn
      {:order, order}, query ->
        query |> order_by({^order, :name})

      {:filter, filter}, query ->
        query |> filter_with(filter)
    end)
    |> Repo.all()
  end

  def list_categories(args) do
    args
    |> Enum.reduce(Category, fn
      {:order, order}, query ->
        query |> order_by({^order, :name})

      {:filter, filter}, query ->
        query |> filter_with(filter)
    end)
    |> Repo.all()
  end

  @search [Item, Category]
  def search(term) do
    pattern = "%#{term}%"
    Enum.flat_map(@search, &search_ecto(&1, pattern))
  end

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_with(query, filter) do
    Enum.reduce(filter, query, fn
      {:name, name}, query ->
        from q in query, where: ilike(q.name, ^"%#{name}%")

      {:description, description}, query ->
        from q in query, where: ilike(q.description, ^"%#{description}%")

      {:priced_above, price}, query ->
        from q in query, where: q.price >= ^price

      {:priced_below, price}, query ->
        from q in query, where: q.price <= ^price

      {:added_before, date}, query ->
        from q in query, where: q.added_on <= ^date

      {:added_after, date}, query ->
        from q in query, where: q.added_on >= ^date

      {:category, category_name}, query ->
        from q in query,
          join: c in assoc(q, :category),
          where: ilike(c.name, ^"%#{category_name}%")

      {:tag, tag_name}, query ->
        from q in query, join: t in assoc(q, :tags), where: ilike(t.name, ^"%#{tag_name}%")
    end)
  end

  defp search_ecto(ecto_schema, pattern) do
    Repo.all(
      from q in ecto_schema, where: ilike(q.name, ^pattern) or ilike(q.description, ^pattern)
    )
  end
end
