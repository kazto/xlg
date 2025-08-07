# Excel Grep Tool

* 下記コマンドを実行することでExcel内の文字列を全文検索し、一覧する。
  * `xlg KEYWORD /path/to/file.xlsx` （単一ファイル）
  * `xlg KEYWORD file1.xlsx file2.xlsx file3.xlsx` （複数ファイル）
  * `xlg KEYWORD /path/to/directory/` （ディレクトリ内の全xlsxファイル）
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

# 使用プログラミング言語

Rubyとする。

# 使用ライブラリ

rubyXLとする。
