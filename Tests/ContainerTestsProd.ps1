$count = 0
do {
    $count++
    Write-Output "[$env:STAGE_NAME] Starting container [Attempt: $count]"

    $testStart = Invoke-WebRequest -Uri http://130.211.124.153/ -UseBasicParsing

    if ($testStart.statuscode -eq '200') {
        $started = $true
    } else {
        Start-Sleep -Seconds 2
    }

} until ($started -or ($count -eq 20))

if (!$started) {
    exit 1
}
