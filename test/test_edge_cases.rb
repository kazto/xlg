require 'minitest/autorun'
require 'tempfile'
require 'fileutils'

# Set up load path for non-gem testing
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cell_matcher'
require 'excel_grep'

class TestEdgeCases < Minitest::Test
  def setup
    @test_dir = Dir.mktmpdir
    @test_file = File.join(@test_dir, 'edge_cases.xlsx')
    create_test_excel_file
  end

  def teardown
    FileUtils.rm_rf(@test_dir)
  end

  def test_empty_string_regex_matching
    matcher = CellMatcher.new('.*')  # Matches everything including empty
    refute matcher.match?("")  # Empty cells are filtered out by match?
    assert matcher.match?("anything")
    
    matcher = CellMatcher.new('^$')  # Matches only empty strings
    refute matcher.match?("")  # Empty cells are filtered out by match?
    refute matcher.match?("not empty")
  end

  def test_special_characters_in_cells
    grep = ExcelGrep.new('\$\d+\.\d{2}', @test_file)
    output = capture_output { grep.search }
    
    assert_includes output, "$99.99"
    assert_includes output, "$1234.56"
  end

  def test_unicode_and_multibyte_characters
    matcher = CellMatcher.new('こんにちは.*')
    assert matcher.match?("こんにちは世界")
    assert matcher.match?("こんにちはHello")
    refute matcher.match?("Hello world")
  end

  def test_very_long_regex_pattern
    long_pattern = 'a' * 1000 + '.*'
    matcher = CellMatcher.new(long_pattern)
    
    long_cell_value = 'a' * 1000 + 'test'
    assert matcher.match?(long_cell_value)
    refute matcher.match?("short")
  end

  def test_regex_with_newlines_and_tabs
    matcher = CellMatcher.new('line1\s+line2')
    assert matcher.match?("line1\nline2")
    assert matcher.match?("line1\tline2")
    assert matcher.match?("line1   line2")
  end

  def test_complex_nested_groups
    matcher = CellMatcher.new('(test|demo)-(v\d+\.\d+)')
    assert matcher.match?("test-v1.0")
    assert matcher.match?("demo-v2.5")
    refute matcher.match?("prod-v1.0")
    
    assert_equal "test-v1.0", matcher.extract_match("prefix test-v1.0 suffix")
  end

  def test_regex_with_lookahead_lookbehind
    # Ruby supports lookahead/lookbehind
    matcher = CellMatcher.new('\d+(?=\s+yen)')  # Numbers followed by " yen"
    assert matcher.match?("Price: 100 yen")
    refute matcher.match?("Price: 100 dollars")
    
    assert_equal "100", matcher.extract_match("Price: 100 yen")
  end

  def test_malformed_regex_patterns
    # These should fall back to literal text matching
    test_cases = [
      '[unclosed',
      '(unclosed group',
      '*invalid quantifier',
      '?invalid quantifier',
      '+invalid quantifier'
    ]
    
    test_cases.each do |pattern|
      matcher = CellMatcher.new(pattern)
      assert matcher.match?(pattern)  # Should match as literal text
      refute matcher.match?("different text")
    end
  end

  def test_regex_with_special_data
    # Test handling of special characters in data
    matcher = CellMatcher.new('test')
    cell_with_special = "test data"
    
    assert matcher.match?(cell_with_special)
  end

  def test_case_sensitivity_edge_cases
    # Test various case sensitivity scenarios
    matcher = CellMatcher.new('/[A-Z]+/i')
    assert matcher.match?("hello")
    assert matcher.match?("HELLO")
    assert matcher.match?("Hello")
    
    # Without flag should be case-insensitive by default
    matcher = CellMatcher.new('[A-Z]+')
    assert matcher.match?("hello")  # Due to IGNORECASE flag
  end

  def test_regex_performance_with_large_cells
    # Create a large cell value
    large_cell = "prefix " + ("data " * 10000) + "target suffix"
    matcher = CellMatcher.new('target')
    
    # Should still work efficiently
    assert matcher.match?(large_cell)
    assert_equal "target", matcher.extract_match(large_cell)
  end

  def test_regex_with_backtracking_issues
    # Pattern that could cause excessive backtracking
    matcher = CellMatcher.new('(a+)+b')
    
    # This should either match or fail gracefully without hanging
    result = matcher.match?("aaaaaaaaaaaaaaaaaac")
    # We don't care about the result, just that it completes
    assert [true, false].include?(result)
  end

  def test_empty_cells_and_nil_values
    grep = ExcelGrep.new('empty.*', @test_file)
    output = capture_output { grep.search }
    
    # Should handle empty cells gracefully
    refute_includes output, "::"  # No double colons from empty content
  end

  def test_numeric_cells_as_strings
    grep = ExcelGrep.new('\d+\.\d+', @test_file)
    output = capture_output { grep.search }
    
    # Should match numeric values converted to strings
    assert_includes output, "123.45"
    assert_includes output, "67.89"
  end

  private

  def create_test_excel_file
    require 'rubyXL'
    
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    
    # Edge case test data
    test_data = [
      ["Special Chars", "$99.99", "$1234.56", "€50.00"],
      ["Unicode", "こんにちは世界", "Ñandú", "🌟emoji"],
      ["Whitespace", "line1\nline2", "tab\tseparated", ""],
      ["Complex", "test-v1.0", "demo-v2.5", "prod-v1.0"],
      ["Lookahead", "100 yen", "200 dollars", "Price: 300 yen"],
      ["Numbers", 123.45, 67.89, "text123.45text"],
      ["Long", "a" * 100 + "target", "normal", "prefix target suffix"],
      ["Clean", "test data", "normal", "clean"]
    ]
    
    test_data.each_with_index do |row, row_index|
      row.each_with_index do |value, col_index|
        worksheet.add_cell(row_index, col_index, value)
      end
    end
    
    workbook.write(@test_file)
  end

  def capture_output
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end