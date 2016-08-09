defmodule Extatic.Reporters.Metrics.DatadogTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  test "When there are no metrics, no request is sent to datadog", %{bypass: bypass} do
    Extatic.Reporters.Metrics.Datadog.send(request_state(bypass))
  end

  test "When there is a metric it is sent to datadog", %{bypass: bypass} do

    Bypass.expect bypass, fn conn ->
          conn = parse_body(conn)

          assert conn.request_path == "/test_endpoint"
          assert conn.method=="POST"

          record =  conn.body_params["series"] |> List.first
          assert record["metric"] == "test_metric"
          assert record["points"] |> List.first |> List.last == "7.54"
          assert record["host"] == "test_hostname"
          assert conn.query_params["api_key"] == "api12345678901234567890"

          Plug.Conn.resp(conn, 200, "")
    end

     request_state(bypass)
     |> add_event
     |> Extatic.Reporters.Metrics.Datadog.send
  end





  defp endpoint_url(port), do: "http://localhost:#{port}/test_endpoint"

  defp request_state(bypass) do
      %{config: config(bypass)}
  end

  defp add_event(state) do
    Map.put(state, :metrics,[%{name: "test_metric", value: "7.54", timestamp: nil}])
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
