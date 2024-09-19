defmodule CreemEx do
  @moduledoc """
  A client library for the Creem payment system.
  """

  @doc """
  Configures the CreemEx client with API key and default return URL.
  """
  def configure(api_key, return_url) do
    Application.put_env(:creem_ex, :api_key, api_key)
    Application.put_env(:creem_ex, :return_url, return_url)
  end

  def get_config(key) do
    Application.get_env(:creem_ex, key) ||
      raise "Creem #{key} is not set. Please ensure it's configured in your config files."
  end


  defp get_base_url do
    case Mix.env() do
      :prod -> "https://api.creem.io/v1"
      _ -> "https://test-api.creem.io/v1"
    end
  end

  @doc """
  Creates a checkout session for a given product.
  """
    def create_checkout_session(product_id, opts \\ []) do
      api_key = get_config(:api_key)
      default_return_url = Application.get_env(:creem_ex, :return_url)
      return_url = Keyword.get(opts, :return_url) || default_return_url ||
        raise "Return URL is not set. Please provide it in the options or configure it in your config files."

      body = %{
        product_id: product_id,
        return_url: return_url
      }
      |> maybe_add_request_id(Keyword.get(opts, :request_id))

      Req.post("#{get_base_url()}/checkouts",
        json: body,
        headers: [{"x-api-key", api_key}]
      )
      |> handle_response()
    end


  defp maybe_add_request_id(body, nil), do: body
  defp maybe_add_request_id(body, request_id), do: Map.put(body, :request_id, request_id)

  @doc """
  Verify the signature of the return URL parameters.
  """
  def verify_signature(params, provided_signature) when is_binary(provided_signature) do
    secret_key = get_config(:secret_key)
    calculated_signature = generate_signature(params, secret_key)
    Plug.Crypto.secure_compare(calculated_signature, provided_signature)
  end
  def verify_signature(_, _), do: false

  defp generate_signature(params, secret_key) do
    params
    |> Enum.sort()
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Kernel.++(["salt=#{secret_key}"])
    |> Enum.join("|")
    |> sha256()
  end

  def parse_return_params(query_string) do
    params = URI.decode_query(query_string)
    signature = params["signature"]

    case verify_signature(Map.delete(params, "signature"), signature) do
      true -> {:ok, params}
      false -> {:error, :invalid_signature}
    end
  end



  defp sha256(data) do
    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end

  defp handle_response({:ok, %{status: status, body: body}}) when status in 200..299 do
    case body do
      %{"checkout_url" => checkout_url} ->
        {:ok, body}
      _ ->
        {:error, "Unexpected response format: #{inspect(body)}"}
    end
  end

  defp handle_response({:ok, %{status: status, body: body}}) do
    {:error, {status, body}}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
