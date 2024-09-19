import Config

config :creem_ex,
  api_key: System.get_env("CREEM_API_KEY"),
  return_url: System.get_env("CREEM_RETURN_URL"),
  secret_key: System.get_env("CREEM_SECRET_KEY")

# 为测试环境配置特定的值
if config_env() == :test do
  config :creem_ex,
    api_key: "creem_test_70Wy8tb1X8F1lrR8uzSnqs",
    return_url: "http://localhost:4000/payment/callback",
    secret_key: "your_test_secret_key"
end
