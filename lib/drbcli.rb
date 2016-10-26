require "drbcli/version"
require 'ruby_parser'
require 'method_source'
require 'drb'
require 'thor'
require 'activesupport'

$st_outputs = []
class Object
  include MethodSource::CodeHelpers
  include ActiveSupport::Inflector
  def stp (obj)
    $st_outputs = $st_outputs + [obj]
  end
  def clear_st_outputs
    $st_outputs = []
  end
  def drb_start drbenv
    DRb.start_service 'druby://localhost:9000', drbenv
    puts "Server running at #{DRb.uri}"
    DRb.thread.join
  end
  # For ` alias rbsandbox=' RAILS_ENV=production rails c --sandbox '  `
  def drb_start_pro drbenv
    DRb.start_service 'druby://localhost:9018', drbenv
    puts "Server running at #{DRb.uri}"
    DRb.thread.join
  end
end

# .. 
module Drbcli
  # Your code goes here...
end
