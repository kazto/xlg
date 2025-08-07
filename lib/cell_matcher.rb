class CellMatcher
  def match?(cell_value, keyword)
    return false if cell_value.nil? || keyword.nil? || keyword.empty?
    
    cell_str = cell_value.to_s
    return false if cell_str.empty?
    
    cell_str.downcase.include?(keyword.downcase)
  end

  def extract_match(cell_value, keyword)
    return nil unless match?(cell_value, keyword)
    
    cell_str = cell_value.to_s
    keyword_lower = keyword.downcase
    
    start_index = cell_str.downcase.index(keyword_lower)
    return nil if start_index.nil?
    
    cell_str[start_index, keyword.length]
  end
end