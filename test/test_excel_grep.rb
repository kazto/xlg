require 'minitest/autorun'
require 'tempfile'
require 'fileutils'
require_relative '../lib/excel_grep'

class TestExcelGrep < Minitest::Test
  def setup
    @test_file = "test_sample.xlsx"
    @missing_file = "missing_file.xlsx"
    @keyword = "test"
  end

  def test_initialize_with_valid_parameters
    grep = ExcelGrep.new(@keyword, @test_file)
    assert_equal @keyword, grep.keyword
    assert_equal @test_file, grep.file_path
  end

  def test_initialize_with_nil_keyword
    assert_raises(ArgumentError) do
      ExcelGrep.new(nil, @test_file)
    end
  end

  def test_initialize_with_empty_keyword
    assert_raises(ArgumentError) do
      ExcelGrep.new("", @test_file)
    end
  end

  def test_initialize_with_nil_file_path
    assert_raises(ArgumentError) do
      ExcelGrep.new(@keyword, nil)
    end
  end

  def test_initialize_with_empty_file_path
    assert_raises(ArgumentError) do
      ExcelGrep.new(@keyword, "")
    end
  end

  def test_validate_file_exists
    # 一時ファイルを作成してテスト
    temp_file = Tempfile.new(['test', '.xlsx'])
    begin
      grep = ExcelGrep.new(@keyword, temp_file.path)
      assert grep.validate_file(temp_file.path)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def test_validate_file_not_exists
    grep = ExcelGrep.new(@keyword, @missing_file)
    refute grep.validate_file(@missing_file)
  end

  def test_validate_file_with_nil
    grep = ExcelGrep.new(@keyword, @test_file)
    refute grep.validate_file(nil)
  end

  def test_validate_file_with_empty_string
    grep = ExcelGrep.new(@keyword, @test_file)
    refute grep.validate_file("")
  end

  def test_validate_file_extension_xlsx
    temp_file = Tempfile.new(['test', '.xlsx'])
    begin
      grep = ExcelGrep.new(@keyword, temp_file.path)
      assert grep.validate_file(temp_file.path)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def test_validate_file_extension_xls
    temp_file = Tempfile.new(['test', '.xls'])
    begin
      grep = ExcelGrep.new(@keyword, temp_file.path)
      assert grep.validate_file(temp_file.path)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def test_validate_file_extension_xlsm
    temp_file = Tempfile.new(['test', '.xlsm'])
    begin
      grep = ExcelGrep.new(@keyword, temp_file.path)
      assert grep.validate_file(temp_file.path)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def test_validate_file_wrong_extension
    temp_file = Tempfile.new(['test', '.txt'])
    begin
      grep = ExcelGrep.new(@keyword, temp_file.path)
      refute grep.validate_file(temp_file.path)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def test_keyword_accessor
    grep = ExcelGrep.new(@keyword, @test_file)
    assert_equal @keyword, grep.keyword
  end

  def test_file_path_accessor
    grep = ExcelGrep.new(@keyword, @test_file)
    assert_equal @test_file, grep.file_path
  end

  def test_search_method_exists
    grep = ExcelGrep.new(@keyword, @test_file)
    assert_respond_to grep, :search
  end

  def test_search_with_missing_file
    grep = ExcelGrep.new(@keyword, @missing_file)
    
    # 標準出力をキャプチャ
    output = capture_io do
      result = grep.search
      refute result
    end
    
    # エラーメッセージが出力されることを確認
    assert_match(/ファイルが見つかりません|File not found/, output[1])
  end

  def test_case_insensitive_keyword_handling
    grep_lower = ExcelGrep.new("test", @test_file)
    grep_upper = ExcelGrep.new("TEST", @test_file)
    
    assert_equal "test", grep_lower.keyword
    assert_equal "TEST", grep_upper.keyword
  end

  def test_file_path_with_spaces
    file_with_spaces = "test file with spaces.xlsx"
    grep = ExcelGrep.new(@keyword, file_with_spaces)
    assert_equal file_with_spaces, grep.file_path
  end

  def test_japanese_keyword
    japanese_keyword = "テスト"
    grep = ExcelGrep.new(japanese_keyword, @test_file)
    assert_equal japanese_keyword, grep.keyword
  end

  def test_validate_file_case_insensitive_extension
    # 大文字小文字を区別しない拡張子テスト
    temp_file = Tempfile.new(['test', '.XLSX'])
    begin
      grep = ExcelGrep.new(@keyword, temp_file.path)
      assert grep.validate_file(temp_file.path)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def test_validate_file_mixed_case_extension
    temp_file = Tempfile.new(['test', '.XlSx'])
    begin
      grep = ExcelGrep.new(@keyword, temp_file.path)
      assert grep.validate_file(temp_file.path)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  private

  def capture_io
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
    
    yield
    
    [$stdout.string, $stderr.string]
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end
end