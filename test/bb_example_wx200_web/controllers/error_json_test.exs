defmodule BB.Example.WX200Web.ErrorJSONTest do
  use BB.Example.WX200Web.ConnCase, async: true

  test "renders 404" do
    assert BB.Example.WX200Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert BB.Example.WX200Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
