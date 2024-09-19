defmodule CreemExTest do
  use ExUnit.Case
  doctest CreemEx

  @test_api_key "creem_test_sdfsdf8uzSnqs"
  @test_product_id "prod_38sssasdfbhr431Vf"
  @test_return_url "https://example.com/return"

  setup do
    CreemEx.configure(@test_api_key, @test_return_url)
    :ok
  end

  test "verify_signature with valid signature" do
    # 生成一个测试参数
    params = %{
      "checkout_id" => "ch_123",
      "order_id" => "ord_456",
      "product_id" => @test_product_id,
      "request_id" => "req_789"
    }

    # 生成签名
    signature = CreemEx.generate_signature(CreemEx.generate_string_to_sign(params), @test_api_key)

    # 将签名添加到参数中
    params = Map.put(params, "signature", signature)

    # 验证签名
    assert CreemEx.verify_signature(params)
  end

  # ... 其他测试用例 ...
end
