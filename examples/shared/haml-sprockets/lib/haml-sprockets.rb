require 'haml-sprockets/version'
require 'tilt'
require 'sprockets'
require 'execjs'

module Haml
  module Sprockets
    class Template < ::Tilt::Template
      def self.engine_initialized?
        true
      end

      def initialize_engine
      end

      def prepare
      end

      def evaluate(scope, locals, &block)
        haml_code = data.dup
        haml_code = haml_code.gsub(/\\/,"\\\\").gsub(/\'/,"\\\\'").gsub(/\n/,"\\n")

        support = File.read(File.join(File.dirname(__FILE__), 'underscore.js')) + File.read(File.join(File.dirname(__FILE__), 'underscore.string.js'))
        haml_path = File.join(File.dirname(__FILE__), 'haml.js') #File.join("../../vendor/assets/javascripts/haml.js", __FILE__)
        haml_lib = File.read(haml_path)
        context = ExecJS.compile(support + haml_lib)
        #puts "HAML: #{haml_code}"
        compiled = context.eval("haml.compileHaml({source:'#{haml_code}', outputFormat:'string'})")
        #puts "Compiled: #{compiled.inspect}"
        return compiled #eval("Haml.optimize(Haml.compile('#{haml_code}', {escapeHtmlByDefault: true}))")
      end
    end
  end
end

Sprockets::Engines
Sprockets.register_engine '.hamlc', Haml::Sprockets::Template
require 'haml-sprockets/engine' if defined?(Rails)
