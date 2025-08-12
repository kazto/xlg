require 'minitest/autorun'
require 'tempfile'
require 'fileutils'
require_relative '../lib/excel_grep'

class TestRegexIntegration < Minitest::Test
  def setup
    @test_dir = Dir.mktmpdir
    @test_file = File.join(@test_dir, 'test_regex.xlsx')
    create_test_excel_file
  end

  def teardown
    FileUtils.rm_rf(@test_dir)
  end

  def test_regex_date_search
    grep = ExcelGrep.new('\d{4}-\d{2}-\d{2}', @test_file)
    
    output = capture_output { grep.search }
    
    assert_includes output, "2023-12-25"
    assert_includes output, "2024-01-01"
    refute_includes output, "invalid date"
  end

  def test_regex_email_search
    grep = ExcelGrep.new('[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+', @test_file)
    
    output = capture_output { grep.search }
    
    assert_includes output, "user@example.com"
    assert_includes output, "admin@test.org"
    refute_includes output, "not-an-email"
  end

  def test_regex_number_pattern
    grep = ExcelGrep.new('\d{3}-\d{3}-\d{4}', @test_file)
    
    output = capture_output { grep.search }
    
    assert_includes output, "555-123-4567"
    # Check that 123-45 doesn't match the pattern (it's in a different cell)
    refute_includes output, ":123-45:"  # Check that 123-45 is not the extracted match
  end

  def test_regex_or_pattern
    grep = ExcelGrep.new('urgent|important', @test_file)
    
    output = capture_output { grep.search }
    
    assert_includes output, "urgent"
    assert_includes output, "important"
    refute_includes output, "normal"
  end

  def test_regex_case_insensitive_flag
    grep = ExcelGrep.new('/hello/i', @test_file)
    
    output = capture_output { grep.search }
    
    assert_includes output, "Hello"
    assert_includes output, "HELLO"
    assert_includes output, "hello"
  end

  def test_regex_start_anchor
    grep = ExcelGrep.new('^Total:', @test_file)
    
    output = capture_output { grep.search }
    
    assert_includes output, "Total:"
    refute_includes output, "Grand Total: 200"
  end

  def test_regex_end_anchor
    grep = ExcelGrep.new('yen$', @test_file)
    
    output = capture_output { grep.search }
    
    assert_includes output, "yen"
    refute_includes output, "yen currency"
  end

  def test_text_fallback_for_invalid_regex
    grep = ExcelGrep.new('[unclosed', @test_file)
    
    output = capture_output { grep.search }
    
    assert_includes output, "[unclosed"
  end

  private

  def create_test_excel_file
    require 'rubyXL'
    
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    
    # Test data for regex patterns
    test_data = [
      ["Date", "2023-12-25", "2024-01-01", "invalid date"],
      ["Email", "user@example.com", "admin@test.org", "not-an-email"],
      ["Phone", "555-123-4567", "123-45", "call me"],
      ["Priority", "urgent task", "important note", "normal work"],
      ["Case", "Hello World", "HELLO", "hello there"],
      ["Anchor", "Total: 100", "Grand Total: 200", "Summary"],
      ["Currency", "1000 yen", "yen currency", "dollars"],
      ["Invalid", "[unclosed bracket", "normal text", "data"]
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