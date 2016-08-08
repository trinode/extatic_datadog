defmodule Extatic.Reporters.Events.DatadogTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  test "When there are no events, no request is sent to datadog", %{bypass: bypass} do
    Extatic.Reporters.Events.Datadog.send(request_state(bypass))
  end

  test "When there is an event it is sent to datadog", %{bypass: bypass} do

    Bypass.expect bypass, fn conn ->
          conn = parse_body(conn)

          assert conn.request_path == "/test_endpoint"
          assert conn.method=="POST"

          assert conn.body_params["alert_type"] == "error"
          assert conn.body_params["text"] == "sample_event_content"
          assert conn.body_params["title"] == "sample_event"
          assert conn.body_params["host"] == "test_hostname"
          assert conn.query_params["api_key"] == "api12345678901234567890"

          IO.inspect conn
          Plug.Conn.resp(conn, 200, "")
    end

     request_state(bypass)
     |> add_event
     |> Extatic.Reporters.Events.Datadog.send
  end





  defp endpoint_url(port), do: "http://localhost:#{port}/test_endpoint"

  defp request_state(bypass) do
      %{config: config(bypass)}
  end

  defp add_event(state) do
    Map.put(state, :events,[%{type: :error, title: "sample_event", content: "sample_event_content"}])
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
