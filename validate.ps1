$ErrorActionPreference = 'Stop'
$index = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'catalog.json') -Raw | ConvertFrom-Json
if ($index.FormatVersion -ne 1 -or $null -eq $index.Packages -or @($index.Packages).Count -gt 500) { throw 'Invalid catalog format.' }
$packIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$questionIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($entry in $index.Packages) {
    if ($entry.Id -cnotmatch '^[a-z][a-z0-9-]{0,63}$' -or -not $packIds.Add($entry.Id)) { throw 'Invalid or duplicate package ID.' }
    if ($entry.Version -notmatch '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$') { throw 'Invalid version.' }
    $parsedVersion = [version]$entry.Version
    if ($entry.Url -cne "packages/$($entry.Id)/$($entry.Version).json") { throw 'Invalid package path.' }
    $path = Join-Path $PSScriptRoot $entry.Url
    if ((Get-Item -LiteralPath $path).Length -ne $entry.SizeBytes -or $entry.SizeBytes -gt 10485760) { throw 'Incorrect package size.' }
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ine $entry.Sha256) { throw 'Incorrect SHA-256.' }
    $package = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if ($package.FormatVersion -ne 1) { throw 'Unsupported package format.' }
    foreach ($field in @('Id', 'Version', 'Title', 'Description', 'Artwork')) {
        if ($package.$field -cne $entry.$field) { throw "Metadata mismatch: $field" }
    }
    if ([string]::IsNullOrWhiteSpace($package.Title) -or $package.Title.Length -gt 150 -or
        [string]::IsNullOrWhiteSpace($package.Description) -or $package.Description.Length -gt 2000 -or $package.Artwork -lt 0 -or $package.Artwork -gt 5) { throw 'Invalid metadata.' }
    if (@($package.Questions).Count -lt 1 -or @($package.Questions).Count -gt 10000) { throw 'Invalid question count.' }
    foreach ($question in $package.Questions) {
        if ($question.PackId -cne $entry.Id -or [string]::IsNullOrWhiteSpace($question.Id) -or $question.Id.Length -gt 150 -or -not $questionIds.Add($question.Id)) { throw 'Invalid question ID or package assignment.' }
        if ($question.Difficulty -cnotin @('Anfänger', 'Bibelkundig', 'Experte')) { throw 'Invalid difficulty.' }
        if (@($question.Answers).Count -ne 4 -or $question.CorrectIndex -notin @(0,1,2,3)) { throw 'Invalid answers.' }
        foreach ($answer in $question.Answers) { if ([string]::IsNullOrWhiteSpace($answer) -or $answer.Length -gt 2000) { throw 'Invalid answer text.' } }
        foreach ($field in @('Text', 'Explanation', 'Source')) { if ([string]::IsNullOrWhiteSpace($question.$field)) { throw "Missing $field" } }
        if ($question.Text.Length -gt 4000 -or $question.Explanation.Length -gt 8000 -or $question.Source.Length -gt 2000) { throw 'Question text too long.' }
    }
    foreach ($level in @('Anfänger', 'Bibelkundig', 'Experte')) { if (-not @($package.Questions | Where-Object Difficulty -CEQ $level).Count) { throw "Missing difficulty: $level" } }
}
Write-Output "Validated $($packIds.Count) packages and $($questionIds.Count) questions."
