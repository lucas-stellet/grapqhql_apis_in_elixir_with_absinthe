defmodule PlateSlateWeb.Schema.CustomScalar.Decimal do
  use Absinthe.Schema.Notation

  scalar :decimal do
    parse(fn
      %{value: value}, _ ->
        {decimal_value, _} = Decimal.parse(value)
        {:ok, decimal_value}

      _, _ ->
        :error
    end)

    serialize(&Decimal.to_string/1)
  end
end
