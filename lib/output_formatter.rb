class OutputFormatter
  def format(file_name, sheet_name, cell_ref, match_text)
    "#{file_name}:#{sheet_name}:#{cell_ref}:#{match_text}"
  end
end