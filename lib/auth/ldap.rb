require 'net/ldap'
require 'yaml'

class LdapConnectionError < StandardError; end

module Auth
  module LDAP
    LDAP_CONFIG_FILE = File.join(Rails.root, 'config', 'ldap.yml')

    def self.isLDAP?
      File.exist?(LDAP_CONFIG_FILE)
    end

    def self.settings
      @settings ||= YAML.load_file(LDAP_CONFIG_FILE)
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
    rescue Net::LDAP::LdapError, Timeout::Error, SystemCallError => e
      raise LdapConnectionError, e
    end
  end
end
