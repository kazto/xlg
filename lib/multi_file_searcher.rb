require 'excel_grep'

class MultiFileSearcher
  attr_reader :pattern, :paths

  def initialize(pattern, paths)
    raise ArgumentError, "検索パターンが空です" if pattern.nil? || pattern.empty?
    raise ArgumentError, "パスが空です" if paths.nil? || paths.empty?
    
    @pattern = pattern
    @paths = paths
  end

  def search
    expanded_files = expand_paths(@paths)
    success_count = 0
    
    expanded_files.each do |file_path|
      begin
        grep = ExcelGrep.new(@pattern, file_path)
        if grep.search
          success_count += 1
        end
      rescue => e
        $stderr.puts "エラー: #{file_path} - #{e.message}"
      end
    end
    
    success_count > 0
  end

  def expand_paths(paths)
    expanded = []
    
    paths.each do |path|
      if File.directory?(path)
        expanded.concat(find_excel_files(path))
      else
        expanded << path
      end
    end
    
    expanded.uniq
  end

  def find_excel_files(directory)
    return [] unless File.exist?(directory) && File.directory?(directory)
    
    excel_files = []
    
    begin
      Dir.entries(directory).each do |entry|
        next if entry.start_with?('.')  # 隠しファイルとカレント/親ディレクトリを除外
        
        file_path = File.join(directory, entry)
        next if File.directory?(file_path)  # サブディレクトリを除外
        
        if entry.match?(/\.(xlsx?|xlsm)$/i)
          excel_files << file_path
        end
      end
    rescue => e
      $stderr.puts "ディレクトリ読み込みエラー: #{directory} - #{e.message}"
    end
    
    excel_files.sort
  end
end