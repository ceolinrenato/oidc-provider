sign_in_config = File.read Rails.root.join "config/sign_in_service.yml"
SIGN_IN_SERVICE_CONFIG = YAML.load(sign_in_config)[Rails.env]
