<#
.SYNOPSIS
    sql文を実行してcsvを生成する
.DESCRIPTION
    PowerShellからsqlを実行してcsvを生成するためのsqlplusのラッパーです
.PARAMETER ConnectionString
    DBの接続文字列
.PARAMETER SqlFile
    sqlファイルのパス
.PARAMETER CsvFile
    出力するcsvファイルのパス
.EXAMPLE
    Invoke-OracleCsv `
    -ConnectionString "scott/tiger@localhost:1521/orclpdb" `
    -SqlFile "test.sql" `
    -CsvFile "test.csv"
.NOTES

#>


function New-SqlPlusScript {
    param(
        [string]$SqlText,
        [string]$CsvFile
    )
    @"
SET PAGESIZE 0
SET LINESIZE 32767
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING ON
SET UNDERLINE OFF
SET TRIMSPOOL ON
SET COLSEP '|'
SET DEFINE OFF

WHENEVER SQLERROR EXIT SQL.SQLCODE

SPOOL $CsvFile

$SqlText

SPOOL OFF
EXIT
"@
}

function Invoke-OracleCsv {
    param(
        [string]$ConnectionString
        [string]$SqlFile,
        [string]$CsvFile,
    )
    $rawSql = Get-Content $SqlFile -Raw

    $tmpSql = New-SqlPlusScript -SqlFile $rawSql -CsvFile $CsvFile

    Set-Content "tmp.sql" $tmpSql

    & sqlplus -s $ConnectionString "@tmp.sql"
    
    if ($LASTEXITCODE -ne 0) {
        throw "SQL実行エラー: $LASTEXITCODE"
    }
}

# Invoke-OracleCsv -SqlFile "test.sql" -CsvFile "test.csv"
