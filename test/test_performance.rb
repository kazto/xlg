require 'minitest/autorun'
require 'tempfile'
require 'fileutils'
require 'benchmark'

# Set up load path for non-gem testing
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cell_matcher'
require 'excel_grep'

class TestPerformance < Minitest::Test
  def setup
    @test_dir = Dir.mktmpdir
    @large_test_file = File.join(@test_dir, 'large_performance_test.xlsx')
    @regex_test_file = File.join(@test_dir, 'regex_performance_test.xlsx')
    create_large_test_file
    create_regex_test_file
  end

  def teardown
    FileUtils.rm_rf(@test_dir)
  end

  def test_large_file_performance
    puts "\n=== Large File Performance Test ==="
    
    # Test with simple text search
    time_text = Benchmark.realtime do
      grep = ExcelGrep.new('data', @large_test_file)
      capture_output { grep.search }
    end
    
    # Test with regex search
    time_regex = Benchmark.realtime do
      grep = ExcelGrep.new('\d+', @large_test_file)
      capture_output { grep.search }
    end
    
    puts "Text search time: #{time_text.round(3)}s"
    puts "Regex search time: #{time_regex.round(3)}s"
    
    # Performance assertions - should complete within reasonable time
    assert time_text < 10.0, "Text search took too long: #{time_text}s"
    assert time_regex < 15.0, "Regex search took too long: #{time_regex}s"
  end

  def test_complex_regex_performance
    puts "\n=== Complex Regex Performance Test ==="
    
    complex_patterns = [
      '\d{4}-\d{2}-\d{2}',                    # Date pattern
      '[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+', # Email pattern
      '\$\d+\.\d{2}',                         # Price pattern
      '^[A-Z][a-z]+\s+[A-Z][a-z]+$',        # Name pattern
      '(test|demo|sample|data)'               # Alternation pattern
    ]
    
    complex_patterns.each do |pattern|
      time = Benchmark.realtime do
        grep = ExcelGrep.new(pattern, @regex_test_file)
        capture_output { grep.search }
      end
      
      puts "Pattern '#{pattern}': #{time.round(3)}s"
      assert time < 5.0, "Complex regex '#{pattern}' took too long: #{time}s"
    end
  end

  def test_memory_usage_large_cells
    puts "\n=== Memory Usage Test ==="
    
    # Create a matcher with very large cell content
    large_cell_content = "prefix " + ("data " * 10000) + " target suffix"
    
    # Test memory usage doesn't explode with large content
    memory_before = get_memory_usage
    
    matcher = CellMatcher.new('target')
    result = matcher.match?(large_cell_content)
    extracted = matcher.extract_match(large_cell_content)
    
    memory_after = get_memory_usage
    memory_diff = memory_after - memory_before
    
    puts "Memory usage difference: #{memory_diff} KB"
    
    assert result, "Should match target in large content"
    assert_equal "target", extracted, "Should extract correct match"
    
    # Memory usage should be reasonable (less than 100MB increase)
    assert memory_diff < 100_000, "Memory usage too high: #{memory_diff} KB"
  end

  def test_regex_compilation_performance
    puts "\n=== Regex Compilation Performance Test ==="
    
    patterns = [
      'simple',
      '\d+',
      '[a-zA-Z]+',
      '\d{4}-\d{2}-\d{2}',
      '(test|demo|sample)',
      '/complex/i',
      '^start.*end$'
    ]
    
    patterns.each do |pattern|
      time = Benchmark.realtime do
        100.times do
          CellMatcher.new(pattern)
        end
      end
      
      puts "Pattern '#{pattern}' (100x): #{time.round(3)}s"
      assert time < 1.0, "Regex compilation too slow for '#{pattern}': #{time}s"
    end
  end

  def test_backtracking_protection
    puts "\n=== Backtracking Protection Test ==="
    
    # Patterns that could cause catastrophic backtracking
    dangerous_patterns = [
      '(a+)+b',
      '(a|a)*b',
      '(a+)*b'
    ]
    
    test_string = 'a' * 20 + 'c'  # Should not match and could cause backtracking
    
    dangerous_patterns.each do |pattern|
      time = Benchmark.realtime do
        begin
          matcher = CellMatcher.new(pattern)
          result = matcher.match?(test_string)
        rescue => e
          puts "Pattern '#{pattern}' failed gracefully: #{e.class}"
        end
      end
      
      puts "Dangerous pattern '#{pattern}': #{time.round(3)}s"
      assert time < 2.0, "Backtracking protection failed for '#{pattern}': #{time}s"
    end
  end

  private

  def create_large_test_file
    require 'rubyXL'
    
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    
    # Create a large file with 1000 rows and 10 columns
    puts "Creating large test file with 10,000 cells..."
    
    1000.times do |row|
      10.times do |col|
        value = case col
                when 0 then "Row #{row}"
                when 1 then row * 10 + col
                when 2 then "data_#{row}_#{col}"
                when 3 then Date.new(2023, (row % 12) + 1, (row % 28) + 1).strftime('%Y-%m-%d')
                when 4 then "user#{row}@example.com"
                when 5 then "$#{(row * 10 + col)}.99"
                else "content #{row}-#{col}"
                end
        
        worksheet.add_cell(row, col, value)
      end
      
      # Progress indicator
      print "." if row % 100 == 0
    end
    
    puts "\nWriting large test file..."
    workbook.write(@large_test_file)
  end

  def create_regex_test_file
    require 'rubyXL'
    
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    
    # Create test data with various patterns
    test_data = [
      ["Dates", "2023-12-25", "2024-01-01", "invalid-date"],
      ["Emails", "test@example.com", "user123@domain.org", "not-email"],
      ["Prices", "$99.99", "$1234.56", "no price"],
      ["Names", "John Smith", "Jane Doe", "lowercase name"],
      ["Keywords", "test data", "demo content", "sample info"]
    ]
    
    # Replicate the patterns multiple times for performance testing
    500.times do |i|
      test_data.each_with_index do |row, row_idx|
        row.each_with_index do |value, col_idx|
          actual_row = i * test_data.length + row_idx
          worksheet.add_cell(actual_row, col_idx, "#{value}_#{i}")
        end
      end
    end
    
    workbook.write(@regex_test_file)
  end

  def capture_output
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end

  def get_memory_usage
    # Simple memory usage check (Linux/Unix)
    if File.exist?('/proc/self/status')
      status = File.read('/proc/self/status')
      if match = status.match(/VmRSS:\s+(\d+) kB/)
        return match[1].to_i
      end
    end
    
    # Fallback for other systems
    0
  end
end