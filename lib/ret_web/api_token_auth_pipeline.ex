defmodule RetWeb.ApiTokenAuthPipeline do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :ret,
    module: Ret.ApiToken,
    error_handler: RetWeb.ApiTokenAuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer", halt: false)
  plug(Guardian.Plug.LoadResource, allow_blank: true, halt: false)
end

defmodule RetWeb.ApiTokenAuthErrorHandler do
  @moduledoc false

  def auth_error(conn, {failure_type, %ArgumentError{message: reason}}, _opts) do
    append_error(conn, failure_type, reason)
  end

  def auth_error(conn, {failure_type, reason}, _opts) do
    append_error(conn, failure_type, reason)
  end

  defp append_error(conn, failure_type, reason) do
    Plug.Conn.assign(
      conn,
      :api_token_auth_errors,
      (conn.assigns[:api_token_auth_errors] || []) ++ [{failure_type, reason}]
    )
  end
end
