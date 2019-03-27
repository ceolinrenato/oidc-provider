module TokenDecode

  RSA_PRIVATE = OpenSSL::PKey::RSA.new Rails.application.credentials.dig(:oidc, :private_key)
  AES_KEY = Base64.decode64(Rails.application.credentials.dig(:oidc, :aes_key))
  AES_IV = Base64.decode64(Rails.application.credentials.dig(:oidc, :aes_iv))

  class IDToken

    def initialize(token)
      @token = token
    end

    def decode
      decode_jwt(@token)
    end

    private

    def decode_jwt(token)
      JWT.decode token, RSA_PRIVATE.public_key, true,
        {
          algorithm: 'RS256',
          exp_leeway: 1.minute,
          iss: OIDC_PROVIDER_CONFIG[:iss],
          verify_iss: true
        }
    end

  end

  class AccessToken < IDToken

    def decode
      decode_jwt(decrypt_token(@token))
    end

    private

    def decrypt_token(token)
      decipher = OpenSSL::Cipher::AES256.new(:CBC)
      decipher.decrypt
      decipher.key = AES_KEY
      decipher.iv = AES_IV
      decipher.update(Base64.decode64(token)) + decipher.final
    end

  end

end
