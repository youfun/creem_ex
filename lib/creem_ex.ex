defmodule CreemEx do
  @moduledoc """
  A client library for the Creem payment system.
  """
  import Plug.Crypto, only: [secure_compare: 2]

  @base_url "https://api.creem.io/v1"

  @doc """
  Configures the CreemEx client with API key and default return URL.
  """
  def configure(api_key, return_url) do
    Application.put_env(:creem_ex, :api_key, api_key)
    Application.put_env(:creem_ex, :return_url, return_url)
  end

  @doc """
  Creates a checkout session for a given product.
  """
  def create_checkout_session(product_id, opts \\ []) do
    api_key = get_config(:api_key)
    return_url = Keyword.get(opts, :return_url, get_config(:return_url))

    body = %{
      product_id: product_id,
      success_url: return_url
    }

    Req.post("#{@base_url}/checkouts",
      json: body,
      headers: [{"x-api-key", api_key}]
    )
    |> handle_response()
  end

  @doc """
  Verifies the signature of a redirect URL.
  """
  def verify_signature(params) do
    api_key = get_config(:api_key)
    secret_key = get_config(:secret_key)

    # Generate the string to sign and expected signature
    string_to_sign = generate_string_to_sign(params)
    expected_signature = generate_signature(string_to_sign, secret_key)

    # Get the provided signature from params
    signature = params["signature"]

    # Debug logging
    IO.inspect(secret_key, label: "Secret Key")
    IO.inspect(string_to_sign, label: "String to Sign")
    IO.inspect(expected_signature, label: "Expected Signature")

    # Use secure_compare directly without the Plug.Crypto prefix
    result = secure_compare(expected_signature, signature)

    # ... rest of the function ...
  end

  @doc """
  Handles the redirect after a successful payment.
  """
  def handle_redirect(params) do
    case verify_signature(params) do
      true -> {:ok, extract_payment_info(params)}
      false -> {:error, :invalid_signature}
    end
  end

  # Private functions

  defp get_config(key) do
    Application.get_env(:creem_ex, key) ||
      raise "CreemEx configuration for #{key} is missing"
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

  defp generate_signature(string_to_sign, secret_key) do
    # Implement the signature generation logic here
    # For example:
    :crypto.mac(:hmac, :sha256, secret_key, string_to_sign)
    |> Base.encode16(case: :lower)
  end

  defp generate_string_to_sign(params) do
    # Implement the logic to generate the string to sign
    # This is just an example, adjust according to your needs
    params
    |> Enum.sort()
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join("&")
  end

  defp extract_payment_info(params) do
    %{
      checkout_id: params["checkout_id"],
      order_id: params["order_id"],
      customer_id: params["customer_id"],
      subscription_id: params["subscription_id"],
      product_id: params["product_id"],
      request_id: params["request_id"]
    }
  end
end
