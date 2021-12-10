defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  @query """
  {
    menuItems {
      name
    }
  }
  """

  setup do
    PlateSlate.Dev.Seeds.run(Mix.env())

    :ok
  end

  # test "menuItems field returns menu items" do
  #   conn = build_conn()
  #   conn = get(conn, "/api", query: @query)

  #   assert json_response(conn, 200) == %{}
  # end

  test "query: menuItems", %{conn: conn} do
    conn = post(conn, "/api", %{query: @query})

    assert json_response(conn, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"},
                 %{"name" => "Vada Pav"},
                 %{"name" => "French Fries"},
                 %{"name" => "Papadum"},
                 %{"name" => "Pasta Salad"},
                 %{"name" => "Water"},
                 %{"name" => "Soft Drink"},
                 %{"name" => "Lemonade"}
               ]
             }
           }
  end
end
