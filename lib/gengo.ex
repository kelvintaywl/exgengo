defmodule Gengo do

  import Gengo.Request, only: [getreq: 1, getreq: 2, postreq: 2, delreq: 1]

  @endpoint "https://api.gengo.com/v2"
  @api_key_variable "GENGO_API_KEY"
  @api_secret_variable "GENGO_API_SECRET"
  @moduledoc """

  This is an Elixir client for Gengo API, version 2.
  For more information, please see [Gengo's developer documentation]
  (http://developers.gengo.com)

  """

  @doc """
  Return the Gengo API endpoint URL as a string

  ## Examples

      iex> Gengo.endpoint
      "https://api.gengo.com/v2"

  """
  def endpoint, do: @endpoint

  @doc """
  Return your Gengo API key as a string

  Assumes that it is set in the GENGO_API_KEY env var

  ## Examples

      iex> Gengo.api_key
      "HELLOGENGO"

  """
  def api_key, do: System.get_env(@api_key_variable)

  @doc """
  Return your Gengo API secret as a string

  Assumes that it is set in the GENGO_API_SECRET env var

  ## Examples

      iex> Gengo.api_secret
      "TOPSECRET"

  """
  def api_secret, do: System.get_env(@api_secret_variable)

  # Jobs API

  @doc """
  Post [jobs to be translated by Gengo]
  (http://developers.gengo.com/v2/api_methods/jobs/#jobs-post)

  """
  def post_jobs(jobs) do
    postreq("/translate/jobs", %{jobs: jobs})
  end

  @doc """
  Return [specific job by ID]
  (http://developers.gengo.com/v2/api_methods/job/#job-get)

  """
  def job(id) when is_integer(id) do
    getreq("/translate/job/#{id}")
    |> Map.get(:job)
  end

  @doc """
  Return [comments on specific job by job ID]
  (http://developers.gengo.com/v2/api_methods/job/#comments-get)

  """
  def job(id, :comments) when is_integer(id) do
    getreq("/translate/job/#{id}/comments")
    |> Map.get(:thread)
  end

  @doc """
  Return [revision history on specific job by job ID]
  (http://developers.gengo.com/v2/api_methods/job/#revisions-get)

  """
  def job(id, :revisions) when is_integer(id) do
    getreq("/translate/job/#{id}/revisions")
    |> Map.get(:revisions)
  end

  @doc """
  Return [specific revision history on job by revision and job ID]
  (http://developers.gengo.com/v2/api_methods/job/#revision-get)

  """
  def job(id, :revisions, revision_id) when is_integer(id) and is_integer(revision_id) do
    getreq("/translate/job/#{id}/revision/#{revision_id}")
    |> Map.get(:revision)
  end

  @doc """
  Return [feedback on specific job by job ID]
  (http://developers.gengo.com/v2/api_methods/job/#feedback-get)

  """
  def job(id, :feedback) when is_integer(id) do
    getreq("/translate/job/#{id}/feedback")
    |> Map.get(:feedback)
  end

  @doc """
  Update [specific job by job ID]
  (http://developers.gengo.com/v2/api_methods/job/#job-delete)

  """
  def update_job(id, action, payload) when is_integer(id) do
    putreq("/translate/job/#{id}", Map.put(payload, :action, action))
  end

  @doc """
  Delete [specific job by job ID]
  (http://developers.gengo.com/v2/api_methods/job/#job-delete)

  """
  def delete_job(id) when is_integer(id), do: delreq("/translate/job/#{id}")

  @doc """
  Retrieve [list of ordered job by specific status]
  (http://developers.gengo.com/v2/api_methods/jobs/#jobs-get)

  """
  def jobs_by_status(status \\ "reviewable", count \\ 10) do
    getreq("/translate/jobs", [status: status, count: count])
  end

  @doc """
  Retrieve [list of ordered job by IDs]
  (http://developers.gengo.com/v2/api_methods/jobs/#jobs-by-id-get)

  """
  def jobs_by_ids(ids) when is_list(ids) do
    joined = Enum.join(ids, ",")
    getreq("/translate/jobs/#{joined}")
  end

  @doc """
  Update [jobs by job ID]
  (http://developers.gengo.com/v2/api_methods/jobs/#jobs-put)

  Please note, via the Gengo API documentation, what payload should be sent.

  """
  def update_jobs(action, payloads_or_ids) when is_binary(action) and is_list(payloads_or_ids) do
    putreq("/translate/jobs", %{job_ids: payloads_or_ids, action: action})
  end

  @doc """
  Post a [comment on specific job]
  (http://developers.gengo.com/v2/api_methods/job/#comment-post)

  """
  def post_job_comment(id, comment) when is_integer(id) do
    postreq("/translate/job/#{id}/comment", %{body: comment})
  end

  # Orders API

  @doc """
  Return [specific order by ID]
  (http://developers.gengo.com/v2/api_methods/order/#order-get)

  """
  def order(id) when is_integer(id) do
    getreq("/translate/order/#{id}")
    |> Map.get(:order)
  end

  @doc """
  Return [comments on specific order by ID]
  (http://developers.gengo.com/v2/api_methods/order/#comments-get)

  """
  def order(id, :comments) when is_integer(id) do
    getreq("/translate/order/#{id}/comments")
    |> Map.get(:thread)
  end

  @doc """
  Delete [specific job by ID]
  (http://developers.gengo.com/v2/api_methods/order/#order-delete)

  """
  def delete_order(id) when is_integer(id), do: delreq("/translate/order/#{id}")

  @doc """
  Post a [comment on specific order]
  (http://developers.gengo.com/v2/api_methods/order/#comment-post)

  """
  def post_order_comment(id, comment) when is_integer(id) do
    postreq("/translate/order/#{id}/comment", %{body: comment})
  end

  # Account API

  @doc """
  Return details on your [Gengo account statistics]
  (http://developers.gengo.com/v2/api_methods/account/#stats-get)

  """
  def stats, do: getreq("/account/stats")

  @doc """
  Return basic details of your [Gengo account]
  (http://developers.gengo.com/v2/api_methods/account/#me-get)

  """
  def me, do: getreq("/account/me")

  @doc """
  Return details of your [Gengo account balance]
  (http://developers.gengo.com/v2/api_methods/account/#balance-get)

  """
  def balance, do: getreq("/account/balance")

  @doc """
  Return details of your [prefered Gengo translators]
  (http://developers.gengo.com/v2/api_methods/account/#preferred-translators-get)

  """
  def preferred_translators, do: getreq("/account/preferred_translators")

  # Service API

  @doc """
  Return list of supported [languages in Gengo]
  (http://developers.gengo.com/v2/api_methods/service/#languages-get)

  """
  def languages, do: getreq("/translate/service/languages")

  @doc """
  Return list of available [language pairs for ordering with Gengo]
  (http://developers.gengo.com/v2/api_methods/service/#language-pairs-get)

  """
  def language_pairs, do: getreq("/translate/service/language_pairs")

  @doc """
  Get a quote on [list of jobs for translation]
  (http://developers.gengo.com/v2/api_methods/service/#quote-post)

  """
  def quote(jobs) do
    postreq("/translate/service/quote", %{jobs: jobs})
    |> Map.get(:jobs)
  end

  def quote_files(files) do
    "TODO"
  end

  # Glossary API

  @doc """
  Return [list of glossaries you uploaded with Gengo]
  (http://developers.gengo.com/v2/api_methods/glossary/#glossaries-get)

  """
  def glossaries, do: getreq("/translate/glossary")

  @doc """
  Return [specific glossary by ID]
  (http://developers.gengo.com/v2/api_methods/glossary/#glossary-get)

  """
  def glossary(id) when is_integer(id), do: getreq("/translate/glossary/#{id}")

end
