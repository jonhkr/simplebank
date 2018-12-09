defmodule SimpleBank.AuthPlug do
  import Plug.Conn

  alias SimpleBank.Auth

  def init(options) do
    options
  end

  def call(conn, _opts) do
    if conn.private[:auth] do
      case check_authorization(conn) do
        {:ok, user} -> assign(conn, :user, user)
        {:error, _} -> 
          conn
          |> send_resp(401, Jason.encode!(%{message: "unauthorized"}))
          |> halt()
      end
    else
      conn
    end
  end

  defp check_authorization(%Plug.Conn{} = conn) do
    conn
    |> get_req_header("authorization")
    |> check_authorization() 
  end
  defp check_authorization([]), do: {:error, :unathorized}
  defp check_authorization([h | _]) do
    if String.starts_with?(h, "Bearer ") do
      String.slice(h, 7..-1)
      |> Auth.validate_and_get_user()
    else
      {:error, :unauthorized}
    end
  end
end