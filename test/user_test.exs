defmodule UserTest do
  use ExUnit.Case

  alias SimpleBank.{Repo, Users, User, Auth}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "create user" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, user} = Users.create_user(name, username, password, email)

    assert user.name == name
    assert user.username == username
    assert User.password_matches(user, password)
    assert user.raw_password == nil
  end

  test "validate user username" do
    name = "Jonas Trevisan"
    password = "jonast"
    email = "jonast@jonast.com"

    {:error, %Ecto.Changeset{valid?: false, errors: errors}} = Users.create_user(name, nil, password, email)

    assert [username: {"can't be blank", [validation: :required]}] = errors

    {:error, %Ecto.Changeset{valid?: false, errors: errors}} = Users.create_user(name, "sh", password, email)

    assert  [
              username: {"should be at least %{count} character(s)",
               [count: 4, validation: :length, kind: :min]}
            ] = errors
  end

  test "validate user password" do
    name = "Jonas Trevisan"
    username = "jonast"
    email = "jonast@jonast.com"

    {:error, %Ecto.Changeset{valid?: false, errors: errors}} = Users.create_user(name, username, nil, email)

    assert [raw_password: {"can't be blank", [validation: :required]}] = errors

    {:error, %Ecto.Changeset{valid?: false, errors: errors}} = Users.create_user(name, username, "411a", email)

    assert  [
              raw_password: {"should be at least %{count} character(s)",
               [count: 6, validation: :length, kind: :min]}
            ] = errors
  end

  test "create session" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, user} = Users.create_user(name, username, password, email)

    {:ok, session} = Users.create_session(username, password)

    assert session.id != nil
    assert session.user_id == user.id
    assert session.revoked_at == nil
  end

  test "revoke session" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, _} = Users.create_user(name, username, password, email)

    {:ok, session} = Users.create_session(username, password)

    Users.revoke_session(session.id)

    revoked = Users.get_session(session.id)

    assert revoked.id == session.id
    assert revoked.revoked_at != nil

    assert !Users.valid_session(session.id)

    Users.revoke_session(session.id)

    revoked2 = Users.get_session(session.id)

    assert revoked.revoked_at == revoked2.revoked_at
  end

  test "generate auth token" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, user} = Users.create_user(name, username, password, email)
    {:ok, token} = Auth.authenticate(username, password)
    {:ok, user2} = Auth.validate_and_get_user(token)

    assert user.id == user2.id
  end

  test "invalid auth token" do
    {:error, error} = Auth.validate_and_get_user("foobar")

    assert error == :invalid_token
  end

  test "revoke token session" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, _} = Users.create_user(name, username, password, email)
    {:ok, token} = Auth.authenticate(username, password)

    Auth.revoke(token)

    {:error, error} = Auth.validate_and_get_user(token)

    assert error == :invalid_token
  end
end
