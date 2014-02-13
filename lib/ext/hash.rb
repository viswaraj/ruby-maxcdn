class Hash
  RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/

  def _escape(value)
    URI::escape(value.to_s, RESERVED_CHARACTERS)
  rescue ArgumentError
    URI::escape(value.to_s.force_encoding(Encoding::UTF_8), RESERVED_CHARACTERS)
  end

  def to_params
    params = ''
    stack = []

    each do |k, v|
      if v.is_a?(Hash)
        stack << [k,v]
      elsif v.is_a?(Array)
        stack << [k,Hash.from_array(v)]
      else
        params << "#{_escape(k)}=#{_escape(v)}&"
      end
    end

    stack.each do |parent, hash|
      parent = _escape(parent) if parent.is_a? String
      hash.each do |k, v|
        if v.is_a?(Hash)
          stack << ["#{parent}[#{k}]", v]
        else
          params << "#{parent}[#{k}]=#{_escape(v)}&"
        end
      end
    end

    params.chop!
    params
  end

  def self.from_array(array = [])
    h = Hash.new
    array.size.times do |t|
      h[t] = array[t]
    end
    h
  end
end

