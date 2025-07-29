module JwtAuthenticable
  extend ActiveSupport::Concern

  JWT_SECRET = Rails.application.credentials.secret_key_base || "fallback_secret"
  ALGORITHM = "HS256"

  class_methods do
    def encode_token(payload)
      payload[:exp] = 24.hours.from_now.to_i
      JWT.encode(payload, JWT_SECRET, ALGORITHM)
    end

    def decode_token(token)
      decoded = JWT.decode(token, JWT_SECRET, true, { algorithm: ALGORITHM })
      decoded[0]
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      nil
    end
  end

  def generate_token
    self.class.encode_token({
      user_id: id,
      user_type: self.class.name,
      email: respond_to?(:email) ? email : nil
    })
  end
end
