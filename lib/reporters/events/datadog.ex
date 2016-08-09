defmodule Extatic.Reporters.Events.Datadog do
  @behaviour Extatic.Behaviours.EventReporter

  def send(state = %{config: config, events: events}) when length(events) > 0 do
    send_requests(state.events, state)
  end

  def send(_), do: nil

  def build_url(url, api_key) do
    "#{url}?api_key=#{api_key}"
  end

  def send_requests([current_event | tail], state = %{config: config, events: events}) when length(events) > 0 do
    url = build_url(config.url,config.api_key)
    body = build_request(current_event, config)
    headers = ["Content-Type": "application/json"]

    HTTPoison.post url, body, headers, options(state)
    send_requests(tail, state)
  end

  def send_requests([], _state) do

  end

  def build_request(event, config) do
    host = config.host
    tags = ""

    data = %{
              "title": event.title,
              "text": event.content,
              "title": event.title,
              "alert_type": event.type,
              "tags": tags,
              "host": host
            }

    {:ok, body} = Poison.encode data
    body
  end

  def get_time do
    DateTime.utc_now |> DateTime.to_unix
  end


  defp options(config = %{config: %{username: username, password: password, host: host, port: port}}) do

    [
      proxy: "http://#{host}:#{port}",
      proxy_auth: {
        username,
        password
      }
    ]
  end


  defp options(config = %{config: %{host: host, port: port}}) do
    [
      proxy: "http://#{host}:#{port}"
    ]
  end

  defp options(_) do
    []
  end

  defp proxy_config(%{config: config}) do
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
