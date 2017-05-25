defmodule Gengo.Request do
  use HTTPoison.Base

  def auth do
    ts = DateTime.utc_now() |> DateTime.to_unix
    sig = :crypto.hmac(:sha, Gengo.api_secret, Integer.to_string(ts)) |> Base.encode16 |> String.downcase
    [api_key: Gengo.api_key, api_sig: sig, ts: ts]
  end

  def resp(body) do
    case body[:opstat] do
      "error" ->
        body[:err]
      "ok" ->
        body[:response]
    end
  end

  def process_url(url) do
    if String.starts_with?(url, Gengo.endpoint) do
      url
    else
      Gengo.endpoint <> url
    end
  end

  def process_request_headers(headers) do
    [{"Content-type", "application/json"}] ++ headers
  end

  def process_response_body(""), do: ""
  def process_response_body(body) do
    Poison.decode!(body, keys: :atoms)
    |> Gengo.Request.resp
  end

  def getreq(path, params \\ []) do
    {:ok, response} = Gengo.Request.get(path, [], params: Gengo.Request.auth ++ params)
    response.body
  end

  def postreq(path, payload \\ %{}) do
    encoded = Poison.Encoder.encode(payload, [])
    {:ok, response} = Gengo.Request.post(path, encoded, [], params: Gengo.Request.auth)
    response.body
  end

  def putreq(path, payload \\ %{}) do
    encoded = Poison.Encoder.encode(payload, [])
    {:ok, response} = Gengo.Request.put(path, encoded, [], params: Gengo.Request.auth)
    response.body
  end

  def delreq(path) do
    {:ok, response} = Gengo.Request.delete(path, [], params: Gengo.Request.auth)
    response.body
  end
end
