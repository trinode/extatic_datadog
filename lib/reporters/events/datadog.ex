defmodule Extatic.Reporters.Events.Datadog do
  @behaviour Extatic.Behaviours.EventReporter
  def send(state) do
    send_requests(state.events)
  end

  def get_config do
    Application.get_env(:extatic, :config) |> Keyword.get(:event_config)
  end

  def build_url(url, api_key) do
    "#{url}?api_key=#{api_key}"
  end

  def send_requests([current_event | tail]) do
    config = get_config

    url = build_url(config.url,config.api_key)
    body = build_request(current_event, config)
    headers = ["Content-Type": "application/json"]

    HTTPoison.post url, body, headers

    send_requests(tail)
  end

  def send_requests([]), do: nil

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
end
