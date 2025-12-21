defmodule BB.Example.WX200Web.PageController do
  use BB.Example.WX200Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
