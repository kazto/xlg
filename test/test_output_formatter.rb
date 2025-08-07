require 'minitest/autorun'
require_relative '../lib/output_formatter'

class TestOutputFormatter < Minitest::Test
  def setup
    @formatter = OutputFormatter.new
  end

  def test_format_basic
    result = @formatter.format("test.xlsx", "Sheet1", "A1", "Hello")
    expected = "test.xlsx:Sheet1:A1:Hello"
    assert_equal expected, result
  end

  def test_format_with_japanese_sheet_name
    result = @formatter.format("sample.xlsx", "シート1", "B2", "テスト")
    expected = "sample.xlsx:シート1:B2:テスト"
    assert_equal expected, result
  end

  def test_format_with_long_cell_reference
    result = @formatter.format("data.xlsx", "Sheet2", "AA100", "Value")
    expected = "data.xlsx:Sheet2:AA100:Value"
    assert_equal expected, result
  end

  def test_format_with_special_characters_in_filename
    result = @formatter.format("file-name_with.special.xlsx", "Sheet1", "C3", "Data")
    expected = "file-name_with.special.xlsx:Sheet1:C3:Data"
    assert_equal expected, result
  end

  def test_format_with_spaces_in_sheet_name
    result = @formatter.format("report.xlsx", "Monthly Report", "D4", "Sales")
    expected = "report.xlsx:Monthly Report:D4:Sales"
    assert_equal expected, result
  end

  def test_format_with_multiline_content
    content = "Line1\nLine2"
    result = @formatter.format("multi.xlsx", "Sheet1", "E5", content)
    expected = "multi.xlsx:Sheet1:E5:Line1\nLine2"
    assert_equal expected, result
  end

  def test_format_with_empty_content
    result = @formatter.format("empty.xlsx", "Sheet1", "F6", "")
    expected = "empty.xlsx:Sheet1:F6:"
    assert_equal expected, result
  end

  def test_format_with_numeric_content
    result = @formatter.format("numbers.xlsx", "Sheet1", "G7", "12345")
    expected = "numbers.xlsx:Sheet1:G7:12345"
    assert_equal expected, result
  end

  def test_format_with_mixed_content
    content = "Price: $100 (税込み)"
    result = @formatter.format("price.xlsx", "価格表", "H8", content)
    expected = "price.xlsx:価格表:H8:Price: $100 (税込み)"
    assert_equal expected, result
  end

  def test_format_consistency
    file = "test.xlsx"
    sheet = "Sheet1"
    cell = "A1"
    content = "Test"
    
    result1 = @formatter.format(file, sheet, cell, content)
    result2 = @formatter.format(file, sheet, cell, content)
    
    assert_equal result1, result2
  end

  def test_format_separator_consistency
    result = @formatter.format("file.xlsx", "sheet", "A1", "content")
    separators = result.scan(/:/).count
    assert_equal 3, separators
  end

  def test_format_order
    result = @formatter.format("file.xlsx", "sheet", "A1", "content")
    parts = result.split(':')
    
    assert_equal "file.xlsx", parts[0]
    assert_equal "sheet", parts[1]
    assert_equal "A1", parts[2]
    assert_equal "content", parts[3]
  end
end