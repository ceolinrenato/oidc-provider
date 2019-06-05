module TokenDecode
  RSA_PRIVATE = OpenSSL::PKey::RSA.new Rails.application.credentials.dig(:oidc, :private_key)
  AES_KEY = Base64.decode64(Rails.application.credentials.dig(:oidc, :aes_key))

  class IDToken
    def initialize(token)
      @token = token
    end

    def decode(options = { verify_expiration: true })
      decode_jwt(@token, options)
    end

    private

    def decode_jwt(token, options = { verify_expiration: true })
      jwt = JWT.decode token, RSA_PRIVATE.public_key, true,
                       algorithm: 'RS256',
                       exp_leeway: 1.minute,
                       iss: OIDC_PROVIDER_CONFIG[:iss],
                       verify_iss: true,
                       verify_expiration: options[:verify_expiration]
      jwt.first
    rescue JWT::DecodeError
      case self.class.to_s
      when 'TokenDecode::AccessToken'
        raise CustomExceptions::InvalidAccessToken
      when 'TokenDecode::IDToken'
        raise CustomExceptions::InvalidIDToken
      else
        raise JWT::DecodeError
      end
    end
  end

  class AccessToken < IDToken
    def decode
      decoded_token = decode_jwt(decrypt_token(@token))
      raise CustomExceptions::InvalidAccessToken unless Session.find_by token: decoded_token['sid']
      decoded_token
    end

    private

    def decrypt_token(token)
      encrypted_data = token.split('.')
      raise CustomExceptions::InvalidAccessToken unless encrypted_data.count == 2
      iv = Base64.urlsafe_decode64(encrypted_data.first)
      decipher = OpenSSL::Cipher::AES256.new(:CBC)
      decipher.decrypt
      decipher.key = AES_KEY
      decipher.iv = iv
      decipher.update(Base64.urlsafe_decode64(encrypted_data.last)) + decipher.final
    rescue OpenSSL::Cipher::CipherError, ArgumentError
      raise CustomExceptions::InvalidAccessToken
    end
  end
end
