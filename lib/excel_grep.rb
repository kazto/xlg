require 'rubyXL'
require 'cell_matcher'
require 'output_formatter'

class ExcelGrep
  attr_reader :pattern, :file_path

  def initialize(pattern, file_path)
    raise ArgumentError, "検索パターンが空です" if pattern.nil? || pattern.empty?
    raise ArgumentError, "ファイルパスが空です" if file_path.nil? || file_path.empty?
    
    @pattern = pattern
    @file_path = file_path
    @matcher = CellMatcher.new(pattern)
    @formatter = OutputFormatter.new
  end

  def validate_file(file_path)
    return false if file_path.nil? || file_path.empty?
    return false unless File.exist?(file_path)
    return false unless file_path.match?(/\.(xlsx?|xlsm)$/i)
    
    true
  end

  def search
    unless validate_file(@file_path)
      $stderr.puts "エラー: ファイルが見つかりません、またはExcelファイルではありません: #{@file_path}"
      return false
    end

    begin
      workbook = RubyXL::Parser.parse(@file_path)
      file_name = File.basename(@file_path)
      
      workbook.worksheets.each do |worksheet|
        next if worksheet.nil?
        
        sheet_name = worksheet.sheet_name || "Sheet#{worksheet.index + 1}"
        
        worksheet.each_with_index do |row, row_index|
          next if row.nil?
          
          row.cells.each_with_index do |cell, col_index|
            next if cell.nil? || cell.value.nil?
            
            cell_value = cell.value.to_s
            if @matcher.match?(cell_value)
              cell_ref = RubyXL::Reference.ind2ref(row_index, col_index)
              match_text = @matcher.extract_match(cell_value) || cell_value
              puts @formatter.format(file_name, sheet_name, cell_ref, match_text)
            end
          end
        end
      end
      
      true
    rescue => e
      $stderr.puts "エラー: Excelファイルの読み込みに失敗しました: #{e.message}"
      false
    end
  end
end