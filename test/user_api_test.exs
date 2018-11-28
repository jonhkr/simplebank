defmodule UserApiTest do
  use ExUnit.Case
  use Plug.Test

  alias SimpleBank.{Repo, Router}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  @opts Router.init([])

  test "create user validation" do
    conn =
      conn(:post, "/v1/users", Jason.encode!(%{username: "foo"}))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 400

    %{"details" => details} = Jason.decode!(conn.resp_body)

    assert %{
      "name" => ["can't be blank"],
      "username" => ["should be at least 4 character(s)"],
      "raw_password" => ["can't be blank"]
    } = details
  end

  test "create user" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"

    req_body = %{name: name, username: username, raw_password: password}

    conn =
      conn(:post, "/v1/users", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 200

    assert %{
      "id" => id,
      "username" => ^username,
      "name" => ^name,
      "inserted_at" => inserted_at} = Jason.decode!(conn.resp_body)

    assert id != nil
    assert inserted_at != nil
  end
end
