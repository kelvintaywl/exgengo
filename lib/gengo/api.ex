defmodule Gengo.API.LanguagePair do
  @derive [Poison.Encoder]
  defstruct [:lc_src, :lc_tgt, :tier, :unit_price, :currency]
end

defmodule Gengo.API.Language do
  @derive [Poison.Encoder]
  defstruct [:language, :localized_name, :lc, :unit_type]
end

defmodule Gengo.API.Account do
  @derive [Poison.Encoder]
  defstruct [:full_name, :display_name, :language_code, :email]
end

defmodule Gengo.API.AccountStats do
  @derive [Poison.Encoder]
  defstruct [:user_since, :currency, :credits_spent, :billing_type, :customer_type]
end

defmodule Gengo.API.AccountBalance do
  @derive [Poison.Encoder]
  defstruct [:currency, :credits]
end

defmodule Gengo.API.JobsPost do
  @derive [Poison.Encoder]
  defstruct [:order_id, :job_count, :currency, :credits_used]
end

defmodule Gengo.API.Response do
  @derive [Poison.Encoder]
  defstruct [:opstat, :response, :err]
end

defmodule Gengo.API.Error do
  @derive [Poison.Encoder]
  defstruct [:code, :msg]
end

defmodule Gengo.API do
  @url "https://api.gengo.com/v2"
  @sandbox_url "https://api.sandbox.gengo.com/v2"

  defp auth(pubkey, privkey) do
    ts = DateTime.utc_now() |> DateTime.to_unix
    sig = :crypto.hmac(:sha, privkey, Integer.to_string(ts)) |> Base.encode16 |> String.downcase
    [api_key: pubkey, api_sig: sig, ts: ts]
  end

  defp get(path, pubkey, privkey, params \\ []) do
    auth_params = auth(pubkey, privkey)
    case HTTPoison.get("#{@url}#{path}", [], params: auth_params ++ params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 400}} ->
        throw "Bad Request"
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        throw "Internal Server Error"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  defp post(path, pubkey, privkey, payload \\ %{}) do
    auth_params = auth(pubkey, privkey)
    payload_json = payload |> Poison.encode!
    case HTTPoison.post("#{@url}#{path}", payload_json, [{"Content-type", "application/json"}], params: auth_params) do
      {:ok, %HTTPoison.Response{body: body}} ->
        # note: Gengo may return 200 / 201; perhaps unnecessary to check
        body
      {:ok, %HTTPoison.Response{status_code: 400}} ->
        throw "Bad Request"
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        throw "Internal Server Error"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def language_pairs(pubkey, privkey) do
    data = get("/translate/service/language_pairs", pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: [%Gengo.API.LanguagePair{}]})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def languages(pubkey, privkey \\ "") do
    data = get("/translate/service/languages", pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: [%Gengo.API.Language{}]})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def stats(pubkey, privkey) do
    data = get('/account/stats', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.AccountStats{}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def me(pubkey, privkey) do
    data = get('/account/me', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.Account{}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def balance(pubkey, privkey) do
    data = get('/account/balance', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.AccountBalance{}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def post_jobs(pubkey, privkey, jobs) do
    payload = %{jobs: jobs}
    data = post("/translate/jobs", pubkey, privkey, payload) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.JobsPost{}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end
end
