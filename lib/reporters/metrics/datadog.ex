defmodule Extatic.Reporters.Metrics.Datadog do
  @behaviour Extatic.Behaviours.MetricReporter
  def send(stat_list) do
    send_request(stat_list)
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
    IO.inspect HTTPoison.post(url, body, headers, options)
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

  defp options() do
    options(proxy_config)
  end


  defp options(config = %{username: username, password: password, host: host, port: port}) do
    [
      proxy: "http://#{host}:#{port}",
      proxy_auth: {
        username,
        password
      }
    ]
  end

  defp options(config = %{host: host, port: port}) do
    [
      proxy: "http://#{host}:#{port}"
    ]
  end

  defp options(_) do
    []
  end

  defp proxy_config do
    proxy_config = Keyword.fetch(config, :proxy)
    case proxy_config do
       {:ok, config} -> config
       _ -> %{}
    end
  end

  defp config do
    Application.get_env(:extatic, :config)
  end
end
