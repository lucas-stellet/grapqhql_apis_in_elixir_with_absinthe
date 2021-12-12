defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Dev.Seeds.run(Mix.env())

    :ok
  end

  @query """
  {
    menuItems {
      name
    }
  }
  """

  test "menuItems returns a list of menu items", %{conn: conn} do
    conn = post(conn, "/api", %{query: @query})

    assert json_response(conn, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "French Fries"},
                 %{"name" => "Lemonade"},
                 %{"name" => "Papadum"},
                 %{"name" => "Pasta Salad"},
                 %{"name" => "Reuben"},
                 %{"name" => "Soft Drink"},
                 %{"name" => "Vada Pav"},
                 %{"name" => "Water"}
               ]
             }
           }
  end

  @query """
  {
    menuItems(order: DESC) {
      name
    }
  }
  """

  test "menuItems returns a list of menu items on desc order", %{conn: conn} do
    conn = post(conn, "/api", %{query: @query})

    assert %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Water"}
                 | _
               ]
             }
           } = json_response(conn, 200)
  end

  @query """
  {
    menuItems(filter: {name: "reu"}) {
      name
    }
  }
  """

  test "menuItems(matching: name) returns menu items filtered by name", %{conn: conn} do
    response = post(conn, "/api", %{query: @query})

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
    query($name: String) {
      menuItems(filter: {name: $name}) {
        name
      }
    }
  """

  @variables %{"name" => "reu"}
  test "menuItems(matching: $term) returns menu items filtered by name by variable", %{conn: conn} do
    response = post(conn, "/api", %{query: @query, variables: @variables})

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
    query($order: SortOrder!) {
      menuItems(order: $order) {
        name
      }
    }
  """

  @variables %{"order" => "DESC"}
  test "menuItems(matching: $term) returns menu items descending using variables", %{conn: conn} do
    response = post(conn, "/api", %{query: @query, variables: @variables})

    assert %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Water"} | _
               ]
             }
           } = json_response(response, 200)
  end

  @query """
  {
    menuItems(filter: {name: 123}) {
      name
    }
  }
  """

  test "menuItems(matching: bad value) returns an error", %{conn: conn} do
    response = post(conn, "/api", %{query: @query})

    assert %{
             "errors" => [
               %{
                 "message" => message
               }
             ]
           } = json_response(response, 200)

    assert message ==
             "Argument \"filter\" has invalid value {name: 123}.\nIn field \"name\": Expected type \"String\", found 123."
  end

  @query """
    {
      menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}) {
        name
      }
    }
  """

  test "menuitems(filter: {}) returns menu items, filtering with a literal", %{conn: conn} do
    response = post(conn, "/api", %{query: @query})

    assert json_response(response, 200) == %{
             "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
           }
  end

  @query """
  query($filter: MenuItemFilter!) {
    menuItems(filter : $filter) {
      name
      added_on
    }
  }
  """

  @variables %{filter: %{"addedBefore" => "2021-12-11"}}
  test "menuitems(filter: {addedBefore, Date}) returns menu items, filtered by date custom scalar type",
       %{
         conn: conn
       } do
    sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")

    %PlateSlate.Menu.Item{
      name: "Garlic Fries",
      added_on: ~D[2021-12-11],
      price: 2.50,
      category: sides
    }
    |> PlateSlate.Repo.insert!()

    response = post(conn, "/api", %{query: @query, variables: @variables})

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"added_on" => "2021-12-11", "name" => "Garlic Fries"}
               ]
             }
           }
  end

  @query """
  query($filter: MenuItemFilter!) {
    menuItems(filter : $filter) {
      name
    }
  }
  """

  @variables %{filter: %{"addedBefore" => "not-a-date"}}
  test "menuitems(filter: {addedBefore, InvalidDate}) returns an error, filtered by date custom scalar type",
       %{
         conn: conn
       } do
    response = post(conn, "/api", %{query: @query, variables: @variables})

    assert %{
             "errors" => [
               %{
                 "locations" => [%{"column" => 13, "line" => 2}],
                 "message" => message
               }
             ]
           } = json_response(response, 200)

    assert message ==
             "Argument \"filter\" has invalid value $filter.\nIn field \"addedBefore\": Expected type \"Date\", found \"not-a-date\"."
  end
end
