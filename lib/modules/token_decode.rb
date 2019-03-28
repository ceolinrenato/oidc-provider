module TokenDecode

  RSA_PRIVATE = OpenSSL::PKey::RSA.new Rails.application.credentials.dig(:oidc, :private_key)
  AES_KEY = Base64.decode64(Rails.application.credentials.dig(:oidc, :aes_key))

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
    rescue JWT::DecodeError
      case self.class.to_s
      when "TokenDecode::AccessToken"
        raise CustomExceptions::InvalidAccessToken.new
      when "TokenDecode::IDToken"
        raise CustomExceptions::InvalidIDToken.new
      else
        raise JWT::DecodeError
      end
    end

  end

  class AccessToken < IDToken

    def decode
      decode_jwt(decrypt_token(@token))
    end

    private

    def decrypt_token(token)
      encrypted_data = token.split('.')
      iv = Base64.decode64(encrypted_data.first)
      raise CustomExceptions::InvalidAccessToken.new unless iv.size == 16
      decipher = OpenSSL::Cipher::AES256.new(:CBC)
      decipher.decrypt
      decipher.key = AES_KEY
      decipher.iv = iv
      decipher.update(Base64.decode64(encrypted_data.last)) + decipher.final
    rescue OpenSSL::Cipher::CipherError
      raise CustomExceptions::InvalidAccessToken.new
    end

  end

end
