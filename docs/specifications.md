# Excel Grep Tool

* 下記コマンドを実行することでExcel内の文字列を全文検索し、一覧する。
  * `xlg KEYWORD /path/to/file.xlsx` （単一ファイル）
  * `xlg KEYWORD file1.xlsx file2.xlsx file3.xlsx` （複数ファイル）
  * `xlg KEYWORD /path/to/directory/` （ディレクトリ内の全xlsxファイル）
* KEYWORDには通常の文字列または正規表現を指定できる。
* 検索結果は、grepのように標準出力に出力する。

```
file1.xlsx:シート1:A12:KEYWORD
file1.xlsx:シート1:B3:KEYWORD
file2.xlsx:シート2:D3:KEYWORD
...
```

## 機能詳細

### 単一ファイル検索
指定されたExcelファイル内を検索する。

### 複数ファイル検索
コマンドライン引数で指定された複数のExcelファイルを順次検索する。

### ディレクトリ検索
指定されたディレクトリ内の全ての `.xlsx`, `.xls`, `.xlsm` ファイルを検索する。
- サブディレクトリは再帰的に検索しない
- 隠しファイル（`.`で始まるファイル）は除外する

### 正規表現検索
キーワードとして正規表現を使用できる。
- Rubyの正規表現構文に対応
- 大文字小文字の区別を無視する場合は `/pattern/i` のような指定が可能
- 使用例:
  * `xlg "\d{4}-\d{2}-\d{2}" data.xlsx` （日付形式の検索）
  * `xlg "^[A-Z].*" data.xlsx` （大文字で始まる文字列）
  * `xlg "test|demo" data.xlsx` （testまたはdemoを含む文字列）

# 使用プログラミング言語

Rubyとする。

# 使用ライブラリ

rubyXLとする。
