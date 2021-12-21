defmodule PlateSlateWeb.Schema.Query.ItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Dev.Seeds.run(Mix.env())

    :ok
  end

  @query """
  {
    items {
      name
    }
  }
  """

  test "items returns a list of menu items", %{conn: conn} do
    conn = post(conn, "/api", %{query: @query})

    assert json_response(conn, 200) == %{
             "data" => %{
               "items" => [
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
    items(order: DESC) {
      name
    }
  }
  """

  test "items returns a list of menu items on desc order", %{conn: conn} do
    conn = post(conn, "/api", %{query: @query})

    assert %{
             "data" => %{
               "items" => [
                 %{"name" => "Water"}
                 | _
               ]
             }
           } = json_response(conn, 200)
  end

  @query """
  {
    items(filter: {name: "reu"}) {
      name
    }
  }
  """

  test "items(matching: name) returns menu items filtered by name", %{conn: conn} do
    response = post(conn, "/api", %{query: @query})

    assert json_response(response, 200) == %{
             "data" => %{
               "items" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
    query($name: String) {
      items(filter: {name: $name}) {
        name
      }
    }
  """

  @variables %{"name" => "reu"}
  test "items(matching: $term) returns menu items filtered by name by variable", %{conn: conn} do
    response = post(conn, "/api", %{query: @query, variables: @variables})

    assert json_response(response, 200) == %{
             "data" => %{
               "items" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
    query($order: SortOrder!) {
      items(order: $order) {
        name
      }
    }
  """

  @variables %{"order" => "DESC"}
  test "items(matching: $term) returns menu items descending using variables", %{conn: conn} do
    response = post(conn, "/api", %{query: @query, variables: @variables})

    assert %{
             "data" => %{
               "items" => [
                 %{"name" => "Water"} | _
               ]
             }
           } = json_response(response, 200)
  end

  @query """
  {
    items(filter: {name: 123}) {
      name
    }
  }
  """

  test "items(matching: bad value) returns an error", %{conn: conn} do
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
      items(filter: {category: "Sandwiches", tag: "Vegetarian"}) {
        name
      }
    }
  """

  test "items(filter: {}) returns menu items, filtering with a literal", %{conn: conn} do
    response = post(conn, "/api", %{query: @query})

    assert json_response(response, 200) == %{
             "data" => %{"items" => [%{"name" => "Vada Pav"}]}
           }
  end

  @query """
  query($filter: MenuItemFilter!) {
    items(filter : $filter) {
      name
      added_on
    }
  }
  """

  @variables %{filter: %{"addedBefore" => "2021-12-11"}}
  test "items(filter: {addedBefore, Date}) returns menu items, filtered by date custom scalar type",
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
               "items" => [
                 %{"added_on" => "2021-12-11", "name" => "Garlic Fries"}
               ]
             }
           }
  end

  @query """
  query($filter: MenuItemFilter!) {
    items(filter : $filter) {
      name
    }
  }
  """

  @variables %{filter: %{"addedBefore" => "not-a-date"}}
  test "items(filter: {addedBefore, InvalidDate}) returns an error, filtered by date custom scalar type",
       %{
         conn: conn
       } do
    response = post(conn, "/api", %{query: @query, variables: @variables})

    assert %{
             "errors" => [
               %{
                 "locations" => [%{"column" => 9, "line" => 2}],
                 "message" => message
               }
             ]
           } = json_response(response, 200)

    assert message ==
             "Argument \"filter\" has invalid value $filter.\nIn field \"addedBefore\": Expected type \"Date\", found \"not-a-date\"."
  end

  @query """

  """
end
