defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  @query_all """
  {
    menuItems {
      name
    }
  }
  """

  @query_by_name """
  {
    menuItems(matching: "reu") {
      name
    }
  }
  """

  @query_with_bad_value """
  {
    menuItems(matching: 123) {
      name
    }
  }
  """

  @query_with_variable_by_name """
    query($term: String) {
      menuItems(matching: $term) {
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

  test "menuItems returns a list of menu items", %{conn: conn} do
    conn = post(conn, "/api", %{query: @query_all})

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

  test "menuItems(matching: name) returns menu items filtered by name", %{conn: conn} do
    response = post(conn, "/api", %{query: @query_by_name})

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @variables %{"term" => "reu"}
  test "menuItems(matching: $term) returns menu items filtered by name by variable", %{conn: conn} do
    response = post(conn, "/api", %{query: @query_with_variable_by_name, variables: @variables})

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  test "menuItems(matching: bad value) returns an error", %{conn: conn} do
    response = post(conn, "/api", %{query: @query_with_bad_value})

    assert %{
             "errors" => [
               %{
                 "message" => message
               }
             ]
           } = json_response(response, 200)

    assert message == "Argument \"matching\" has invalid value 123."
  end
end
