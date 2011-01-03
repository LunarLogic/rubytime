require 'net/ldap'
require 'yaml'

module Auth
  module LDAP

    def self.settings
      @settings ||=
        YAML.load_file(File.join(Merb.root, 'config', 'ldap.yml'))
    end


    def self.authenticate(login, password)
      ldap = Net::LDAP.new({
          :host => settings[:host],
          :base => settings[:base],
          :port => settings[:port],
          :auth => {
            :method => :simple,
            :username => "#{settings[:attr]}=#{login},#{settings[:base]}",
            :password => password
          }})
      ldap.bind
    end

  end
end
