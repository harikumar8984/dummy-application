require 'openssl'
require 'base64'

class Content < ActiveRecord::Base
  has_many :course_contents , dependent: :destroy
  has_many :courses, through: :course_contents, dependent: :destroy
  has_many :player_usage_stats, dependent: :destroy

  mount_uploader :name, ContentUploader
  after_save :encrypt_content_data

 def encrypt_content_data
    @cipher = 'aes-128-cbc'
    d = OpenSSL::Cipher.new(@cipher)
    @secret = OpenSSL::PKCS5.pbkdf2_hmac_sha1("password", "some salt", 1024, d.key_len)
    cipher = OpenSSL::Cipher::Cipher.new(@cipher)
    iv = cipher.random_iv
    cipher.encrypt
    cipher.key = @secret
    cipher.iv = iv
    data = self.name.read
    #File.open(self.name.path,'r').read
    encrypted_data = cipher.update(data)
    encrypted_data << cipher.final
    e = [encrypted_data, iv].map {|v| Base64.strict_encode64(v)}.join("--")
    File.open(self.name.path,'w'){|f| f.write e}
   end

end
