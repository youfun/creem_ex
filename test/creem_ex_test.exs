defmodule CreemExTest do
  use ExUnit.Case
  doctest CreemEx

  @test_api_key "creem_test_70Wy8tb1X8F1lrR8uzSnqs"
  @test_product_id "prod_38itZkD0Qieuxfbhr431Vf"
  @test_return_url "https://example.com/return"

  setup do
    CreemEx.configure(@test_api_key, @test_return_url)
    :ok
  end

  test "create_checkout_session" do
    case CreemEx.create_checkout_session(@test_product_id) do
      {:ok, response} ->
        assert is_map(response)
        assert Map.has_key?(response, "checkout_url")
      {:error, reason} ->
        flunk("Failed to create checkout session: #{inspect(reason)}")
    end
  end

  test "verify_signature" do
    # Note: This test will need to be updated with a valid signature from a real response
    params = %{
      "checkout_id" => "ch_123",
      "order_id" => "ord_456",
      "signature" => "44d9ddf05ee70c017c2d1f590efa3f9ceabc93fa3a361c3c56a463be34e2b650"
    }

    assert CreemEx.verify_signature(params)
  end

  test "handle_redirect with valid signature" do
    # Note: This test will need to be updated with a valid signature from a real response
    params = %{
      "checkout_id" => "ch_123",
      "order_id" => "ord_456",
      "signature" => "44d9ddf05ee70c017c2d1f590efa3f9ceabc93fa3a361c3c56a463be34e2b650"
    }

    assert {:ok, _payment_info} = CreemEx.handle_redirect(params)
  end

  test "handle_redirect with invalid signature" do
    params = %{
      "checkout_id" => "ch_123",
      "order_id" => "ord_456",
      "signature" => "invalid_signature"
    }

    assert {:error, :invalid_signature} = CreemEx.handle_redirect(params)
  end
end
