# Builds roadmap 2.6 steps 3-11 into stage2/notes/seed_plan.xlsx through Excel COM.
# Rebuilds only the sheets product, customer, subscription, chosen, delivery_exc, delivery,
# add_on, refund and checks; season, week and expected keep their content.
# Close the workbook in Excel before running:
#   powershell -ExecutionPolicy Bypass -File stage2\scratch\build_seed_plan.ps1

$ErrorActionPreference = 'Stop'

$book   = (Resolve-Path (Join-Path $PSScriptRoot '..\notes\seed_plan.xlsx')).Path
$lock   = Join-Path (Split-Path $book) '~$seed_plan.xlsx'
$backup = Join-Path $PSScriptRoot 'seed_plan_before_build.xlsx'

if (Test-Path $lock) { throw "seed_plan.xlsx is open in Excel. Save and close it, then run again." }
if (-not (Test-Path $backup)) { Copy-Item $book $backup }

$BLUE = 16247773   # RGB(221,235,247): columns that go into the database
$GREY = 14277081   # RGB(217,217,217): helper columns
$BAD_FILL = 13551615
$BAD_FONT = 393372

function D([string]$s) { [datetime]::ParseExact($s, 'yyyy-MM-dd', $null).ToOADate() }

function Clear-Sheet($ws) {
    while ($ws.ListObjects.Count -gt 0) { $ws.ListObjects.Item(1).Delete() }
    try { [void]$ws.Cells.FormatConditions.Delete() } catch {}
    try { [void]$ws.Cells.Validation.Delete() } catch {}
    [void]$ws.Cells.Clear()
}

function New-Table($ws, [string]$name, [string[]]$headers, [object[]]$rows, [int]$nSchema) {
    $r = $rows.Count
    $c = $headers.Count
    $arr = New-Object 'object[,]' ($r + 1), $c
    for ($j = 0; $j -lt $c; $j++) { $arr[0, $j] = $headers[$j] }
    for ($i = 0; $i -lt $r; $i++) {
        $row = $rows[$i]
        for ($j = 0; $j -lt $row.Count; $j++) {
            $v = $row[$j]
            if ($null -ne $v) { $v = $v.PSObject.BaseObject }   # COM cannot marshal PSObject wrappers
            $arr[($i + 1), $j] = $v
        }
    }
    $range = $ws.Range($ws.Cells.Item(1, 1), $ws.Cells.Item($r + 1, $c))
    $range.Value2 = $arr
    $lo = $ws.ListObjects.Add(1, $range, [Type]::Missing, 1)
    $lo.Name = $name
    for ($j = 1; $j -le $c; $j++) {
        $cell = $lo.HeaderRowRange.Cells.Item(1, $j)
        $cell.Interior.Color = $(if ($j -le $nSchema) { $BLUE } else { $GREY })
        $cell.Font.Color = 0
        $cell.Font.Bold = $true
    }
    return $lo
}

# Through COM, Excel rejects [@col] when the column name contains "_"; [@[col]] is accepted.
function Set-F($lo, [string]$col, [string]$formula) {
    $formula = $formula -replace '\[@([A-Za-z_][A-Za-z0-9_]*)\]', '[@[$1]]'
    try { $lo.ListColumns.Item($col).DataBodyRange.Formula = $formula }
    catch { throw "Excel rejected the formula for $($lo.Name)[$col]: $formula" }
}

function Set-Fmt($lo, [string[]]$cols, [string]$fmt) {
    foreach ($col in $cols) { $lo.ListColumns.Item($col).DataBodyRange.NumberFormat = $fmt }
}

function Set-List($lo, [string]$col, [string]$list) {
    $rng = $lo.ListColumns.Item($col).DataBodyRange
    try { [void]$rng.Validation.Delete() } catch {}
    [void]$rng.Validation.Add(3, 1, 1, $list)
}

$DATE  = 'yyyy-mm-dd'
$DATE0 = 'yyyy-mm-dd;;'   # hides 0, which INDEX returns for a blank date
$MONEY = '0.00'
$FC    = "farmer's choice"
$CZ    = 'customizable'

# ---------------------------------------------------------------- data
$autumn = @(
    @('Cabbage', 18, 1), @('Cauliflower', 26, 1), @('Pumpkin', 14, 1), @('Sweet Potatoes', 18, 1),
    @('White Radish', 12, 1), @('Napa Cabbage', 16, 1), @('Kale', 35, 0), @('Leeks', 32, 0),
    @('Taro', 25, 0), @('Winter Melon', 15, 0))
$spring = @(
    @('Spinach', 32, 1), @('Lettuce', 22, 1), @('Pak Choi', 20, 1), @('Chinese Kale', 28, 1),
    @('Choy Sum', 35, 1), @('Broccoli', 30, 1), @('Carrots', 15, 0), @('Snow Peas', 48, 0),
    @('Asparagus', 58, 0), @('Strawberries', 85, 0))
$summer = @(
    @('Tomatoes', 25, 1), @('Cucumbers', 18, 1), @('Eggplants', 22, 1), @('Green Beans', 32, 1),
    @('Bell Peppers', 38, 1), @('Sweet Corn', 25, 1), @('Watermelon', 12, 0), @('Hairy Gourd', 16, 0),
    @('Okra', 42, 0), @('Bitter Melon', 28, 0))
$catalog = @{ 1 = $autumn; 2 = $spring; 3 = $summer; 4 = $autumn }

$productRows = @()
foreach ($s in 1..4) {
    for ($i = 0; $i -lt 10; $i++) {
        $p = $catalog[$s][$i]
        $productRows += , @((($s - 1) * 10 + $i + 1), $s, $p[0], $p[2], $p[1])
    }
}

$customerRows = @(
    @(1,  'Alex Chan',    'alex.chan@example.com',    '12 Greenfield Road',       'Greenfield Court Block A', '12A',     'C01'),
    @(2,  'Bella Wong',   'bella.wong@example.com',   '8 Lotus Pond Street',      'Lotus Mansion',            '3B',      'C02'),
    @(3,  'Calvin Lee',   'calvin.lee@example.com',   '33 Harbour Breeze Avenue', 'Breeze Tower',             '1805',    'C03'),
    @(4,  'Daisy Lam',    'daisy.lam@example.com',    '5 Maple Lane',             'Maple House',              '7C',      'C04'),
    @(5,  'Ethan Ho',     'ethan.ho@example.com',     '21 Orchard Path',          'Orchard Villa',            'House 4', 'C05'),
    @(6,  'Fiona Cheung', 'fiona.cheung@example.com', '16 Bamboo Grove Road',     'Grove Garden Block 2',     '9F',      'C06'),
    @(7,  'Gary Ng',      'gary.ng@example.com',      '9 Willow Terrace',         'Willow Court',             '2A',      'C07'),
    @(8,  'Helen Lau',    'helen.lau@example.com',    '40 Sunrise Crescent',      'Sunrise Plaza Tower 1',    '22D',     'C08'),
    @(9,  'Ivan Tse',     'ivan.tse@example.com',     '2 Riverbank Street',       'Riverside Mansion',        '5E',      'C09'),
    @(10, 'Jenny Yip',    'jenny.yip@example.com',    '27 Jade Garden Road',      'Jade Garden Block C',      '15B',     'C10'),
    @(11, 'Kelvin Mak',   'kelvin.mak@example.com',   '14 Peach Blossom Lane',    'Blossom Court',            '6A',      'C11'),
    @(12, 'Lily Kwok',    'lily.kwok@example.com',    '7 Cloud Valley Road',      'Cloud View Tower',         '31G',     'C12'),
    @(13, 'Marco Siu',    'marco.siu@example.com',    '19 Pine Hill Drive',       'Pine Hill Garden',         '8H',      'C13'),
    @(14, 'Nancy Fung',   'nancy.fung@example.com',   '3 Starlight Street',       'Starlight Building',       '11F',     'C14'),
    @(15, 'Oscar Poon',   'oscar.poon@example.com',   '11 Meadow View Road',      'Meadow Lodge',             'House 2', 'C15'))

# subscription_id, customer_id, season_id, status, plan_type, frequency, allocated_cost,
# submission_date, cancellation_date, remaining_refundable_skip
$subRows = @(
    @(101, 1,  1, 'finished',  $FC, 'weekly',   200, (D '2025-07-10'), $null, 2),
    @(102, 6,  1, 'finished',  $CZ, 'weekly',   240, (D '2025-07-18'), $null, 2),
    @(103, 8,  1, 'finished',  $FC, 'biweekly', 200, (D '2025-08-02'), $null, 2),
    @(104, 10, 1, 'finished',  $CZ, 'biweekly', 240, (D '2025-08-15'), $null, 2),
    @(201, 1,  2, 'finished',  $FC, 'weekly',   160, (D '2025-12-10'), $null, 1),
    @(202, 2,  2, 'finished',  $FC, 'weekly',   200, (D '2026-01-05'), $null, 1),
    @(203, 3,  2, 'cancelled', $FC, 'biweekly', 200, (D '2026-01-20'), (D '2026-02-10'), 0),
    @(204, 4,  2, 'cancelled', $FC, 'weekly',   200, (D '2026-01-12'), (D '2026-04-14'), 0),
    @(205, 5,  2, 'cancelled', $FC, 'weekly',   200, (D '2026-01-15'), (D '2026-03-18'), 0),
    @(206, 6,  2, 'finished',  $CZ, 'weekly',   192, (D '2025-12-20'), $null, 1),
    @(207, 7,  2, 'finished',  $CZ, 'weekly',   240, (D '2026-02-01'), $null, 1),
    @(208, 8,  2, 'finished',  $FC, 'biweekly', 160, (D '2025-12-15'), $null, 2),
    @(209, 9,  2, 'finished',  $FC, 'biweekly', 200, (D '2026-02-05'), $null, 2),
    @(210, 10, 2, 'finished',  $CZ, 'biweekly', 192, (D '2026-01-08'), $null, 2),
    @(211, 11, 2, 'finished',  $CZ, 'biweekly', 240, (D '2026-02-10'), $null, 2),
    @(301, 1,  3, 'active',    $FC, 'weekly',   160, (D '2026-04-20'), $null, 2),
    @(302, 2,  3, 'active',    $FC, 'weekly',   160, (D '2026-05-01'), $null, 0),
    @(303, 5,  3, 'active',    $FC, 'weekly',   200, (D '2026-04-10'), $null, 2),
    @(304, 8,  3, 'active',    $FC, 'biweekly', 160, (D '2026-04-15'), $null, 2),
    @(305, 10, 3, 'active',    $CZ, 'biweekly', 192, (D '2026-04-28'), $null, 1),
    @(306, 12, 3, 'cancelled', $FC, 'biweekly', 200, (D '2026-04-25'), (D '2026-06-15'), 0),
    @(307, 15, 3, 'cancelled', $FC, 'weekly',   200, (D '2026-03-20'), (D '2026-06-24'), 0),
    @(401, 1,  4, 'planned',   $FC, 'weekly',   160, (D '2026-06-15'), $null, 2),
    @(402, 6,  4, 'planned',   $CZ, 'weekly',   240, (D '2026-06-20'), $null, 2),
    @(403, 15, 4, 'planned',   $FC, 'weekly',   160, (D '2026-06-05'), $null, 2))

# customizable subscription, its season, the 2 products it does not choose
$excluded = @(
    @(102, 1, 'Pumpkin', 'Winter Melon'), @(104, 1, 'Pumpkin', 'Winter Melon'),
    @(206, 2, 'Pak Choi', 'Carrots'),     @(207, 2, 'Pak Choi', 'Lettuce'),
    @(210, 2, 'Pak Choi', 'Carrots'),     @(211, 2, 'Pak Choi', 'Snow Peas'),
    @(305, 3, 'Watermelon', 'Okra'),      @(402, 4, 'White Radish', 'Taro'))
$chosenRows = @()
foreach ($e in $excluded) {
    for ($i = 0; $i -lt 10; $i++) {
        $name = $catalog[$e[1]][$i][0]
        if ($name -ne $e[2] -and $name -ne $e[3]) { $chosenRows += , @($e[0], (($e[1] - 1) * 10 + $i + 1)) }
    }
}

$excRows = @(
    @(201, 6, 'skipped'), @(202, 6, 'skipped'), @(202, 9, 'failed'), @(204, 6, 'skipped'),
    @(204, 7, 'skipped'), @(206, 6, 'skipped'), @(207, 6, 'skipped'), @(211, 5, 'failed'),
    @(302, 2, 'skipped'), @(302, 4, 'skipped'), @(302, 5, 'skipped'), @(305, 3, 'skipped'))

$weekly   = @(101, 102, 201, 202, 204, 205, 206, 207, 301, 302, 303, 307)
$biweekly = @(103, 104, 208, 209, 210, 211, 304, 305, 306)
$deliveryRows = @()
foreach ($sub in (($weekly + $biweekly) | Sort-Object)) {
    $weeks = $(if ($weekly -contains $sub) { 1..12 } else { @(1, 3, 5, 7, 9, 11) })
    foreach ($w in $weeks) { $deliveryRows += , @($sub, $w) }
}

# subscription_id, week_no, product_id (formula), weight, product_name
$addOnRows = @(
    @(201, 10, $null, 1.0, 'Choy Sum'),     @(202, 3, $null, 1.5, 'Spinach'),
    @(202, 9,  $null, 1.0, 'Broccoli'),     @(204, 7, $null, 1.0, 'Lettuce'),
    @(205, 4,  $null, 4.5, 'Chinese Kale'), @(206, 3, $null, 1.0, 'Asparagus'),
    @(207, 2,  $null, 1.0, 'Strawberries'), @(208, 5, $null, 2.0, 'Spinach'),
    @(211, 1,  $null, 0.5, 'Strawberries'), @(301, 6, $null, 1.5, 'Green Beans'),
    @(304, 7,  $null, 2.0, 'Tomatoes'))

# refund_id, subscription_id, amount, type, refund_date, week_no
$refundRows = @(
    @(1,  203, 1200, 'cancelled', (D '2026-02-10'), $null),
    @(2,  205, 526,  'cancelled', (D '2026-03-18'), $null),
    @(3,  211, 240,  'failed',    (D '2026-03-31'), 5),
    @(4,  201, 160,  'skipped',   (D '2026-04-01'), 6),
    @(5,  202, 200,  'skipped',   (D '2026-04-01'), 6),
    @(6,  204, 200,  'skipped',   (D '2026-04-02'), 6),
    @(7,  206, 192,  'skipped',   (D '2026-04-02'), 6),
    @(8,  207, 240,  'skipped',   (D '2026-04-03'), 6),
    @(9,  204, 222,  'skipped',   (D '2026-04-09'), 7),
    @(10, 202, 230,  'failed',    (D '2026-04-28'), 9),
    @(11, 302, 160,  'skipped',   (D '2026-06-03'), 2),
    @(12, 305, 192,  'skipped',   (D '2026-06-10'), 3),
    @(13, 306, 400,  'cancelled', (D '2026-06-15'), $null),
    @(14, 302, 160,  'skipped',   (D '2026-06-17'), 4),
    @(15, 307, 400,  'cancelled', (D '2026-06-24'), $null))

# ---------------------------------------------------------------- checks
$checks = @(
    @('R01', 'season has 4 rows',                 'row count', '=ROWS(t_season)=4'),
    @('R02', 'week has 48 rows',                  'row count', '=ROWS(t_week)=48'),
    @('R03', 'product has 40 rows',               'row count', '=ROWS(t_product)=40'),
    @('R04', 'customer has 15 rows',              'row count', '=ROWS(t_customer)=15'),
    @('R05', 'subscription has 25 rows',          'row count', '=ROWS(t_sub)=25'),
    @('R06', 'chosen_products has 64 rows',       'row count', '=ROWS(t_chosen)=64'),
    @('R07', 'delivery_exc has 12 rows',          'row count', '=ROWS(t_exc)=12'),
    @('R08', 'delivery has 198 rows',             'row count', '=ROWS(t_delivery)=198'),
    @('R09', 'add_on has 11 rows',                'row count', '=ROWS(t_add_on)=11'),
    @('R10', 'refund has 15 rows',                'row count', '=ROWS(t_refund)=15'),
    @('E01', 'no formula errors in t_season',     'formula errors', '=SUMPRODUCT(--ISERROR(t_season))=0'),
    @('E02', 'no formula errors in t_week',       'formula errors', '=SUMPRODUCT(--ISERROR(t_week))=0'),
    @('E03', 'no formula errors in t_product',    'formula errors', '=SUMPRODUCT(--ISERROR(t_product))=0'),
    @('E04', 'no formula errors in t_customer',   'formula errors', '=SUMPRODUCT(--ISERROR(t_customer))=0'),
    @('E05', 'no formula errors in t_sub',        'formula errors', '=SUMPRODUCT(--ISERROR(t_sub))=0'),
    @('E06', 'no formula errors in t_chosen',     'formula errors', '=SUMPRODUCT(--ISERROR(t_chosen))=0'),
    @('E07', 'no formula errors in t_exc',        'formula errors', '=SUMPRODUCT(--ISERROR(t_exc))=0'),
    @('E08', 'no formula errors in t_delivery',   'formula errors', '=SUMPRODUCT(--ISERROR(t_delivery))=0'),
    @('E09', 'no formula errors in t_add_on',     'formula errors', '=SUMPRODUCT(--ISERROR(t_add_on))=0'),
    @('E10', 'no formula errors in t_refund',     'formula errors', '=SUMPRODUCT(--ISERROR(t_refund))=0'),
    @('S01', '133 deliveries are success',        'I09, timelines 6.3', '=COUNTIF(t_delivery[status],"success")=133'),
    @('S02', '10 deliveries are skipped',         'I09, timelines 6.3', '=COUNTIF(t_delivery[status],"skipped")=10'),
    @('S03', '2 deliveries are failed',           'I09, timelines 6.3', '=COUNTIF(t_delivery[status],"failed")=2'),
    @('S04', '26 deliveries are cancelled',       'I09, timelines 6.3', '=COUNTIF(t_delivery[status],"cancelled")=26'),
    @('S05', '27 deliveries are planned',         'I09, timelines 6.3', '=COUNTIF(t_delivery[status],"planned")=27'),
    @('C01', 'every first planning day is a Monday',       'BR3', '=COUNTIF(t_season[is_Monday],FALSE)=0'),
    @('C02', 'every first planning day is in its year',    'BR3', '=COUNTIF(t_season[year_ok],FALSE)=0'),
    @('I01a', 'each season has 10 products',               'I01', '=SUMPRODUCT(--(COUNTIFS(t_product[season_id],{1,2,3,4})=10))=4'),
    @('I01b', "each season has 6 farmer's choice products", 'I01', '=SUMPRODUCT(--(COUNTIFS(t_product[season_id],{1,2,3,4},t_product[is_farmers_choice],1)=6))=4'),
    @('I02', 'every submission is inside its enrolment window', 'I02', '=COUNTIF(t_sub[in_window],FALSE)=0'),
    @('I03', 'every allocated_cost matches renewal status (D23, D24)', 'I03', '=COUNTIF(t_sub[cost_ok],FALSE)=0'),
    @('I04', 'every status matches the baseline date',     'I04', '=COUNTIF(t_sub[status_ok],FALSE)=0'),
    @('I05', 'every cancellation date is valid',           'I05', '=COUNTIF(t_sub[canc_ok],FALSE)=0'),
    @('I06', 'remaining skips = 2 - skipped refunds (0 if cancelled)', 'I06', '=COUNTIF(t_sub[skips_ok],FALSE)=0'),
    @('I07', 'every subscription has the expected number of deliveries', 'I07, I08', '=COUNTIF(t_sub[deliv_ok],FALSE)=0'),
    @('I10', 'every refund date follows its rule',         'I10', '=COUNTIF(t_refund[date_ok],FALSE)=0'),
    @('I11', 'every refund amount matches its rule',       'I11, I12, I13', '=COUNTIF(t_refund[amount_ok],FALSE)=0'),
    @('I11b', 'every skipped or failed refund names a delivery with that status', 'I11, I12', '=COUNTIF(t_refund[link_ok],FALSE)=0'),
    @('I12', 'every failed delivery has a failed refund',  'I12', '=COUNTIF(t_delivery[status],"failed")=COUNTIF(t_refund[type],"failed")'),
    @('I13', 'every refund amount is positive (D20)',      'I13', '=COUNTIF(t_refund[amount],"<=0")=0'),
    @('I14a', 'every add-on product is within the plan',   'I14', '=COUNTIF(t_add_on[plan_ok],FALSE)=0'),
    @('I14b', 'every add-on is on an existing delivery',   'I14', '=COUNTIF(t_add_on[delivery_status],"NO DELIVERY")=0'),
    @('I14c', 'every add-on weight is at least 0.10',      'I14', '=COUNTIF(t_add_on[weight],"<0.1")=0'),
    @('I15a', 'customizable has 8 chosen, farmer''s choice has 0', 'I15', '=COUNTIF(t_sub[chosen_ok],FALSE)=0'),
    @('I15b', 'every chosen product is from the subscription season', 'I15', '=COUNTIF(t_chosen[same_season],FALSE)=0'),
    @('U01', 'customer email is unique',                   'uq_customer_email', '=COUNTIF(t_customer[email_unique],FALSE)=0'),
    @('U02', '(customer_id, season_id) is unique',         'uq_subscription_customer_season', '=SUMPRODUCT(--(COUNTIFS(t_sub[customer_id],t_sub[customer_id],t_sub[season_id],t_sub[season_id])>1))=0'),
    @('U03', '(season_id, name) is unique',                'uq_product_season_name', '=SUMPRODUCT(--(COUNTIF(t_product[pkey],t_product[pkey])>1))=0'),
    @('U04', 'chosen_products primary key is unique',      'chosen_products PK', '=SUMPRODUCT(--(COUNTIFS(t_chosen[subscription_id],t_chosen[subscription_id],t_chosen[product_id],t_chosen[product_id])>1))=0'),
    @('U05', 'delivery primary key is unique',             'delivery PK', '=SUMPRODUCT(--(COUNTIF(t_delivery[key],t_delivery[key])>1))=0'),
    @('U06', 'add_on primary key is unique',               'add_on PK', '=SUMPRODUCT(--(COUNTIFS(t_add_on[subscription_id],t_add_on[subscription_id],t_add_on[week_no],t_add_on[week_no],t_add_on[product_id],t_add_on[product_id])>1))=0'),
    @('U07', '(subscription_id, week_no) is unique in refund', 'uq_refund_subscription_week_no', '=SUMPRODUCT((t_refund[week_no]<>"")*(COUNTIFS(t_refund[subscription_id],t_refund[subscription_id],t_refund[week_no],t_refund[week_no])>1))=0'))

# ---------------------------------------------------------------- build
$xl = $null; $wb = $null
try {
    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = $false
    $xl.DisplayAlerts = $false
    $xl.ScreenUpdating = $false
    $xl.AutoCorrect.AutoFillFormulasInLists = $true
    $wb = $xl.Workbooks.Open($book)
    $xl.Calculation = -4135   # manual while building

    $sheet = @{}
    foreach ($n in 'season', 'week', 'product', 'customer', 'subscription', 'chosen',
                   'delivery_exc', 'delivery', 'add_on', 'refund', 'checks') {
        $sheet[$n] = $wb.Worksheets.Item($n)
    }
    foreach ($n in 'checks', 'refund', 'add_on', 'delivery', 'delivery_exc', 'chosen',
                   'subscription', 'customer', 'product') {
        Clear-Sheet $sheet[$n]
    }

    # Step 2: week table name
    $week = $sheet['week'].ListObjects.Item(1)
    if ($week.Name -ne 't_week') { $week.Name = 't_week' }

    # Step 3: product
    $t = New-Table $sheet['product'] 't_product' `
        @('product_id', 'season_id', 'name', 'is_farmers_choice', 'price_per_kg', 'pkey') $productRows 5
    Set-F $t 'pkey' '=[@season_id]&"|"&[@name]'
    Set-Fmt $t @('price_per_kg') $MONEY

    # Step 4: customer
    $t = New-Table $sheet['customer'] 't_customer' `
        @('customer_id', 'name', 'email', 'street', 'building', 'room', 'cast_id', 'email_unique') $customerRows 6
    Set-F $t 'email_unique' '=COUNTIF(t_customer[email],[@email])=1'

    # Step 5: subscription (helpers are filled in step 10)
    $subHeaders = @('subscription_id', 'customer_id', 'season_id', 'status', 'plan_type', 'frequency',
        'allocated_cost', 'submission_date', 'cancellation_date', 'remaining_refundable_skip',
        'label', 'prev_season_id', 'is_renewal', 'expected_cost', 'cost_ok', 'win_lo', 'win_hi', 'in_window',
        'rs', 're', 'expected_status', 'status_ok', 'canc_ok', 'skips_ok', 'n_deliv_expected', 'deliv_ok',
        'chosen_ok', 'fee', 'addon_income', 'refund_total', 'net', 'renewed_next')
    $tSub = New-Table $sheet['subscription'] 't_sub' $subHeaders $subRows 10
    Set-Fmt $tSub @('submission_date', 'cancellation_date', 'win_lo', 'win_hi', 'rs', 're') $DATE
    Set-Fmt $tSub @('allocated_cost', 'expected_cost', 'fee', 'addon_income', 'refund_total', 'net') $MONEY
    Set-List $tSub 'status' 'planned,active,finished,cancelled'
    Set-List $tSub 'plan_type' "farmer's choice,customizable"
    Set-List $tSub 'frequency' 'weekly,biweekly'

    # Step 6: chosen
    $t = New-Table $sheet['chosen'] 't_chosen' @('subscription_id', 'product_id', 'product_name', 'same_season') $chosenRows 2
    Set-F $t 'product_name' '=INDEX(t_product[name],MATCH([@product_id],t_product[product_id],0))'
    Set-F $t 'same_season' '=INDEX(t_product[season_id],MATCH([@product_id],t_product[product_id],0))=INDEX(t_sub[season_id],MATCH([@subscription_id],t_sub[subscription_id],0))'

    # Step 7: delivery_exc and delivery
    $t = New-Table $sheet['delivery_exc'] 't_exc' @('subscription_id', 'week_no', 'status', 'key') $excRows 3
    Set-F $t 'key' '=[@subscription_id]&"-"&[@week_no]'
    Set-List $t 'status' 'skipped,failed'

    $t = New-Table $sheet['delivery'] 't_delivery' `
        @('subscription_id', 'week_no', 'status', 'key', 'season_id', 'delivery_date', 'canc', 'exc_status', 'label') $deliveryRows 3
    Set-F $t 'key'           '=[@subscription_id]&"-"&[@week_no]'
    Set-F $t 'season_id'     '=INDEX(t_sub[season_id],MATCH([@subscription_id],t_sub[subscription_id],0))'
    Set-F $t 'delivery_date' '=INDEX(t_week[delivery_date],MATCH([@season_id]&"-"&[@week_no],t_week[key],0))'
    Set-F $t 'canc'          '=INDEX(t_sub[cancellation_date],MATCH([@subscription_id],t_sub[subscription_id],0))'
    Set-F $t 'exc_status'    '=IFERROR(INDEX(t_exc[status],MATCH([@key],t_exc[key],0)),"")'
    Set-F $t 'label'         '=INDEX(t_season[label],MATCH([@season_id],t_season[season_id],0))'
    Set-F $t 'status'        '=IF([@exc_status]<>"",[@exc_status],IF(AND([@canc]>0,[@delivery_date]>[@canc]),"cancelled",IF([@delivery_date]<=DATE(2026,7,5),"success","planned")))'
    Set-Fmt $t @('delivery_date') $DATE
    Set-Fmt $t @('canc') $DATE0

    # Step 8: add_on
    $t = New-Table $sheet['add_on'] 't_add_on' `
        @('subscription_id', 'week_no', 'product_id', 'weight', 'product_name', 'season_id', 'price', 'fee',
          'plan_type', 'delivery_status', 'plan_ok', 'label') $addOnRows 4
    Set-F $t 'season_id'       '=INDEX(t_sub[season_id],MATCH([@subscription_id],t_sub[subscription_id],0))'
    Set-F $t 'product_id'      '=INDEX(t_product[product_id],MATCH([@season_id]&"|"&[@product_name],t_product[pkey],0))'
    Set-F $t 'price'           '=INDEX(t_product[price_per_kg],MATCH([@product_id],t_product[product_id],0))'
    Set-F $t 'fee'             '=ROUND([@weight]*[@price],2)'
    Set-F $t 'plan_type'       '=INDEX(t_sub[plan_type],MATCH([@subscription_id],t_sub[subscription_id],0))'
    Set-F $t 'delivery_status' '=IFERROR(INDEX(t_delivery[status],MATCH([@subscription_id]&"-"&[@week_no],t_delivery[key],0)),"NO DELIVERY")'
    Set-F $t 'plan_ok'         '=IF([@plan_type]="farmer''s choice",INDEX(t_product[is_farmers_choice],MATCH([@product_id],t_product[product_id],0))=1,COUNTIFS(t_chosen[subscription_id],[@subscription_id],t_chosen[product_id],[@product_id])=1)'
    Set-F $t 'label'           '=INDEX(t_season[label],MATCH([@season_id],t_season[season_id],0))'
    Set-Fmt $t @('weight', 'price', 'fee') $MONEY

    # Step 9: refund
    $t = New-Table $sheet['refund'] 't_refund' `
        @('refund_id', 'subscription_id', 'amount', 'type', 'refund_date', 'week_no', 'cost', 'freq', 'season_id',
          'addon_fee', 'nd', 'nc', 'left', 'feec', 'expected_amount', 'amount_ok', 'win_start', 'win_end', 'ddate',
          'canc', 'date_ok', 'link_ok') $refundRows 6
    $wk = 'MATCH([@season_id]&"-"&[@week_no],t_week[key],0)'
    Set-F $t 'cost'      '=INDEX(t_sub[allocated_cost],MATCH([@subscription_id],t_sub[subscription_id],0))'
    Set-F $t 'freq'      '=INDEX(t_sub[frequency],MATCH([@subscription_id],t_sub[subscription_id],0))'
    Set-F $t 'season_id' '=INDEX(t_sub[season_id],MATCH([@subscription_id],t_sub[subscription_id],0))'
    Set-F $t 'addon_fee' '=IF([@week_no]="",0,SUMIFS(t_add_on[fee],t_add_on[subscription_id],[@subscription_id],t_add_on[week_no],[@week_no]))'
    Set-F $t 'nd'        '=COUNTIFS(t_delivery[subscription_id],[@subscription_id])'
    Set-F $t 'nc'        '=COUNTIFS(t_delivery[subscription_id],[@subscription_id],t_delivery[status],"cancelled")'
    Set-F $t 'left'      '=2-COUNTIFS(t_refund[subscription_id],[@subscription_id],t_refund[type],"skipped",t_refund[refund_date],"<="&[@refund_date])'
    Set-F $t 'feec'      '=SUMIFS(t_add_on[fee],t_add_on[subscription_id],[@subscription_id],t_add_on[delivery_status],"cancelled")'
    Set-F $t 'expected_amount' '=IF([@type]<>"cancelled",[@cost]+[@addon_fee],IF([@nd]=0,IF([@freq]="weekly",12,6)*[@cost],MIN([@left],[@nc])*[@cost]+[@feec]))'
    Set-F $t 'amount_ok' '=ROUND([@amount],2)=ROUND([@expected_amount],2)'
    Set-F $t 'win_start' ('=IF([@week_no]="","",IF([@freq]="weekly",INDEX(t_week[weekly_win_start],' + $wk + '),INDEX(t_week[biweekly_win_start],' + $wk + ')))')
    Set-F $t 'win_end'   ('=IF([@week_no]="","",INDEX(t_week[win_end],' + $wk + '))')
    Set-F $t 'ddate'     ('=IF([@week_no]="","",INDEX(t_week[delivery_date],' + $wk + '))')
    Set-F $t 'canc'      '=INDEX(t_sub[cancellation_date],MATCH([@subscription_id],t_sub[subscription_id],0))'
    Set-F $t 'date_ok'   '=IF([@type]="skipped",AND([@refund_date]>=[@win_start],[@refund_date]<=[@win_end]),IF([@type]="failed",[@refund_date]=[@ddate]+1,[@refund_date]=[@canc]))'
    Set-F $t 'link_ok'   '=IF([@type]="cancelled",[@week_no]="",IFERROR(INDEX(t_delivery[status],MATCH([@subscription_id]&"-"&[@week_no],t_delivery[key],0))=[@type],FALSE))'
    Set-Fmt $t @('refund_date', 'win_start', 'win_end', 'ddate') $DATE
    Set-Fmt $t @('canc') $DATE0
    Set-Fmt $t @('amount', 'cost', 'addon_fee', 'feec', 'expected_amount') $MONEY
    Set-List $t 'type' 'skipped,failed,cancelled'

    # Step 10: subscription helpers
    $sk = 'MATCH([@season_id],t_season[season_id],0)'
    Set-F $tSub 'label'          ('=INDEX(t_season[label],' + $sk + ')')
    Set-F $tSub 'prev_season_id' '=IF([@season_id]=1,"",[@season_id]-1)'
    Set-F $tSub 'is_renewal'     '=IF([@prev_season_id]="",FALSE,COUNTIFS(t_sub[customer_id],[@customer_id],t_sub[season_id],[@prev_season_id],t_sub[cancellation_date],"")+COUNTIFS(t_sub[customer_id],[@customer_id],t_sub[season_id],[@prev_season_id],t_sub[cancellation_date],">"&[@submission_date])>0)'
    Set-F $tSub 'expected_cost'  '=IF([@plan_type]="farmer''s choice",IF([@is_renewal],160,200),IF([@is_renewal],192,240))'
    Set-F $tSub 'cost_ok'        '=[@allocated_cost]=[@expected_cost]'
    Set-F $tSub 'win_lo'         ('=INDEX(t_season[window_start],' + $sk + ')')
    Set-F $tSub 'win_hi'         ('=INDEX(t_season[window_end],' + $sk + ')')
    Set-F $tSub 'in_window'      '=AND([@submission_date]>=[@win_lo],[@submission_date]<=[@win_hi])'
    Set-F $tSub 'rs'             ('=INDEX(t_season[range_start],' + $sk + ')')
    Set-F $tSub 're'             ('=INDEX(t_season[range_end],' + $sk + ')')
    Set-F $tSub 'expected_status' '=IF([@cancellation_date]<>"","cancelled",IF(DATE(2026,7,7)>[@re],"finished",IF(DATE(2026,7,7)>=[@rs],"active","planned")))'
    Set-F $tSub 'status_ok'      '=[@status]=[@expected_status]'
    Set-F $tSub 'canc_ok'        '=OR([@cancellation_date]="",AND([@cancellation_date]<=DATE(2026,7,6),[@cancellation_date]<=[@re],[@cancellation_date]>=[@submission_date]))'
    Set-F $tSub 'skips_ok'       '=[@remaining_refundable_skip]=IF([@status]="cancelled",0,2-COUNTIFS(t_refund[subscription_id],[@subscription_id],t_refund[type],"skipped"))'
    Set-F $tSub 'n_deliv_expected' '=IF(AND([@rs]<DATE(2026,7,7),NOT(AND([@cancellation_date]<>"",[@cancellation_date]<[@rs]))),IF([@frequency]="weekly",12,6),0)'
    Set-F $tSub 'deliv_ok'       '=COUNTIFS(t_delivery[subscription_id],[@subscription_id])=[@n_deliv_expected]'
    Set-F $tSub 'chosen_ok'      '=COUNTIFS(t_chosen[subscription_id],[@subscription_id])=IF([@plan_type]="customizable",8,0)'
    Set-F $tSub 'fee'            '=IF([@frequency]="weekly",12,6)*[@allocated_cost]'
    Set-F $tSub 'addon_income'   '=SUMIFS(t_add_on[fee],t_add_on[subscription_id],[@subscription_id])'
    Set-F $tSub 'refund_total'   '=SUMIFS(t_refund[amount],t_refund[subscription_id],[@subscription_id])'
    Set-F $tSub 'net'            '=[@fee]+[@addon_income]-[@refund_total]'
    Set-F $tSub 'renewed_next'   '=IF(COUNTIFS(t_sub[customer_id],[@customer_id],t_sub[season_id],[@season_id]+1)>0,1,0)'

    # Step 11: checks (plain range; one formula per row)
    $ws = $sheet['checks']
    $n = $checks.Count
    $hdr = @('check_id', 'description', 'maps_to', 'result', 'expected')
    for ($j = 0; $j -lt 5; $j++) {
        $cell = $ws.Cells.Item(1, $j + 1)
        $cell.Value2 = $hdr[$j]
        $cell.Font.Bold = $true
        $cell.Interior.Color = $GREY
    }
    for ($i = 0; $i -lt $n; $i++) {
        $ws.Cells.Item($i + 2, 1).Value2 = $checks[$i][0]
        $ws.Cells.Item($i + 2, 2).Value2 = $checks[$i][1]
        $ws.Cells.Item($i + 2, 3).Value2 = $checks[$i][2]
        $ws.Cells.Item($i + 2, 4).Formula = $checks[$i][3]
        $ws.Cells.Item($i + 2, 5).Value2 = 'TRUE'
    }
    $last = $n + 1
    $ws.Range('G1').Value2 = 'all_checks_pass'
    $ws.Range('G1').Font.Bold = $true
    $ws.Range('G1').Interior.Color = $GREY
    $ws.Range('G2').Formula = "=AND(D2:D$last)"
    foreach ($addr in "D2:D$last", 'G2') {
        $fc = $ws.Range($addr).FormatConditions.Add(1, 3, '=FALSE')
        $fc.Interior.Color = $BAD_FILL
        $fc.Font.Color = $BAD_FONT
    }

    foreach ($n2 in 'product', 'customer', 'subscription', 'chosen', 'delivery_exc', 'delivery', 'add_on', 'refund', 'checks') {
        [void]$sheet[$n2].UsedRange.Columns.AutoFit()
    }

    $xl.CalculateFull()

    # ------------------------------------------------------------ report
    Write-Output '--- row counts'
    foreach ($pair in @(@('season', 't_season'), @('week', 't_week'), @('product', 't_product'),
                        @('customer', 't_customer'), @('subscription', 't_sub'), @('chosen', 't_chosen'),
                        @('delivery_exc', 't_exc'), @('delivery', 't_delivery'), @('add_on', 't_add_on'),
                        @('refund', 't_refund'))) {
        Write-Output ("{0,-12} {1}" -f $pair[1], $sheet[$pair[0]].ListObjects.Item($pair[1]).ListRows.Count)
    }
    Write-Output '--- checks'
    $failed = 0
    for ($i = 0; $i -lt $n; $i++) {
        $cell = $ws.Cells.Item($i + 2, 4)
        $v = $cell.Value2
        $text = $(if ($v -is [bool]) { "$v".ToUpper() } else { "ERROR($($cell.Text))" })
        if (-not ($v -is [bool] -and $v)) { $failed++ }
        Write-Output ("{0,-5} {1,-6} {2}" -f $checks[$i][0], $text, $checks[$i][1])
    }
    Write-Output ("all_checks_pass = {0}; failed = {1}" -f $ws.Range('G2').Text, $failed)
    Write-Output '--- spot values'
    $ev = $sheet['subscription']
    $spots = @(
        @('refund of 205, expected_amount (526)', 'INDEX(t_refund[expected_amount],MATCH(205,t_refund[subscription_id],0))'),
        @('403 is_renewal (TRUE)',                'INDEX(t_sub[is_renewal],MATCH(403,t_sub[subscription_id],0))'),
        @('303 is_renewal (FALSE)',               'INDEX(t_sub[is_renewal],MATCH(303,t_sub[subscription_id],0))'))
    foreach ($s in $spots) {
        $r = $ev.Evaluate($s[1])
        if ($r -is [__ComObject]) { $r = $r.Value2 }
        Write-Output ("{0} = {1}" -f $s[0], $r)
    }

    $xl.Calculation = -4105   # automatic
    $xl.ScreenUpdating = $true
    $wb.Save()
}
finally {
    if ($wb) { $wb.Close($false); [void][Runtime.InteropServices.Marshal]::ReleaseComObject($wb) }
    if ($xl) { $xl.Quit(); [void][Runtime.InteropServices.Marshal]::ReleaseComObject($xl) }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
