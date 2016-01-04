# encoding: utf-8

class ContentUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if Rails.env == 'production'
    storage :fog
  else
    storage :file
  end

  version :android do
    process :encrypt_content_data
  end


  # after :store, :unlink_original
  #
  # def unlink_original(file)
  #   file.delete if version_name.blank?
  # end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.content_type}"
  end

  def encrypt_content_data
      @cipher = 'aes-128-cbc'
      d = OpenSSL::Cipher.new(@cipher)
      @secret = OpenSSL::PKCS5.pbkdf2_hmac_sha1("password", "some salt", 1024, d.key_len)
      cipher = OpenSSL::Cipher::Cipher.new(@cipher)
      iv = cipher.random_iv
      cipher.encrypt
      cipher.key = @secret
      cipher.iv = iv
      data = Rails.env == 'production' ? File.open(current_path,'r').read : File.open(self.path,'r').read
      encrypted_data = cipher.update(data)
      encrypted_data << cipher.final
      e = [encrypted_data, iv].map {|v| Base64.strict_encode64(v)}.join("--")
      Rails.env == 'production' ? File.open(current_path,'w'){|f| f.write e} : File.open(self.path,'w'){|f| f.write e}
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
