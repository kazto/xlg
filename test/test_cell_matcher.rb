require 'minitest/autorun'
require_relative '../lib/cell_matcher'

class TestCellMatcher < Minitest::Test
  def setup
    @text_matcher = CellMatcher.new("Hello")
    @regex_matcher = CellMatcher.new('\d+')
  end

  def test_match_exact_keyword
    matcher = CellMatcher.new("Hello")
    assert matcher.match?("Hello World")
    matcher = CellMatcher.new("Test")
    assert matcher.match?("Test")
    matcher = CellMatcher.new("World")
    refute matcher.match?("Hello")
  end

  def test_match_case_insensitive
    matcher = CellMatcher.new("hello")
    assert matcher.match?("Hello World")
    matcher = CellMatcher.new("test")
    assert matcher.match?("TEST")
    matcher = CellMatcher.new("camelcase")
    assert matcher.match?("CamelCase")
  end

  def test_match_partial_keyword
    matcher = CellMatcher.new("test")
    assert matcher.match?("This is a test")
    matcher = CellMatcher.new("World")
    assert matcher.match?("HelloWorld")
    matcher = CellMatcher.new("fix")
    assert matcher.match?("prefix_suffix")
  end

  def test_match_with_numbers
    matcher = CellMatcher.new("123")
    assert matcher.match?("Order123")
    matcher = CellMatcher.new("2023")
    assert matcher.match?("2023-01-01")
    matcher = CellMatcher.new("1.0")
    assert matcher.match?("Version 1.0")
  end

  def test_match_with_special_characters
    matcher = CellMatcher.new("@")
    assert matcher.match?("email@example.com")
    matcher = CellMatcher.new("$")
    assert matcher.match?("Price: $100")
    matcher = CellMatcher.new("%")
    assert matcher.match?("100%")
  end

  def test_match_empty_or_nil
    matcher = CellMatcher.new("test")
    refute matcher.match?(nil)
    refute matcher.match?("")
  end

  def test_extract_match_basic
    matcher = CellMatcher.new("Hello")
    assert_equal "Hello", matcher.extract_match("Hello World")
    matcher = CellMatcher.new("test")
    assert_equal "test", matcher.extract_match("This is a test")
  end

  def test_extract_match_case_insensitive
    matcher = CellMatcher.new("hello")
    assert_equal "Hello", matcher.extract_match("Hello World")
    matcher = CellMatcher.new("test")
    assert_equal "TEST", matcher.extract_match("TEST data")
  end

  def test_extract_match_multiple_occurrences
    matcher = CellMatcher.new("test")
    result = matcher.extract_match("test test test")
    assert_equal "test", result
  end

  def test_extract_match_no_match
    matcher = CellMatcher.new("xyz")
    assert_nil matcher.extract_match("Hello World")
    matcher = CellMatcher.new("test")
    assert_nil matcher.extract_match("")
    assert_nil matcher.extract_match(nil)
  end

  def test_match_with_whitespace
    matcher = CellMatcher.new("Hello")
    assert matcher.match?("  Hello World  ")
    matcher = CellMatcher.new("Tab")
    assert matcher.match?("Tab\tSeparated")
    matcher = CellMatcher.new("Line")
    assert matcher.match?("Line\nBreak")
  end

  def test_match_japanese_text
    matcher = CellMatcher.new("こんにちは")
    assert matcher.match?("こんにちは世界")
    matcher = CellMatcher.new("テスト")
    assert matcher.match?("テストデータ")
    matcher = CellMatcher.new("カタカナ")
    assert matcher.match?("ひらがなカタカナ漢字")
  end

  # 正規表現テストの追加
  def test_regex_basic_patterns
    matcher = CellMatcher.new('\d+')
    assert matcher.match?("Order123")
    assert matcher.match?("2023-01-01")
    refute matcher.match?("No numbers here")
    
    matcher = CellMatcher.new('[A-Z]+')
    assert matcher.match?("HELLO")
    assert matcher.match?("Test ABC")
    assert matcher.match?("lowercase only")  # This will match because regex is case-insensitive by default
  end

  def test_regex_date_pattern
    matcher = CellMatcher.new('\d{4}-\d{2}-\d{2}')
    assert matcher.match?("Today is 2023-12-25")
    assert matcher.match?("2023-01-01")
    refute matcher.match?("23-1-1")
    refute matcher.match?("No date here")
  end

  def test_regex_or_pattern
    matcher = CellMatcher.new('test|demo')
    assert matcher.match?("This is a test")
    assert matcher.match?("demo version")
    assert matcher.match?("test and demo")
    refute matcher.match?("production")
  end

  def test_regex_case_insensitive_flag
    matcher = CellMatcher.new('/hello/i')
    assert matcher.match?("Hello World")
    assert matcher.match?("HELLO")
    assert matcher.match?("hello")
    
    matcher = CellMatcher.new('/test/i')
    assert matcher.match?("TEST")
    assert matcher.match?("Test")
    assert matcher.match?("test")
  end

  def test_regex_start_end_anchors
    matcher = CellMatcher.new('^Hello')
    assert matcher.match?("Hello World")
    refute matcher.match?("Say Hello")
    
    matcher = CellMatcher.new('World$')
    assert matcher.match?("Hello World")
    refute matcher.match?("World Hello")
  end

  def test_regex_character_classes
    matcher = CellMatcher.new('[aeiou]+')
    assert matcher.match?("beautiful")
    assert matcher.match?("audio")
    refute matcher.match?("rhythm")
    
    matcher = CellMatcher.new('[0-9]+')
    assert matcher.match?("Order123")
    assert matcher.match?("999")
    refute matcher.match?("No digits")
  end

  def test_regex_quantifiers
    matcher = CellMatcher.new('a+')
    assert matcher.match?("aaa")
    assert matcher.match?("banana")
    refute matcher.match?("bbb")
    
    matcher = CellMatcher.new('a?b')
    assert matcher.match?("ab")
    assert matcher.match?("b")
    assert matcher.match?("aab")  # This should match because 'a?b' matches the 'ab' part
  end

  def test_regex_extract_match
    matcher = CellMatcher.new('\d{4}-\d{2}-\d{2}')
    assert_equal "2023-12-25", matcher.extract_match("Today is 2023-12-25")
    
    matcher = CellMatcher.new('[A-Z]+')
    assert_equal "HELLO", matcher.extract_match("HELLO world")
    
    matcher = CellMatcher.new('test|demo')
    assert_equal "test", matcher.extract_match("This is a test")
    assert_equal "demo", matcher.extract_match("demo version")
  end

  def test_regex_complex_patterns
    # Email pattern (simplified)
    matcher = CellMatcher.new('[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
    assert matcher.match?("Contact: user@example.com")
    refute matcher.match?("Not an email")
    
    # Phone number pattern
    matcher = CellMatcher.new('\d{3}-\d{3}-\d{4}')
    assert matcher.match?("Call 555-123-4567")
    refute matcher.match?("555-12-34")
  end

  def test_invalid_regex_fallback
    # Invalid regex should fall back to literal text matching
    matcher = CellMatcher.new('[unclosed')
    assert matcher.match?("[unclosed")
    refute matcher.match?("not matching")
  end

  def test_edge_case_empty_pattern
    assert_raises(ArgumentError) { CellMatcher.new("") }
    assert_raises(ArgumentError) { CellMatcher.new(nil) }
  end
end