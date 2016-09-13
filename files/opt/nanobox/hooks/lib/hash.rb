class Hash
  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end

  def deep_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
    end
    self
  end

  def deep_stringify_keys
    deep_transform_keys{ |key| key.to_s }
  end

  def deep_symbolize_keys
    deep_transform_keys{ |key| key.to_sym }
  end

  def deep_transform_keys(&block)
    _deep_transform_keys_in_object(self, &block)
  end

  def _deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = _deep_transform_keys_in_object(value, &block)
      end
    when Array
      object.map {|e| _deep_transform_keys_in_object(e, &block) }
    else
      object
    end
  end

  def prune_empty
    delete_if do |key, value| 
      if value.is_a? Hash
        value.prune_empty 
      end

      if value.respond_to? :empty?
        value.nil? or value.empty?
      else
        value.nil?
      end
    end
  end
end
