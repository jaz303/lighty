module Lighty
  class App
    
    def initialize(cwd)
      @cwd = cwd
    end
    
    def run
      begin
        setup_signal_handlers
        prepare_global_config
        merge_global_config
        merge_local_config
        merge_inline_config
        write_temporary_config_file
        invoke_lighty
      ensure
        cleanup
      end
    end
    
    private
    
    def setup_signal_handlers
      trap('INT') { cleanup }
    end
    
    def prepare_global_config
      unless File.exists?(config_dir)
        FileUtils.cp_r(File.join(File.dirname(__FILE__), '..', '..', 'skel'), config_dir)
      end
    end
    
    def merge_global_config
      config_hash.recursive_merge!(YAML.load_file(config_path('config.yml')))
    end
    
    def merge_local_config
      local_config_file = File.join(@cwd, '.lighty.yml')
      if File.exists?(local_config_file)
        config_hash.recursive_merge!(YAML.load_file(local_config_file))
      end
    end
    
    def merge_inline_config
      config_hash.recursive_merge!(inline_config_hash)
    end
    
    def write_temporary_config_file
      @temporary_config_filename = "/tmp/lighty.#{config.port}.conf"
      raise "Error: temporary config file #{@temporary_config_filename} exists\nIs there already a lighty on this port?" if File.exists?(@temporary_config_filename)
      File.open(@temporary_config_filename, "w") { |f| f.write(config.to_lighty) }
    end
    
    def invoke_lighty
      lighty_bin = config.try('lighty')
      raise "Error: lighty executable path not set" unless lighty_bin
      raise "Error: lighty executable not found" unless File.exists?(lighty_bin)
      `#{lighty_bin} -D -f #{@temporary_config_filename}`
    end
    
    def cleanup
      if @temporary_config_filename && File.exists?(@temporary_config_filename)
        FileUtils.rm(@temporary_config_filename)
      end
    end
    
    def config_hash
      @config_hash ||= {}
    end
    
    # don't call until config_hash is finalised
    def config
      @config ||= Config.new(sanitize_config(config_hash), config_template)
    end
    
    def config_dir
      File.join(ENV['HOME'], '.lighty')
    end
    
    def config_path(filename)
      File.join(config_dir, filename)
    end
    
    def config_template
      File.read(config_path('lighty.conf.erb'))
    end
    
    def inline_config_hash
      hash = {}
      
      OptionParser.new do |opts|
        opts.banner = "Usage: lighty [options]"
        
        opts.on("-r", "--root [ROOT]", "Set the document root") do |v|
          hash["document_root"] = v
        end
        
        opts.on("-p", "--port [PORT]", "Set the port") do |v|
          hash["port"] = v.to_i
        end
        
        opts.on("--php [VERSION]", "Set the PHP version") do |v|
          php_config = {}
          if v.nil? || %w(true false).include?(v)
            php_config["enabled"] = v || true
          else
            php_config["enabled"] = true
            php_config["version"] = v
          end
          hash.merge!("php" => php_config)
        end
        
        opts.on("--directory-listing", "Enable directory listing") do |v|
          has["directory_listing"] = v || true
        end
        
        opts.on("-d", "--dispatcher [DISPATCHER]", "Set the dispatcher") do |v|
          hash["dispatcher"] = v
        end
      end.parse!
      
      hash
    end
    
    def sanitize_config(hash)
      hash.inject({}) do |m,(k,v)|
        m.update(k => case v
                      when 'true'
                        true
                      when 'false'
                        false
                      when Hash
                        sanitize_config(v)
                      else
                        v
                      end)
      end
    end
    
  end
end