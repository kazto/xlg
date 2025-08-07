require 'minitest/autorun'
require 'tempfile'
require 'fileutils'
require_relative '../lib/multi_file_searcher'

class TestMultiFileSearcher < Minitest::Test
  def setup
    @keyword = "test"
    @temp_dir = Dir.mktmpdir
    @test_files = []
    
    # テスト用ファイルを作成
    @xlsx_file1 = File.join(@temp_dir, "file1.xlsx")
    @xlsx_file2 = File.join(@temp_dir, "file2.xlsx")
    @xls_file = File.join(@temp_dir, "file3.xls")
    @xlsm_file = File.join(@temp_dir, "file4.xlsm")
    @txt_file = File.join(@temp_dir, "file5.txt")
    @hidden_file = File.join(@temp_dir, ".hidden.xlsx")
    
    [@xlsx_file1, @xlsx_file2, @xls_file, @xlsm_file, @txt_file, @hidden_file].each do |file|
      FileUtils.touch(file)
    end
    
    # サブディレクトリとファイルも作成
    @sub_dir = File.join(@temp_dir, "subdir")
    Dir.mkdir(@sub_dir)
    FileUtils.touch(File.join(@sub_dir, "sub.xlsx"))
  end

  def teardown
    FileUtils.rm_rf(@temp_dir) if @temp_dir
  end

  def test_initialize_with_valid_parameters
    paths = [@xlsx_file1, @xlsx_file2]
    searcher = MultiFileSearcher.new(@keyword, paths)
    assert_equal @keyword, searcher.keyword
    assert_equal paths, searcher.paths
  end

  def test_initialize_with_nil_keyword
    assert_raises(ArgumentError) do
      MultiFileSearcher.new(nil, [@xlsx_file1])
    end
  end

  def test_initialize_with_empty_keyword
    assert_raises(ArgumentError) do
      MultiFileSearcher.new("", [@xlsx_file1])
    end
  end

  def test_initialize_with_nil_paths
    assert_raises(ArgumentError) do
      MultiFileSearcher.new(@keyword, nil)
    end
  end

  def test_initialize_with_empty_paths
    assert_raises(ArgumentError) do
      MultiFileSearcher.new(@keyword, [])
    end
  end

  def test_find_excel_files_in_directory
    searcher = MultiFileSearcher.new(@keyword, [@temp_dir])
    excel_files = searcher.find_excel_files(@temp_dir)
    
    # 期待されるファイル（隠しファイルとサブディレクトリのファイルは除外）
    expected_files = [@xlsx_file1, @xlsx_file2, @xls_file, @xlsm_file].sort
    assert_equal expected_files, excel_files.sort
  end

  def test_find_excel_files_excludes_hidden_files
    searcher = MultiFileSearcher.new(@keyword, [@temp_dir])
    excel_files = searcher.find_excel_files(@temp_dir)
    
    refute_includes excel_files, @hidden_file
  end

  def test_find_excel_files_excludes_non_excel_files
    searcher = MultiFileSearcher.new(@keyword, [@temp_dir])
    excel_files = searcher.find_excel_files(@temp_dir)
    
    refute_includes excel_files, @txt_file
  end

  def test_find_excel_files_excludes_subdirectories
    searcher = MultiFileSearcher.new(@keyword, [@temp_dir])
    excel_files = searcher.find_excel_files(@temp_dir)
    
    sub_excel_file = File.join(@sub_dir, "sub.xlsx")
    refute_includes excel_files, sub_excel_file
  end

  def test_find_excel_files_with_nonexistent_directory
    searcher = MultiFileSearcher.new(@keyword, [@temp_dir])
    excel_files = searcher.find_excel_files("/nonexistent/directory")
    
    assert_empty excel_files
  end

  def test_expand_paths_with_files
    file_paths = [@xlsx_file1, @xlsx_file2]
    searcher = MultiFileSearcher.new(@keyword, file_paths)
    expanded = searcher.expand_paths(file_paths)
    
    assert_equal file_paths.sort, expanded.sort
  end

  def test_expand_paths_with_directory
    searcher = MultiFileSearcher.new(@keyword, [@temp_dir])
    expanded = searcher.expand_paths([@temp_dir])
    
    expected_files = [@xlsx_file1, @xlsx_file2, @xls_file, @xlsm_file].sort
    assert_equal expected_files, expanded.sort
  end

  def test_expand_paths_with_mixed_files_and_directories
    mixed_paths = [@xlsx_file1, @temp_dir]
    searcher = MultiFileSearcher.new(@keyword, mixed_paths)
    expanded = searcher.expand_paths(mixed_paths)
    
    # @xlsx_file1 + ディレクトリ内のExcelファイル
    expected_files = [@xlsx_file1, @xlsx_file2, @xls_file, @xlsm_file].sort
    assert_equal expected_files, expanded.sort
  end

  def test_expand_paths_removes_duplicates
    # 同じファイルを複数回指定
    paths = [@xlsx_file1, @xlsx_file1, @xlsx_file2]
    searcher = MultiFileSearcher.new(@keyword, paths)
    expanded = searcher.expand_paths(paths)
    
    expected_files = [@xlsx_file1, @xlsx_file2].sort
    assert_equal expected_files, expanded.sort
  end

  def test_expand_paths_with_nonexistent_file
    nonexistent_file = File.join(@temp_dir, "nonexistent.xlsx")
    paths = [@xlsx_file1, nonexistent_file]
    searcher = MultiFileSearcher.new(@keyword, paths)
    expanded = searcher.expand_paths(paths)
    
    # 存在しないファイルも含まれる（実際の検索時にエラーハンドリング）
    assert_includes expanded, nonexistent_file
    assert_includes expanded, @xlsx_file1
  end

  def test_search_method_exists
    searcher = MultiFileSearcher.new(@keyword, [@xlsx_file1])
    assert_respond_to searcher, :search
  end

  def test_keyword_accessor
    searcher = MultiFileSearcher.new(@keyword, [@xlsx_file1])
    assert_equal @keyword, searcher.keyword
  end

  def test_paths_accessor
    paths = [@xlsx_file1, @xlsx_file2]
    searcher = MultiFileSearcher.new(@keyword, paths)
    assert_equal paths, searcher.paths
  end

  def test_supported_excel_extensions
    searcher = MultiFileSearcher.new(@keyword, [@temp_dir])
    
    # 内部メソッドをテストするため、テスト用のメソッドを想定
    assert searcher.respond_to?(:find_excel_files)
    
    # 実際にサポートされている拡張子を確認
    excel_files = searcher.find_excel_files(@temp_dir)
    
    # .xlsx, .xls, .xlsm ファイルが含まれている
    assert excel_files.any? { |f| f.end_with?('.xlsx') }
    assert excel_files.any? { |f| f.end_with?('.xls') }
    assert excel_files.any? { |f| f.end_with?('.xlsm') }
  end
end