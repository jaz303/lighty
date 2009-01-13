module Lighty
  class Config
    
    def initialize(config_hash, template)
      @config_hash, @template = config_hash, template
    end
    
    def php_enabled?
      !! try('php.enabled') && php_binary_path
    end
    
    def php_binary_path
      path = if requested_version = try('php.version')
               php_version_binary_path(requested_version)
             else
               php_version_binary_path(best_php_version)
             end
      if path && (ini_options = try('php.ini')).is_a?(Hash)
        path += ini_options.map { |k,v| " -d #{k}=#{v}" }.join('')
      end
      path
    end
    
    def best_php_version
      available_versions = try("php.versions")
      return nil unless available_versions.is_a?(Hash) && available_versions.length > 0
      available_versions.keys.map { |v| v.split('_').map { |x| x.to_i } }.sort.pop.join('_')
    end
    
    def php_version_binary_path(version)
      return nil if version.nil?
      try("php.versions.#{version}")
    end
    
    def to_lighty
      ERB.new(@template).result(binding)
    end
    
    def method_missing(method, *args, &block)
      @config_hash[method.to_s]
    end
    
    def document_root
      given_root = @config_hash["document_root"]
      if given_root !~ %r{^/}
        %{CWD + \"/#{given_root}\"}
      else
        %{\"#{given_root}\"}
      end
    end
    
    def directory_listing
      !! try('directory_listing')
    end
    
    def try(path)
      hash = @config_hash
      path.split('.').each do |c|
        return nil unless hash.is_a?(Hash) && hash.key?(c)
        hash = hash[c]
      end
      hash
    end
    
  end
end