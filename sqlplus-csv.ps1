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

WHENEVER SQLERROR EXIT SQL.SQLCODE

SPOOL $CsvFile

$SqlText

SPOOL OFF
EXIT
"@
}

function Invoke-OracleCsv {
    param(
        [string]$SqlFile,
        [string]$CsvFile,
        [string]$ConnectionString
    )
    $rawSql = Get-Content $SqlFile -Raw

    $tmpSql = New-SqlPlusScript -SqlFile $rawSql -CsvFile $CsvFile

    Set-Content "tmp.sql" $tmpSql

    & sqlplus -s $ConnectionString "@tmp.sql"
    
    if ($LASTEXITCODE -ne 0) {
        throw "SQL実行エラー: $LASTEXITCODE"
    }
}

Invoke-OracleCsv -SqlFile "test.sql" -CsvFile "test.csv"
