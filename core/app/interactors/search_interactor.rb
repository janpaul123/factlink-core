class SearchInteractor
  include Pavlov::CanCan
  include Pavlov::SearchHelper

  def initialize keywords, options={}
    raise 'Keywords should be an string.' unless keywords.kind_of? String
    raise 'Keywords must not be empty.'   unless keywords.length > 0

    @keywords = keywords
    @options = options
    @page = options[:page] || 1
    @row_count = options[:row_count] || 20
  end

  def execute
    return search_with(:elastic_search_all)
  end

  private
  def valid_result?(res)
    not invalid_result?(res)
  end

  def invalid_result?(res)
      res.nil? or
      (res.class == FactData and FactData.invalid(res)) or
      (res.class == User and res.hidden)
  end

  def keyword_min_length
    2
  end

  def authorized?
    can? :index, Fact
  end
end
