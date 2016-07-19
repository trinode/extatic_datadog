defmodule Extatic.Reporters.Metrics.Datadog do
  @behaviour Extatic.Behaviours.MetricReporter
  def send(stat_list) do
    IO.puts "-------------------------"
    IO.puts "DATADOG SENDER:"
    IO.puts "configuration:"
    IO.inspect get_config
    IO.puts "input_stats:"
    IO.inspect send_request(stat_list)
    IO.puts "-------------------------"
  end

  def get_config do
    config |> Keyword.get(:metric_config)
  end

  def build_url(url, api_key) do
    "#{url}?api_key=#{api_key}"
  end



  def send_request(stats) do
    config = get_config

    url = build_url(config.url,config.api_key)
    body = build_request(stats, config)
    headers = ["Content-Type": "application/json"]
    HTTPoison.post url, body, headers, options
  end

  def build_request(stats, config) do
    now = get_time
    host = config.host
    tags = ""
    list = stats |> Enum.map(fn (s) ->
      %{
        "metric": s.name,
        "points": [
          [now, s.value]
        ],
        "host": host,
        "tags": tags

      }
    end)

    data = %{"series": list}
    IO.inspect data
    {:ok, body} = Poison.encode data
    body
  end

  def get_body(stats) do

    {:ok, json} = Poison.encode(stats)
    json
  end



  def get_time do
    DateTime.utc_now |> DateTime.to_unix
  end

  defp options do
    [
      proxy: "http://#{System.get_env("WEB_PROXY_HOST")}:#{System.get_env("WEB_PROXY_PORT")}",
      proxy_auth: {System.get_env("WEB_PROXY_USER"), System.get_env("WEB_PROXY_PASS")}
    ]
  end

  defp config do
    Application.get_env(:extatic, :config)
  end
end
