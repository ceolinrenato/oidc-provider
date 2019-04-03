sign_in_config = File.read Rails.root.join "config/sign_in_service.yml"
oidc_provider_config = File.read Rails.root.join "config/oidc_provider.yml"
SIGN_IN_SERVICE_CONFIG = YAML.load(sign_in_config)[Rails.env]
OIDC_PROVIDER_CONFIG = YAML.load(oidc_provider_config)[Rails.env]
