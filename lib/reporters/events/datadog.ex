defmodule Extatic.Reporters.Events.Datadog do
  @behaviour Extatic.Behaviours.EventReporter
  def send(state) do
    IO.puts "-------------------------"
    IO.puts "DATADOG EVENT SENDER:"
    IO.puts "configuration:"
    IO.inspect get_config

    IO.puts "input"
    IO.inspect state.events

    send_requests(state.events)
    IO.puts "-------------------------"
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
    IO.puts "url"
    IO.inspect url
    IO.puts "body"
    IO.inspect body
    IO.puts "headers"
    IO.inspect headers
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
