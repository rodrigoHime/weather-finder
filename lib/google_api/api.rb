module GoogleApi
  class << self
    attr_accessor :api_key

    def configure
      yield self
    end

    def options(params)
      { query: params.merge(key: api_key) }
    end
  end
end