# xlg - Excel Grep Tool

`xlg` is a command-line tool that provides functionality to search keywords in Excel files in various formats. It works like `grep` but for Excel files, outputting results in a grep-like format showing file, sheet, cell reference, and matched content.

## Features

- Search text in Excel files (.xlsx, .xls, .xlsm)
- **Regular expression support** for advanced pattern matching
- Support for single file, multiple files, and directory-based searches
- Case-insensitive keyword matching
- Grep-like output format: `filename:sheet:cell_ref:matched_text`
- Automatic Excel file discovery in directories
- Comprehensive error handling and validation

## Installation

Build and install the gem:

```bash
gem build gemspec
gem install xlg-0.4.2.gem
```

Or install directly from the built gem files:

```bash
gem install xlg-0.4.2.gem
```

## Usage

### Basic Usage

```bash
# Search in a single Excel file
xlg 'keyword' sample.xlsx

# Search in multiple Excel files
xlg 'keyword' file1.xlsx file2.xlsx

# Search all Excel files in a directory
xlg 'keyword' /path/to/directory/
```

### Regular Expression Support

`xlg` supports Ruby-style regular expressions for advanced pattern matching:

```bash
# Search for date patterns (YYYY-MM-DD format)
xlg '\d{4}-\d{2}-\d{2}' data.xlsx

# Search for email addresses
xlg '[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+' contacts.xlsx

# Search for strings starting with capital letters
xlg '^[A-Z].*' documents.xlsx

# Search for "test" OR "demo"
xlg 'test|demo' samples.xlsx

# Case-insensitive regex using flags
xlg '/hello/i' greetings.xlsx

# Search for phone numbers
xlg '\d{3}-\d{3}-\d{4}' phonebook.xlsx
```

### Command Line Options

```
xlg PATTERN FILE.xlsx                    # Single file search
xlg PATTERN FILE1.xlsx FILE2.xlsx       # Multiple file search
xlg PATTERN /path/to/directory/          # Directory search

Options:
  -h, --help  Show help message
```

Where `PATTERN` can be:
- A simple text string (e.g., `'hello'`)
- A regular expression (e.g., `'\d+'` for numbers)
- A regex with flags (e.g., `'/pattern/i'` for case-insensitive)

### Examples

#### Text Search
```bash
# Search for "test" in sample.xlsx
xlg 'test' sample.xlsx

# Search for "データ" in multiple files
xlg 'データ' file1.xlsx file2.xlsx

# Search for "keyword" in all Excel files in documents folder
xlg 'キーワード' /home/user/documents/
```

#### Regular Expression Search
```bash
# Find all dates in YYYY-MM-DD format
xlg '\d{4}-\d{2}-\d{2}' reports.xlsx

# Find email addresses
xlg '\w+@\w+\.\w+' contacts.xlsx

# Find cells starting with "Total"
xlg '^Total' financial.xlsx

# Find prices in dollar format
xlg '\$\d+\.\d{2}' prices.xlsx

# Case-insensitive search
xlg '/error/i' logs.xlsx
```

## Output Format

The output follows a grep-like format:

```
filename.xlsx:SheetName:A1:matched content
filename.xlsx:SheetName:B5:another match
```

Where:
- `filename.xlsx`: The Excel file name
- `SheetName`: The worksheet name
- `A1`: Cell reference (Excel format)
- `matched content`: The actual cell content that contains the keyword

## Supported File Formats

- `.xlsx` (Excel 2007 and later)
- `.xls` (Excel 97-2003)
- `.xlsm` (Excel with macros)

## Requirements

- Ruby >= 3.0
- rubyXL gem (~> 3.4) - automatically installed as dependency

## Architecture

The tool consists of four main components:

- `ExcelGrep` (lib/excel_grep.rb): Core search functionality for single files
- `MultiFileSearcher` (lib/multi_file_searcher.rb): Handles multiple files and directories
- `CellMatcher` (lib/cell_matcher.rb): Performs text and regular expression matching
- `OutputFormatter` (lib/output_formatter.rb): Formats output in grep-like style

## Development

### Running Tests

```bash
# Run individual test files
RUBYLIB=lib bundle exec ruby test/test_cell_matcher.rb
RUBYLIB=lib bundle exec ruby test/test_regex_integration.rb
RUBYLIB=lib bundle exec ruby test/test_edge_cases.rb

# Or run all tests
RUBYLIB=lib bundle exec ruby test/test_*.rb
```

### Project Structure

```
├── lib/
│   ├── excel_grep.rb          # Main Excel search engine
│   ├── multi_file_searcher.rb # Multi-file search coordination
│   ├── cell_matcher.rb        # Text matching logic
│   └── output_formatter.rb    # Output formatting
├── bin/
│   └── xlg                    # Command-line executable
├── test/                      # Unit tests
├── docs/                      # Documentation
└── gemspec                    # Gem specification
```

## License

MIT License - see LICENSE file for details.

## Author

Kazto TAKAHASHI (kazto@kazto.dev)

## Repository

https://github.com/kazto/xlg
