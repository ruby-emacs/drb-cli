# coding: utf-8
require "drbcli/version"
require 'ruby_parser'
require 'method_source'
require 'drb'
require 'thor'
require 'active_support'
require 'open3'
class Object
  $log_record = []
  def log file
    open(file,'a') do |f|
      yield(f)
    end
  end
end
class IOUndumpedProxy
  include DRb::DRbUndumped
  def initialize(obj)
    @obj = obj
  end
  def puts(*lines)
    @obj.puts(*lines)
  end
end
old_version = (2.4 > RUBY_VERSION.to_f and RUBY_VERSION.to_f >= 2.3)
patch_method = -> {
  # DRb::DRbServer.private_instance_methods(false) ;;=> :error_print
  module DRb
    class DRbServer
      private
      def error_print(exception)
        exception.backtrace.inject(true) do |first, x|
          if first
            $stderr.puts "#{x}: #{exception} (#{exception.class})"
          else
            $stderr.puts "\tfrom #{x}"
          end
          false
        end
      end
      #
      def main_loop
        client0 = @protocol.accept
        return nil if !client0
        Thread.start(client0) do |client|
          @grp.add Thread.current
          Thread.current['DRb'] = { 'client' => client ,
                                    'server' => self }
          DRb.mutex.synchronize do
            client_uri = client.uri
            @exported_uri << client_uri unless @exported_uri.include?(client_uri)
          end
          loop do
            begin
              succ = false
              invoke_method = InvokeMethod.new(self, client)
              succ, result = invoke_method.perform
              # 这个才是我们要打印的错误输出
              #log("/Users/emacs/aaa.log"){ |f| f.puts result } if !succ && verbose
              ##$stderr.puts result if !succ && verbose# 输出不到客户端
              # raise result if !succ && verbose 输出不到客户端
              if !succ && verbose
                $log_record << result.to_s
                ####($stdout.print result) rescue 11
                ##(DRb::DRbUndumped.new($stderr).puts result) rescue 22
                ##(DRb::DRbUndumped.new($stdout).puts result) rescue 33
              end
              client.send_reply(succ, result)
            rescue Exception => e
              # 这个是输出到server端的错误信息,但是没有我们要的drb文件执行错误信息
              # error_print(e) if verbose
              log("/Users/emacs/bbb.log"){ |f| f.puts e.backtrace } if verbose
            ensure
              client.close unless succ
              if Thread.current['DRb']['stop_service']
                Thread.new { stop_service }
              end
              break unless succ
            end
          end
        end
      end
      #
    end
  end
}

patch_method.call if old_version

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
    if RUBY_VERSION.to_f >= 2.4
      DRb.start_service("druby://localhost:9000", self.__drbcli__)
    else
      DRb.start_service("druby://localhost:9000", self.__drbcli__, verbose: true)
    end
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
