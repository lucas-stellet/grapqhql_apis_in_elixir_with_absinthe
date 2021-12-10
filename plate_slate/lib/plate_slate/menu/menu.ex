defmodule PlateSlate.Menu do
  import Ecto.Query

  alias PlateSlate.Menu.Item
  alias PlateSlate.Repo

  def list_items(%{matching: name}) when is_binary(name) do
    Item
    |> where([i], ilike(i.name, ^"%#{name}%"))
    |> Repo.all()
  end

  def list_items(_), do: Repo.all(Item)
end
