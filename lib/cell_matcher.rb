class CellMatcher
  def initialize(pattern)
    @pattern = pattern
    @compiled_pattern = compile_pattern(pattern)
  end

  def match?(cell_value)
    return false if cell_value.nil? || @pattern.nil? || @pattern.empty?
    
    cell_str = cell_value.to_s
    return false if cell_str.empty?
    
    if is_regex?(@pattern)
      !(@compiled_pattern =~ cell_str).nil?
    else
      cell_str.downcase.include?(@pattern.downcase)
    end
  end

  def extract_match(cell_value)
    return nil unless match?(cell_value)
    
    cell_str = cell_value.to_s
    
    if is_regex?(@pattern)
      match_result = @compiled_pattern.match(cell_str)
      match_result ? match_result[0] : nil
    else
      pattern_lower = @pattern.downcase
      start_index = cell_str.downcase.index(pattern_lower)
      return nil if start_index.nil?
      
      cell_str[start_index, @pattern.length]
    end
  end

  private

  def is_regex?(pattern)
    # Check if pattern looks like a regex (contains regex metacharacters)
    pattern.match?(/[.*+?^${}()|[\]\\]/) || 
    pattern.start_with?('/') && pattern.end_with?('/') ||
    pattern.start_with?('/') && pattern.match?(/\/[gimxo]*$/)
  end

  def compile_pattern(pattern)
    begin
      if is_regex?(pattern)
        # Handle /pattern/flags format
        if pattern.start_with?('/') && pattern.match?(/\/([gimxo]*)$/)
          # Extract pattern and flags
          match = pattern.match(/^\/(.*)\/([gimxo]*)$/)
          if match
            regex_pattern = match[1]
            flags = match[2]
            
            options = 0
            options |= Regexp::IGNORECASE if flags.include?('i')
            options |= Regexp::MULTILINE if flags.include?('m')
            options |= Regexp::EXTENDED if flags.include?('x')
            
            return Regexp.new(regex_pattern, options)
          end
        end
        
        # Try to compile as-is for patterns with metacharacters
        Regexp.new(pattern, Regexp::IGNORECASE)
      else
        # For plain text, return the pattern as-is
        pattern
      end
    rescue RegexpError => e
      # If regex compilation fails, treat as plain text
      pattern
    end
  end
end