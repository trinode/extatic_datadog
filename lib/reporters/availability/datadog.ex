defmodule Extatic.Reporters.Availability.Datadog do
  @behaviour Extatic.Behaviours.AvailabilityReporter
  def send do
    send_request
  end

  def get_config do
    config |> Keyword.get(:availability_config)
  end

  def build_url(url, api_key) do
    "#{url}?api_key=#{api_key}"
  end


  def send_request() do
    config = get_config

    url = build_url(config.url,config.api_key)
    body = build_request(config)
    headers = ["Content-Type": "application/json"]

    HTTPoison.post url, body, headers, options
  end

  def build_request(config) do
    now = get_time
    host = config.host
    tags = ""

    data = %{
              "check": "app.is_ok",
              "host_name": host,
              "timestamp": get_time,
              "status": 0
            }

    {:ok, body} = Poison.encode data
    body
  end

  def get_time do
    DateTime.utc_now |> DateTime.to_unix
  end

  defp options do
    [
      proxy: "http://#{Keyword.fetch!(proxy_config, :host)}:#{Keyword.fetch!(proxy_config, :port)}",
      proxy_auth: {
        Keyword.fetch!(proxy_config, :username),
        Keyword.fetch!(proxy_config, :password)
      }
    ]
  end

  defp proxy_config do
    Keyword.fetch!(config, :proxy)
  end

  defp config do
    Application.fetch_env!(:extatic, :config)
  end
end
