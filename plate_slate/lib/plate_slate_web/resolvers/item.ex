defmodule PlateSlateWeb.Resolvers.Item do
  alias PlateSlate.Menu

  def items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def items_for_category(category, _, _) do
    query = Ecto.assoc(category, :items)
    {:ok, PlateSlate.Repo.all(query)}
  end
end
