module Vtiger
  class Base
    attr_accessor :md5,:token, :endpoint_url, :access_key, :session_name, :url, :username,  :userid, :campaigndb
    def challenge(options)
      self.url=options[:url] || Vtiger::Api.api_settings[:url]
      self.username = options[:username]|| Vtiger::Api.api_settings[:username]
      self.access_key = options[:key] || Vtiger::Api.api_settings[:key]
      self.endpoint_url="http://#{self.url}/vtigercrm/webservice.php?"
      operation = "operation=getchallenge&username=#{self.username}";
      #puts "challenge: " + self.endpoint_url + operation
      r=http_ask_get(self.endpoint_url+operation)
      self.token = r["result"]["token"] #if r["success"]==true

      create_digest
      #  puts "digest is: #{self.md5} token #{self.token}"
      self.token!=nil
    end
  end
end

Vtiger::Api.api_settings = {
    username: 'Hari',
    key: 'JZSpZjKgqfpha2v',
    url: 'vtiger.nuryl.com',
    element_type: 'Contacts'
}






