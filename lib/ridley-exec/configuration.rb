require 'ridley'
require 'optparse'
require 'ostruct'

module RidleyExec
  module Configuration
    def self.env_default(name, default, opt={})
      val = ENV[name.to_s]
      return default if val.nil? || (val.size == 0 && opt[:no_blank])
      if block_given?
        val = yield val
      end

      val
    end


    def self.parse_args(args)
      options = {}
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: ridley-exec [options]"

        opts.separator ""
        opts.separator "Specific options:"

        options[:server_url] = env_default(:CHEF_SERVER_URL, nil, :no_blank => true)
        opts.on('-u [URL]', '--server-url [URL]', String, "The URL of the chef server to query") do |url|
          options[:server_url] = url
        end


        options[:client_name] = env_default(:CHEF_CLIENT_NAME, nil, :no_blank => true)
        opts.on('-n [CLIENT_NAME]', '--client-name [CLIENT_NAME]', String, "The name of the client to use for chef API operations.") do |client|
          options[:client_name] = client
        end


        options[:client_key] = env_default(:CHEF_CLIENT_KEY, nil, :no_blank => true)
        opts.on('-k [CLIENT_KEY]', '--client-key [CLIENT_KEY]', String, "The path to the client key file used for chef API operations.") do |key|
          options[:client_key] = key
        end

        options[:encrypted_data_bag_secret] = env_default(:CHEF_ENCRYPTED_DATA_BAG_SECRET, nil, :no_blank => true)
        opts.on('-s [SECRET]', '--encrypted-data-bag-secret [SECRET]', String, "The secret string for encrypting data bags.") do |secret|
          options[:encrypted_data_bag_secret] = secret
        end

        options[:knife_path] = env_default(:CHEF_KNIFE_PATH, nil)
        puts "Knife path nil? #{options[:knife_path].nil?}"
        opts.on('-p [KNIFE_PATH]', '--knife-path [KNIFE_PATH]', String, "Path to the knife.rb file to use for config (empty string does search)") do |path|
          path = '' if path.nil?
          options[:knife_path] = path
        end

        opts.on('-e [SCRIPT_STRING]', String, 'Execute the ruby in SCRIPT_STRING') do |script|
          options[:target] = prepare_script_string(script)
        end

        opts.on('-I', 'Execute the ruby from STDIN.') do
          options[:target] = prepare_stdin_script
        end

        opts.separator ""
        opts.separator "Common options:"
        opts.on_tail("-h", "--help", "Show this help message.") do
          puts opts
          exit 0
        end

        opts.on_tail("-v", "--version", "Print the version.") do
          puts RidleyExec::VERSION
          exit 0
        end
      end

      opt_parser.parse!(args)
      [options, args]
    end

    def self.api_from_knife(path)
      args = []
      args << path unless path.nil?
      Ridley.from_chef_config(*args)
    end

    def self.api_from_options(options)
      Ridley.new(options)
    end


    def self.prepare_script(path)
      Proc.new do |scope|
        eval File.read(path), scope, path
      end
    end

    def self.prepare_stdin_script
      Proc.new do |scope|
        eval STDIN.read, scope, '-stdin-'
      end
    end

    def self.prepare_script_string(script)
      Proc.new do |scope|
        eval script, scope, '-'
      end
    end

    def self.resolve_args(args)
      options, remaining = parse_args(args)
      options = options.inject({}) do |a, kv|
        a[kv[0]] = kv[1] unless kv[1].nil?
        a
      end

      if options.has_key? :target
        target = options.delete(:target)
      else
        target = prepare_script(remaining.shift)
      end

      if options.has_key? :knife_path
        api = api_from_knife(options[:knife_path])
      else
        api = api_from_options(options)
      end

      [api, target, remaining]
    end
  end
end
