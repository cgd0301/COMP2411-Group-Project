# Roadmap 2.6 steps 12-13 on stage2/notes/seed_plan.xlsx through Excel COM:
# adds or refreshes the sql column of the 8 data tables and the note column of t_sub and t_refund
# (notes are only written into empty cells), and rebuilds the expected sheet.
# Never changes the input data. Run order after a full rebuild:
#   build_seed_plan.ps1 -> extend_seed_plan.ps1 -> export_seed_sql.ps1
# Close the workbook in Excel before running:
#   powershell -ExecutionPolicy Bypass -File stage2\scratch\extend_seed_plan.ps1

$ErrorActionPreference = 'Stop'

$book = (Resolve-Path (Join-Path $PSScriptRoot '..\notes\seed_plan.xlsx')).Path
$lock = Join-Path (Split-Path $book) '~$seed_plan.xlsx'
if (Test-Path $lock) { throw "seed_plan.xlsx is open in Excel. Save and close it, then run again." }

$GREY = 14277081

# Through COM, Excel rejects [@col] when the column name contains "_"; [@[col]] is accepted.
function Set-F($lo, [string]$col, [string]$formula) {
    $formula = $formula -replace '\[@([A-Za-z_][A-Za-z0-9_]*)\]', '[@[$1]]'
    try { $lo.ListColumns.Item($col).DataBodyRange.Formula = $formula }
    catch { throw "Excel rejected the formula for $($lo.Name)[$col]: $formula" }
}

function Get-Column($lo, [string]$name) {
    foreach ($lc in $lo.ListColumns) { if ($lc.Name -eq $name) { return $lc } }
    $lc = $lo.ListColumns.Add()
    $lc.Name = $name
    $h = $lc.Range.Cells.Item(1, 1)
    $h.Interior.Color = $GREY
    $h.Font.Color = 0
    $h.Font.Bold = $true
    return $lc
}

function Set-Notes($lo, [string]$idCol, $notes) {
    $lc = Get-Column $lo 'note'
    $ids = $lo.ListColumns.Item($idCol).DataBodyRange
    $cells = $lc.DataBodyRange
    for ($i = 1; $i -le $cells.Rows.Count; $i++) {
        $id = [int]$ids.Cells.Item($i, 1).Value2
        $cell = $cells.Cells.Item($i, 1)
        if ([string]::IsNullOrEmpty([string]$cell.Value2) -and $notes.ContainsKey($id)) { $cell.Value2 = $notes[$id] }
    }
}

# ---------------------------------------------------------------- sql tuples (no separators)
$sqlFormulas = @{
't_season' = @'
="("&[@season_id]&", '"&[@season_name]&"', "&[@year]&", '"&TEXT([@first_planning_day],"yyyy-mm-dd")&"')"
'@
't_product' = @'
="("&[@product_id]&", "&[@season_id]&", '"&SUBSTITUTE([@name],"'","''")&"', "&[@is_farmers_choice]&", "&TEXT([@price_per_kg],"0.00")&")"
'@
't_customer' = @'
="("&[@customer_id]&", '"&SUBSTITUTE([@name],"'","''")&"', '"&SUBSTITUTE([@email],"'","''")&"', '"&SUBSTITUTE([@street],"'","''")&"', '"&SUBSTITUTE([@building],"'","''")&"', '"&SUBSTITUTE([@room],"'","''")&"')"
'@
't_sub' = @'
="("&[@subscription_id]&", "&[@customer_id]&", "&[@season_id]&", '"&[@status]&"', '"&SUBSTITUTE([@plan_type],"'","''")&"', '"&[@frequency]&"', "&TEXT([@allocated_cost],"0.00")&", '"&TEXT([@submission_date],"yyyy-mm-dd")&"', "&IF([@cancellation_date]="","NULL","'"&TEXT([@cancellation_date],"yyyy-mm-dd")&"'")&", "&[@remaining_refundable_skip]&")"
'@
't_chosen' = @'
="("&[@subscription_id]&", "&[@product_id]&")"
'@
't_delivery' = @'
="("&[@subscription_id]&", "&[@week_no]&", '"&[@status]&"')"
'@
't_add_on' = @'
="("&[@subscription_id]&", "&[@week_no]&", "&[@product_id]&", "&TEXT([@weight],"0.00")&")"
'@
't_refund' = @'
="("&[@refund_id]&", "&[@subscription_id]&", "&TEXT([@amount],"0.00")&", '"&[@type]&"', '"&TEXT([@refund_date],"yyyy-mm-dd")&"', "&IF([@week_no]="","NULL",[@week_no])&")"
'@
}
$tableSheet = [ordered]@{
    't_season' = 'season'; 't_product' = 'product'; 't_customer' = 'customer'; 't_sub' = 'subscription'
    't_chosen' = 'chosen'; 't_delivery' = 'delivery'; 't_add_on' = 'add_on'; 't_refund' = 'refund'
}

# ---------------------------------------------------------------- provenance notes
$subNotes = @{
    101 = 'C01: new (D23); plain'
    102 = 'C06: new (D23); plain'
    103 = 'C08: new (D23); plain'
    104 = 'C10: new (D23); plain'
    201 = 'C01: renewal of 101; Easter skip; wk10 add-on'
    202 = 'C02: new; 2 add-ons, Easter skip, wk9 failed (coverage #2)'
    203 = 'C03: new; cancelled 2026-02-10 before the range (case A)'
    204 = 'C04: new; skips wk6 and wk7, cancelled 2026-04-14 (case B, refund 0, no refund row)'
    205 = 'C05: new; wk4 add-on, cancelled 2026-03-18 (case B, refund 526.00)'
    206 = 'C06: renewal of 102; wk3 add-on, Easter skip'
    207 = 'C07: new; wk2 add-on, Easter skip'
    208 = 'C08: renewal of 103; wk5 add-on'
    209 = 'C09: new; plain (coverage #3)'
    210 = 'C10: renewal of 104; plain'
    211 = 'C11: new; wk1 add-on, wk5 failed'
    301 = 'C01: renewal of 201; wk6 add-on (UC2 fixture)'
    302 = 'C02: renewal of 202; skips wk2 and wk4 (refunded) and wk5 (no refund), 0 refundable skips left'
    303 = 'C05: new, 205 was cancelled before this submission (D24); plain'
    304 = 'C08: renewal of 208; wk7 add-on (UC4 case B fixture)'
    305 = 'C10: renewal of 210; wk3 skip, 1 refundable skip left'
    306 = 'C12: new; cancelled 2026-06-15 on its wk3 delivery day (case B)'
    307 = 'C15: new; cancelled 2026-06-24 after renewing into 403 (case B)'
    401 = 'C01: renewal of 301'
    402 = 'C06: new, no Summer 2026 subscription'
    403 = 'C15: renewal of 307, kept after 307 was cancelled (D24, coverage #13)'
}
$refundNotes = @{
    1  = '203 case A: 6 x 200.00'
    2  = '205 case B: 2 x 200.00 + 126.00 add-on on wk4'
    3  = '211 wk5 failed: 240.00'
    4  = '201 Easter skip, 1st refundable skip'
    5  = '202 Easter skip, 1st refundable skip'
    6  = '204 Easter skip, 1st refundable skip'
    7  = '206 Easter skip, 1st refundable skip'
    8  = '207 Easter skip, 1st refundable skip'
    9  = '204 wk7 skip, 2nd refundable skip: 200.00 + 22.00 add-on'
    10 = '202 wk9 failed: 200.00 + 30.00 add-on'
    11 = '302 wk2 skip, 1st refundable skip'
    12 = '305 wk3 skip, 1st refundable skip'
    13 = '306 case B: 2 x 200.00'
    14 = '302 wk4 skip, 2nd refundable skip'
    15 = '307 case B: 2 x 200.00'
}

function Out-Range($rng) {
    $v = $rng.Value2
    for ($i = 1; $i -le $v.GetLength(0); $i++) {
        $cells = for ($j = 1; $j -le $v.GetLength(1); $j++) {
            $x = $v[$i, $j]
            if ($x -is [double]) { [math]::Round($x, 4).ToString() } else { "$x" }
        }
        Write-Output ('  ' + ($cells -join ' | '))
    }
}

$xl = $null; $wb = $null
try {
    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = $false
    $xl.DisplayAlerts = $false
    $xl.AutoCorrect.AutoFillFormulasInLists = $true
    $wb = $xl.Workbooks.Open($book)

    # Step 12: note and sql columns
    $tables = @{}
    foreach ($t in $tableSheet.Keys) { $tables[$t] = $wb.Worksheets.Item($tableSheet[$t]).ListObjects.Item($t) }
    Set-Notes $tables['t_sub'] 'subscription_id' $subNotes
    Set-Notes $tables['t_refund'] 'refund_id' $refundNotes
    foreach ($t in $tableSheet.Keys) {
        $lc = Get-Column $tables[$t] 'sql'
        Set-F $tables[$t] 'sql' $sqlFormulas[$t]
        $lc.Range.ColumnWidth = 70
    }

    # Step 13: expected sheet
    $ws = $wb.Worksheets.Item('expected')
    while ($ws.PivotTables().Count -gt 0) { [void]$ws.PivotTables(1).TableRange2.Clear() }
    [void]$ws.Cells.Clear()

    function Title([string]$addr, [string]$text) {
        $c = $ws.Range($addr)
        $c.Value2 = $text
        $c.Font.Bold = $true
    }
    function New-Pivot([string]$source, [string]$dest, [string]$name) {
        $pc = $wb.PivotCaches().Create(1, $source)
        $pt = $pc.CreatePivotTable($ws.Range($dest), $name)
        [void]$pt.RowAxisLayout(1)
        return $pt
    }
    function Add-Data($pt, [string]$field, [string]$caption, [int]$fn, [string]$fmt) {
        $df = $pt.AddDataField($pt.PivotFields($field), $caption, $fn)
        $df.NumberFormat = $fmt
    }
    $COUNT = -4112; $SUM = -4157

    Title 'A1' 'Expected results of Q01-Q05 on the seed baseline (start of 2026-07-07). Refresh pivot tables after any data change: Data > Refresh All.'

    # Q01 / MQ1
    Title 'A3' 'Q01 / MQ1: Spring 2026 per plan type (cancelled subscriptions included): subscriptions, fee, add-on income, refunds, net income'
    $q1 = New-Pivot 't_sub' 'A7' 'pt_q01'
    $f = $q1.PivotFields('label'); $f.Orientation = 3; $f.CurrentPage = 'spring 2026'
    $q1.PivotFields('plan_type').Orientation = 1
    Add-Data $q1 'subscription_id' 'subscriptions'    $COUNT '0'
    Add-Data $q1 'fee'             'sum_fee'          $SUM   '0.00'
    Add-Data $q1 'addon_income'    'sum_addon_income' $SUM   '0.00'
    Add-Data $q1 'refund_total'    'sum_refund_total' $SUM   '0.00'
    Add-Data $q1 'net'             'sum_net'          $SUM   '0.00'

    # Q02 / MQ2
    Title 'A15' 'Q02 / MQ2: Spring 2026 add-on income from successful deliveries, per plan type and product'
    $q2 = New-Pivot 't_add_on' 'A20' 'pt_q02'
    $f = $q2.PivotFields('label'); $f.Orientation = 3; $f.CurrentPage = 'spring 2026'
    $f = $q2.PivotFields('delivery_status'); $f.Orientation = 3; $f.CurrentPage = 'success'
    $q2.PivotFields('plan_type').Orientation = 1
    $q2.PivotFields('product_name').Orientation = 1
    Add-Data $q2 'fee'    'sum_fee'    $SUM '0.00'
    Add-Data $q2 'weight' 'sum_weight' $SUM '0.00'
    [void]$q2.PivotFields('product_name').AutoSort(2, 'sum_fee')

    # Q05 / MQ5
    Title 'A33' 'Q05 / MQ5: Spring 2026 subscriptions that were not cancelled, renewed into Summer 2026, per plan type'
    $q5 = New-Pivot 't_sub' 'A38' 'pt_q05'
    $f = $q5.PivotFields('label'); $f.Orientation = 3; $f.CurrentPage = 'spring 2026'
    $f = $q5.PivotFields('status'); $f.Orientation = 3; $f.CurrentPage = 'finished'
    $q5.PivotFields('plan_type').Orientation = 1
    Add-Data $q5 'subscription_id' 'subscriptions' $COUNT '0'
    Add-Data $q5 'renewed_next'    'renewed'       $SUM   '0'
    $ws.Range('E38').Value2 = 'plan_type'
    $ws.Range('F38').Value2 = 'renewal_rate'
    $ws.Range('E38:F38').Font.Bold = $true
    $ws.Range('E39').Value2 = "farmer's choice"
    $ws.Range('E40').Value2 = 'customizable'
    $ws.Range('F39:F40').Formula = '=GETPIVOTDATA("renewed",$A$38,"plan_type",E39)/GETPIVOTDATA("subscriptions",$A$38,"plan_type",E39)'
    $ws.Range('F39:F40').NumberFormat = '0.0000'

    # Q03 / MQ3
    Title 'J3' 'Q03 / MQ3: Spring 2026 deliveries per week (cancelled deliveries excluded)'
    $h = @('week_no', 'non_cancelled', 'skipped', 'failed', 'success', 'attempted', 'skip_rate', 'failure_rate')
    for ($j = 0; $j -lt $h.Count; $j++) { $ws.Cells.Item(5, 10 + $j).Value2 = $h[$j] }
    $ws.Range('J5:Q5').Font.Bold = $true
    $ws.Range('J6:J17').Formula = '=ROW()-ROW($J$5)'
    $ws.Range('K6:K17').Formula = '=COUNTIFS(t_delivery[season_id],2,t_delivery[week_no],$J6,t_delivery[status],"<>cancelled")'
    $ws.Range('L6:L17').Formula = '=COUNTIFS(t_delivery[season_id],2,t_delivery[week_no],$J6,t_delivery[status],"skipped")'
    $ws.Range('M6:M17').Formula = '=COUNTIFS(t_delivery[season_id],2,t_delivery[week_no],$J6,t_delivery[status],"failed")'
    $ws.Range('N6:N17').Formula = '=COUNTIFS(t_delivery[season_id],2,t_delivery[week_no],$J6,t_delivery[status],"success")'
    $ws.Range('O6:O17').Formula = '=M6+N6'
    $ws.Range('P6:P17').Formula = '=IF(K6=0,"NULL",L6/K6)'
    $ws.Range('Q6:Q17').Formula = '=IF(O6=0,"NULL",M6/O6)'
    $ws.Range('P6:Q17').NumberFormat = '0.0000'

    # Q04 / MQ4
    Title 'J21' 'Q04 / MQ4: Spring 2026 products chosen by customizable subscriptions (formula table, so unchosen products show 0)'
    $h = @('product_id', 'name', 'is_farmers_choice', 'chosen_count', 'pick_rate')
    for ($j = 0; $j -lt $h.Count; $j++) { $ws.Cells.Item(23, 10 + $j).Value2 = $h[$j] }
    $ws.Range('J23:N23').Font.Bold = $true
    $ws.Range('J24:J33').Formula = '=10+ROW()-ROW($J$23)'
    $ws.Range('K24:K33').Formula = '=INDEX(t_product[name],MATCH($J24,t_product[product_id],0))'
    $ws.Range('L24:L33').Formula = '=INDEX(t_product[is_farmers_choice],MATCH($J24,t_product[product_id],0))'
    $ws.Range('M24:M33').Formula = '=COUNTIFS(t_chosen[product_id],$J24)'
    $ws.Range('N24:N33').Formula = '=M24/$M$35'
    $ws.Range('N24:N33').NumberFormat = '0.0000'
    $ws.Range('J35').Value2 = 'customizable subscriptions in Spring 2026'
    $ws.Range('M35').Formula = '=COUNTIFS(t_sub[season_id],2,t_sub[plan_type],"customizable")'

    $xl.CalculateFull()
    foreach ($pt in @($q1, $q2, $q5)) { [void]$pt.RefreshTable() }
    $xl.CalculateFull()
    [void]$ws.Columns('A:Q').AutoFit()
    $ws.Columns('A').ColumnWidth = 24

    # ------------------------------------------------------------ report
    $wsSub = $wb.Worksheets.Item('subscription')
    $err = 0
    foreach ($t in $tableSheet.Keys) { $err += $wsSub.Evaluate("SUMPRODUCT(--ISERROR($t[sql]))") }
    Write-Output "sql cells with errors: $err"
    foreach ($t in $tableSheet.Keys) {
        $first = $tables[$t].ListColumns.Item('sql').DataBodyRange.Cells.Item(1, 1).Text
        Write-Output ("{0,-11} {1}" -f $t, $first)
    }
    Write-Output ("t_sub 403 sql: " + $wsSub.Evaluate('INDEX(t_sub[sql],MATCH(403,t_sub[subscription_id],0))').Value2)
    Write-Output ("t_sub 205 sql: " + $wsSub.Evaluate('INDEX(t_sub[sql],MATCH(205,t_sub[subscription_id],0))').Value2)
    Write-Output ("t_refund 1 sql: " + $wsSub.Evaluate('INDEX(t_refund[sql],1)').Value2)
    Write-Output ("checks all pass: " + $wb.Worksheets.Item('checks').Range('G2').Value2)
    Write-Output '--- Q01'; Out-Range $q1.TableRange1
    Write-Output '--- Q02'; Out-Range $q2.TableRange1
    Write-Output '--- Q05'; Out-Range $q5.TableRange1; Out-Range $ws.Range('E38:F40')
    Write-Output '--- Q03'; Out-Range $ws.Range('J5:Q17')
    Write-Output '--- Q04'; Out-Range $ws.Range('J23:N33'); Out-Range $ws.Range('J35:M35')

    $wb.Save()
}
finally {
    if ($wb) { $wb.Close($false); [void][Runtime.InteropServices.Marshal]::ReleaseComObject($wb) }
    if ($xl) { $xl.Quit(); [void][Runtime.InteropServices.Marshal]::ReleaseComObject($xl) }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
