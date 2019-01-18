require 'digest/md5'

module WxPay
  module Sign

    SIGN_TYPE_MD5 = 'MD5'
    SIGN_TYPE_HMAC_SHA256 = 'HMAC-SHA256'

    def self.generate(params, sign_type = SIGN_TYPE_MD5)
      key = params.delete(:key)

      query = params.sort.map do |k, v|
        "#{k}=#{v}" if v.to_s != ''
      end.compact.join('&')

      string_sign_temp = "#{query}&key=#{key || WxPay.key}"

      if sign_type == SIGN_TYPE_MD5
        Digest::MD5.hexdigest(string_sign_temp).upcase
      elsif sign_type == SIGN_TYPE_HMAC_SHA256
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, string_sign_temp).upcase
      else
        warn("WxPay Warn: unknown sign_type : #{sign_type}")
      end
    end

    def self.verify?(params, options = {})
      return true if WxPay.sandbox_mode?
      params = params.dup
#       params = params.merge(options)
      params = {
        appid: options.delete(:appid) || WxPay.appid,
        mch_id: options.delete(:mch_id) || WxPay.mch_id,
        key: options.delete(:key) || WxPay.key
      }.merge(params)
      sign = params.delete('sign') || params.delete(:sign)
      generate(params) == sign
    end
  end
end
