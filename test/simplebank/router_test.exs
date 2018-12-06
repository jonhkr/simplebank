defmodule SimpleBank.RouterTest do
  use SimpleBank.TestCase

  @opts Router.init([])

  test "_health test" do
    conn =
      conn(:get, "/_health")
      |> Router.call(@opts)

    assert conn.status == 200
    assert %{"status" => "ok"} = Jason.decode!(conn.resp_body)
  end
  
  test "not found" do
    conn =
      conn(:get, "/foo_bar_not_found")
      |> Router.call(@opts)

    assert conn.status == 404
    assert %{"message" => "not found"} = Jason.decode!(conn.resp_body)
  end

end