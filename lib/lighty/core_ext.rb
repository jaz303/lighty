class Hash
  def recursive_merge!(other_hash)
    other_hash.each do |k,v|
      if v.is_a?(Hash) && (self[k] ||= {}).is_a?(Hash)
        self[k].recursive_merge!(v)
      else
        self[k] = v
      end
    end
  end
end