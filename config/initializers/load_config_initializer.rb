oidc_provider_config = File.read Rails.root.join 'config/oidc_provider.yml'
OIDC_PROVIDER_CONFIG = YAML.load(oidc_provider_config)[Rails.env]
