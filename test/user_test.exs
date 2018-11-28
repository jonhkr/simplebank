defmodule UserTest do
  use ExUnit.Case

  alias SimpleBank.{Repo, Users, User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "create user" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"

    {:ok, user} = Users.create_user(name, username, password)

    assert user.name == name
    assert user.username == username
    assert User.password_matches(user, password)
    assert user.raw_password == nil
  end

  test "validate user username" do
    name = "Jonas Trevisan"
    password = "jonast"

    {:error, %Ecto.Changeset{valid?: false, errors: errors}} = Users.create_user(name, nil, password)

    assert [username: {"can't be blank", [validation: :required]}] = errors

    {:error, %Ecto.Changeset{valid?: false, errors: errors}} = Users.create_user(name, "sh", password)

    assert  [
              username: {"should be at least %{count} character(s)",
               [count: 4, validation: :length, kind: :min]}
            ] = errors
  end

  test "validate user password" do
    name = "Jonas Trevisan"
    username = "jonast"

    {:error, %Ecto.Changeset{valid?: false, errors: errors}} = Users.create_user(name, username, nil)

    assert [raw_password: {"can't be blank", [validation: :required]}] = errors

    {:error, %Ecto.Changeset{valid?: false, errors: errors}} = Users.create_user(name, username, "411a")

    assert  [
              raw_password: {"should be at least %{count} character(s)",
               [count: 6, validation: :length, kind: :min]}
            ] = errors
  end

  test "create session" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"

    {:ok, user} = Users.create_user(name, username, password)

    {:ok, session} = Users.create_session(username, password)

    assert session.id != nil
    assert session.user_id == user.id
    assert session.revoked_at == nil
  end

  test "revoke session" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"

    {:ok, user} = Users.create_user(name, username, password)

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
end
