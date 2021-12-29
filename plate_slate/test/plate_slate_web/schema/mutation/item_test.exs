defmodule PlateSlateWeb.Schema.Mutation.Item do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.{Repo, Menu}

  import Ecto.Query

  setup do
    PlateSlate.Dev.Seeds.run(Mix.env())

    category_id =
      from(t in Menu.Category, where: t.name == "Sandwiches")
      |> Repo.one!()
      |> Map.fetch!(:id)
      |> to_string()

    {:ok, category_id: category_id}
  end

  @query """
    mutation ($item: ItemInput) {
      createItem(input: $item) {
        item {
          name
          description
          price
        }
        errors {
          key
          message
        }
      }
    }
  """

  test "createItem field creates an item", %{category_id: category_id} do
    item = %{
      "name" => "French Dip",
      "description" => "Roast beef, onions ...",
      "price" => "5.75",
      "category_id" => category_id
    }

    conn = post(build_conn(), "/api", query: @query, variables: %{item: item})

    assert json_response(conn, 200) == %{
             "data" => %{
               "createItem" => %{
                 "errors" => nil,
                 "item" => %{
                   "description" => "Roast beef, onions ...",
                   "name" => "French Dip",
                   "price" => "5.75"
                 }
               }
             }
           }
  end

  test "creating a item with an existing name fails", %{category_id: category_id} do
    item = %{
      "name" => "Reuben",
      "description" => "Roast beef, onions ...",
      "price" => "5.75",
      "category_id" => category_id
    }

    conn = post(build_conn(), "/api", query: @query, variables: %{item: item})

    assert json_response(conn, 200) == %{
             "data" => %{
               "createItem" => %{
                 "errors" => [%{"key" => "name", "message" => "has already been taken"}],
                 "item" => nil
               }
             }
           }
  end
end
