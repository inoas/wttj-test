defmodule WttjWeb.Plugs.Redirector do
  def init(default) do
    default
  end

  def call(conn, opts) do
    location = opts[:location]
    http_status_code = opts[:http_status_code] || 302

    conn
    |> Plug.Conn.put_resp_header("location", location)
    |> Plug.Conn.resp(http_status_code, "")
    |> Plug.Conn.halt()
  end
end
