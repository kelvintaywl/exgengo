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

defmodule Gengo.API.PreferredTranslatorsByLanguagePair do
  @derive [Poison.Encoder]
  defstruct [:translators, :lc_src, :lc_tgt, :tier]
end

defmodule Gengo.API.PreferredTranslator do
  @derive [Poison.Encoder]
  defstruct [:id, :last_login]
end

defmodule Gengo.API.Glossary do
  @derive [Poison.Encoder]
  defstruct [:id, :title, :customer_user_id, :source_language_id, :source_language_code, :target_languages, :is_public, :unit_count, :description, :ctime]
end

defmodule Gengo.API.AccountBalance do
  @derive [Poison.Encoder]
  defstruct [:currency, :credits]
end

defmodule Gengo.API.JobItem do
  @derive [Poison.Encoder]
  defstruct [:job_id, :order_id, :slug, :body_src, :body_tgt, :eta, :callback_url, :status, :auto_approve, :lc_src, :lc_tgt, :tier, :currency, :credits, :unit_count, :ctime]
end

defmodule Gengo.API.Job do
  @derive [Poison.Encoder]
  defstruct [:job]
end

defmodule Gengo.API.JobFeedback do
  @derive [Poison.Encoder]
  defstruct [:feedback]
end

defmodule Gengo.API.Feedback do
  @derive [Poison.Encoder]
  defstruct [:for_translator, :rating]
end

defmodule Gengo.API.JobRevisions do
  @derive [Poison.Encoder]
  defstruct [:job_id, :revisions]
end

defmodule Gengo.API.JobRevision do
  @derive [Poison.Encoder]
  defstruct [:rev_id, :ctime, :revision]
end

defmodule Gengo.API.Revision do
  @derive [Poison.Encoder]
  defstruct [:body_tgt, :ctime]
end

defmodule Gengo.API.JobsPost do
  @derive [Poison.Encoder]
  defstruct [:order_id, :job_count, :currency, :credits_used]
end

defmodule Gengo.API.OrderItem do
  @derive [Poison.Encoder]
  defstruct [:order_id, :total_credits, :currency, :total_units, :total_jobs, :jobs_queued, :jobs_available, :jobs_pending, :jobs_revising, :jobs_reviewable, :jobs_approved]
end

defmodule Gengo.API.Order do
  @derive [Poison.Encoder]
  defstruct [:order]
end

defmodule Gengo.API.Comment do
  @derive [Poison.Encoder]
  defstruct [:body, :author, :ctime]
end

defmodule Gengo.API.Comments do
  @derive [Poison.Encoder]
  defstruct [:thread]
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
      {:ok, %HTTPoison.Response{status_code: 404}} ->
          throw "Not Found"
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

  # Services API

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

  # Account API

  def stats(pubkey, privkey) do
    data = get("/account/stats", pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.AccountStats{}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def me(pubkey, privkey) do
    data = get("/account/me", pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.Account{}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def balance(pubkey, privkey) do
    data = get("/account/balance", pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.AccountBalance{}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def preferred_translators(pubkey, privkey) do
    resp_struct = [%Gengo.API.PreferredTranslatorsByLanguagePair{translators: [%Gengo.API.PreferredTranslator{}]}]
    data = get("/account/preferred_translators", pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: resp_struct})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  # Glossary API

  def glossaries(pubkey, privkey) do
    data = get("/translate/glossary", pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: [%Gengo.API.Glossary{}]})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def glossary(pubkey, privkey, id) when is_integer(id) do
    data = get("/translate/glossary/#{id}", pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.Glossary{}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  # Job API

  def job(pubkey, privkey, id) when is_integer(id) do
    data = get('/translate/job/#{id}', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.Job{job: %Gengo.API.JobItem{}}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response.job
    end
  end

  def job_comments(pubkey, privkey, id) when is_integer(id) do
    data = get('/translate/job/#{id}/comments', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.Comments{thread: [%Gengo.API.Comment{}]}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response.thread
    end
  end

  def job_feedback(pubkey, privkey, id) when is_integer(id) do
    data = get('/translate/job/#{id}/feedback', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.JobFeedback{feedback: %Gengo.API.Feedback{}}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response.feedback
    end
  end

  def job_revisions(pubkey, privkey, id) when is_integer(id) do
    data = get('/translate/job/#{id}/revisions', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.JobRevisions{revisions: [%Gengo.API.JobRevision{}]}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response.revisions
    end
  end

  def job_revision(pubkey, privkey, job_id, revision_id) when is_integer(job_id) and is_integer(revision_id) do
    data = get('/translate/job/#{job_id}/revision/#{revision_id}', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.JobRevision{revision: %Gengo.API.Revision{}}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response.revisions
    end
  end

  def job_feedback(pubkey, privkey, id) when is_integer(id) do
    data = get('/translate/job/#{id}/feedback', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.JobFeedback{feedback: %Gengo.API.Feedback{}}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response.feedback
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

  def jobs(pubkey, privkey, status \\ "reviewable", count \\ 10) do
    data = get("/translate/jobs", pubkey, privkey, [status: status, count: count]) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: [%Gengo.API.JobItem{}]})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  def jobs_by_ids(pubkey, privkey, ids) when is_list(ids) do
    ids_joined = ids |> Enum.join(",")
    data = get("/translate/jobs/#{ids_joined}", pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: [%Gengo.API.JobItem{}]})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response
    end
  end

  # Order API

  def order(pubkey, privkey, id) when is_integer(id) do
    data = get('/translate/order/#{id}', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.Order{order: %Gengo.API.OrderItem{}}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response.order
    end
  end

  def order_comments(pubkey, privkey, id) when is_integer(id) do
    data = get('/translate/order/#{id}/comments', pubkey, privkey) |> Poison.decode!(as: %Gengo.API.Response{err: %Gengo.API.Error{}, response: %Gengo.API.Comments{thread: [%Gengo.API.Comment{}]}})
    case data.opstat do
      "error" ->
        data.err
      "ok" ->
        data.response.thread
    end
  end

end
