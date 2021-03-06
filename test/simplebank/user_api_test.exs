defmodule SimpleBank.UserApiTest do
  use SimpleBank.TestCase

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
    email = "jonast@jonast.com"

    req_body = %{name: name, username: username, raw_password: password, email: email}

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

  test "create user session" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, user} = Users.create_user(name, username, password, email)

    req_body = %{username: username, raw_password: password}

    conn =
      conn(:post, "/v1/sessions", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 200

    assert %{"session_token" => token} = Jason.decode!(conn.resp_body)

    {:ok, session_user} = Auth.validate_and_get_user(token)

    assert user.id == session_user.id
  end

  test "authentication error" do
    username = "jonast"
    password = "jonast"

    req_body = %{username: username, raw_password: password}

    conn =
      conn(:post, "/v1/sessions", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 401

    assert %{"message" => "invalid credentials"} = Jason.decode!(conn.resp_body)
  end

  test "authentication with empty username" do
    req_body = %{username: nil}

    conn =
      conn(:post, "/v1/sessions", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 401

    assert %{"message" => "invalid credentials"} = Jason.decode!(conn.resp_body)
  end

  test "authentication with empty password" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, _user} = Users.create_user(name, username, password, email)

    req_body = %{username: username, raw_password: nil}

    conn =
      conn(:post, "/v1/sessions", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 401

    assert %{"message" => "invalid credentials"} = Jason.decode!(conn.resp_body)
  end
end
