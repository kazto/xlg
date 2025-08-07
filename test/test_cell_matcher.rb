require 'minitest/autorun'
require_relative '../lib/cell_matcher'

class TestCellMatcher < Minitest::Test
  def setup
    @matcher = CellMatcher.new
  end

  def test_match_exact_keyword
    assert @matcher.match?("Hello World", "Hello")
    assert @matcher.match?("Test", "Test")
    refute @matcher.match?("Hello", "World")
  end

  def test_match_case_insensitive
    assert @matcher.match?("Hello World", "hello")
    assert @matcher.match?("TEST", "test")
    assert @matcher.match?("CamelCase", "camelcase")
  end

  def test_match_partial_keyword
    assert @matcher.match?("This is a test", "test")
    assert @matcher.match?("HelloWorld", "World")
    assert @matcher.match?("prefix_suffix", "fix")
  end

  def test_match_with_numbers
    assert @matcher.match?("Order123", "123")
    assert @matcher.match?("2023-01-01", "2023")
    assert @matcher.match?("Version 1.0", "1.0")
  end

  def test_match_with_special_characters
    assert @matcher.match?("email@example.com", "@")
    assert @matcher.match?("Price: $100", "$")
    assert @matcher.match?("100%", "%")
  end

  def test_match_empty_or_nil
    refute @matcher.match?(nil, "test")
    refute @matcher.match?("", "test")
    refute @matcher.match?("test", "")
  end

  def test_extract_match_basic
    assert_equal "Hello", @matcher.extract_match("Hello World", "Hello")
    assert_equal "test", @matcher.extract_match("This is a test", "test")
  end

  def test_extract_match_case_insensitive
    assert_equal "Hello", @matcher.extract_match("Hello World", "hello")
    assert_equal "TEST", @matcher.extract_match("TEST data", "test")
  end

  def test_extract_match_multiple_occurrences
    result = @matcher.extract_match("test test test", "test")
    assert_equal "test", result
  end

  def test_extract_match_no_match
    assert_nil @matcher.extract_match("Hello World", "xyz")
    assert_nil @matcher.extract_match("", "test")
    assert_nil @matcher.extract_match(nil, "test")
  end

  def test_match_with_whitespace
    assert @matcher.match?("  Hello World  ", "Hello")
    assert @matcher.match?("Tab\tSeparated", "Tab")
    assert @matcher.match?("Line\nBreak", "Line")
  end

  def test_match_japanese_text
    assert @matcher.match?("こんにちは世界", "こんにちは")
    assert @matcher.match?("テストデータ", "テスト")
    assert @matcher.match?("ひらがなカタカナ漢字", "カタカナ")
  end
end