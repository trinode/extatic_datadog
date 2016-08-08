defmodule Extatic.Reporters.Availability.DatadogTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  test "Availability is sent to datadog", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
          conn = parse_body(conn)

          assert conn.request_path == "/test_endpoint"
          assert conn.method=="POST"
          assert conn.body_params["check"] == "app.is_ok"
          assert conn.params["api_key"] == "api12345678901234567890"
          assert conn.body_params["host_name"] == "test_hostname"

          Plug.Conn.resp(conn, 200, "")
    end

    Extatic.Reporters.Availability.Datadog.send(request_state(bypass))
  end


  defp endpoint_url(port), do: "http://localhost:#{port}/test_endpoint"

  defp request_state(bypass) do
      %{config: config(bypass)}
  end

  defp parse_body(conn) do
     Plug.Parsers.call(conn, parsers: [Plug.Parsers.JSON], pass: ["*/*"], json_decoder: Poison)
  end

  defp config(bypass) do
    %{
      url: endpoint_url(bypass.port),
      api_key: "api12345678901234567890",
      host: "test_hostname"
    }
  end
end
