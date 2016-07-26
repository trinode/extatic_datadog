defmodule Extatic.Reporters.Events.Datadog do
  @behaviour Extatic.Behaviours.EventReporter
  def send(state) do
    send_requests(state.events)
  end

  def get_config do
    config |> Keyword.get(:event_config)
  end

  def build_url(url, api_key) do
    "#{url}?api_key=#{api_key}"
  end



  def send_requests([current_event | tail]) do
    config = get_config

    url = build_url(config.url,config.api_key)
    body = build_request(current_event, config)
    headers = ["Content-Type": "application/json"]

    HTTPoison.post url, body, headers, options
    send_requests(tail)
  end

  def send_requests([]) do

  end

  def build_request(event, config) do
    now = get_time
    host = config.host
    tags = ""

    data = %{
              "title": event.title,
              "text": event.content,
              "title": event.title,
              "alert_type": event.type,
              "tags": tags
            }

    {:ok, body} = Poison.encode data
    body
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
    Application.fetch_env!(:extatic, :config)
  end
end
