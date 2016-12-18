require "drbcli/version"
require 'ruby_parser'
require 'method_source'
require 'drb'
require 'thor'
require 'active_support'

# Usage: arrays.to_list #=> '("user_id" "name") 
class Array
  def to_list
    inspect.gsub(/\[/, "(").gsub(/\]/, ")").gsub(/,/, "").sub(/^/, "'")
  end
end

# Usage: hash.to_list(-> k { k.underscore }, -> v { v.nil? ? 'null' : v })  
#=> '(("name" . "Steve") ("name2" . "Jobs") )'  
class Hash
  def to_list (key_proc, val_proc)
    inject("") do |s, (k, v)|
      s = s + " (\"#{key_proc.call(k)}\" . \"#{val_proc.call(v)}\") " ; s
    end.to_s.sub(/^/, "'(").sub(/$/, ')')
  end
end

$st_outputs = []
class Object
  include MethodSource::CodeHelpers
  def camelize(first_letter = :upper)
    case first_letter
    when :upper
      ActiveSupport::Inflector.camelize(self, true)
    when :lower
      ActiveSupport::Inflector.camelize(self, false)
    end
  end
  def underscore
    ActiveSupport::Inflector.underscore(self)
  end
  def stp (obj)
    $st_outputs = $st_outputs + [obj]
  end
  def clear_st_outputs
    $st_outputs = []
  end
  
  def drb_start
    (class << self; self; end).class_eval <<-EOF, __FILE__, __LINE__ + 1
      def __drbcli__
       ::Kernel.binding
       end
    EOF
    DRb.start_service("druby://localhost:9000", self.__drbcli__)
    puts "Server running at #{DRb.uri}"
    DRb.thread.join
  end
  # For ` alias rbsandbox=' RAILS_ENV=production rails c --sandbox '  `
  def drb_start_pro drbenv
    DRb.start_service 'druby://0.0.0.0:9018', drbenv
    puts "Server running at #{DRb.uri}"
    DRb.thread.join
  end
end

# .. 
module Drbcli
  # Your code goes here...
end
