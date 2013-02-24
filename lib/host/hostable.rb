module Host
  module Hostable

      def has_many_hosts(options = {})
        has_many :hosts, {:class_name => "Host::Base"}.merge(options)
        has_many :managed_hosts, {:class_name => "Host::Managed"}.merge(options)
      end

      def belongs_to_host(options = {})
        belongs_to :host, {:class_name => "Host::Base", :foreign_key => :host_id}.merge(options)
        belongs_to :managed_host, {:class_name => "Host::Managed", :foreign_key => :host_id}.merge(options)
      end

  end
end
