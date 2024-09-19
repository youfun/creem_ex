defmodule CreemEx do
  @moduledoc """
  A client library for the Creem payment system.
  """
  import Plug.Crypto

  @doc """
  Configures the CreemEx client with API key, default return URL, and environment.
  """
  def configure(api_key, return_url, env \\ :test) do
    Application.put_env(:creem_ex, :api_key, api_key)
    Application.put_env(:creem_ex, :return_url, return_url)
    Application.put_env(:creem_ex, :environment, env)
  end

  defp get_config(key) do
    Application.get_env(:creem_ex, key) ||
      raise "CreemEx configuration for #{key} is missing"
  end

  defp get_base_url do
    case get_config(:environment) do
      :prod -> "https://api.creem.io/v1"
      _ -> "https://test-api.creem.io/v1"
    end
  end

  @doc """
  Creates a checkout session for a given product.
  """
  @doc """
  Creates a checkout session for a given product.
  """
  def create_checkout_session(product_id, opts \\ []) do
    api_key = get_config(:api_key)
    default_return_url = get_config(:return_url)
    success_url = Keyword.get(opts, :success_url, default_return_url)
    request_id = Keyword.get(opts, :request_id)

    body = %{
      product_id: product_id,
      success_url: success_url
    }
    |> maybe_add_request_id(request_id)

    Req.post("#{get_base_url()}/checkouts",
      json: body,
      headers: [{"x-api-key", api_key}]
    )
    |> handle_response()
  end

  defp maybe_add_request_id(body, nil), do: body
  defp maybe_add_request_id(body, request_id), do: Map.put(body, :request_id, request_id)

  @doc """
  Parse and verify the return URL parameters.
  """
  def parse_return_params(query_string) do
    params = URI.decode_query(query_string)
    signature = params["signature"]

    parsed_params = %{
      checkout_id: params["checkout_id"],
      order_id: params["order_id"],
      customer_id: params["customer_id"],
      subscription_id: params["subscription_id"],
      product_id: params["product_id"],
      request_id: params["request_id"]
    }

    if verify_signature(parsed_params, signature) do
      {:ok, parsed_params}
    else
      {:error, :invalid_signature}
    end
  end

  @doc """
  Verify the signature of the return URL parameters.
  """
  def verify_signature(params, provided_signature) do
    api_key = get_config(:api_key)
    calculated_signature = generate_signature(params, api_key)
    Plug.Crypto.secure_compare(calculated_signature, provided_signature)
  end

  defp generate_signature(params, api_key) do
    params
    |> Enum.sort()
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Kernel.++(["salt=#{api_key}"])
    |> Enum.join("|")
    |> sha256()
  end

  defp sha256(data) do
    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end


  defp handle_response({:ok, %{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response({:ok, %{status: status, body: body}}) do
    {:error, {status, body}}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end


end
