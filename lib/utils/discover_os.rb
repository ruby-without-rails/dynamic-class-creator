require 'rbconfig'

module Utils
  # Module DiscoverOS
  module DiscoverOS
    class << self
      def os?
        case os_string
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/ then :windows
          when /darwin|mac os/ then :macosx
          when /linux/ then :linux
          when /solaris|bsd/ then :unix
          else raise StandardError, "Operational system not defined: #{os_string}"
        end
      end

      def os_string
        RbConfig::CONFIG['host_os']
      end
    end
  end
end
