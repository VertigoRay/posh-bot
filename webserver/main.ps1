$InformationPreference = 'Continue'

$global:init=[scriptblock]::create(@"
Set-Location '$(Get-Location)'

Get-ChildItem 'Functions' -Filter '*.ps1' -File | %{ . `$_.FullName }
Get-ChildItem 'Functions' -Filter '*.ps1' -Exclude '*.Tests.ps1' -File -Recurse | %{ . `$_.FullName }
`$global:routes = @{}
Get-ChildItem 'Functions' -Filter '*.json' -File -Recurse | %{ (Get-Content `$_.FullName | Out-String | ConvertFrom-Json).PSObject.Properties | %{ `$routes.Add(`$_.Name, `$_.Value) } }

Import-Module ActiveDirectory
"@)
&$global:init

Write-Host "Routes: $($routes | Out-String)" -ForegroundColor 'Cyan'


$env:WEBSERVER_PROTOCOL = if ($env:WEBSERVER_PROTOCOL) {$env:WEBSERVER_PROTOCOL} else {'http'}
$env:WEBSERVER_HOST = if ($env:WEBSERVER_HOST) {$env:WEBSERVER_HOST} else {'*'}
$env:WEBSERVER_PORT = if ($env:WEBSERVER_PORT) {$env:WEBSERVER_PORT} else {'8080'}
$url = "${env:WEBSERVER_PROTOCOL}://${env:WEBSERVER_HOST}:${env:WEBSERVER_PORT}/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Listening: ${url}" -ForegroundColor 'Green'

while ($listener.IsListening) {
    $Time = [System.Diagnostics.Stopwatch]::StartNew()

    $context = $listener.GetContext()
    if ($context.MATTERMOST_TOKEN -ne $env:MATTERMOST_TOKEN) {
        Write-Warning 'Invalid Token.'
    }
    $requestUrl = $context.Request.Url
    $response = $context.Response

    Write-Host ''
    Write-Host "> ${requestUrl}"
    Write-Verbose ($context.Request | Out-String)

    questUrl.LocalPath
    $route = $routes.$($requestUrl.LocalPath)

    if ($route -eq $null) {
        $response.StatusCode = 404
    } else {
        $content = & $route
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    $response.Close()

    $responseStatus = $response.StatusCode
    Write-Host "< ${responseStatus} (Seconds: $($Time.Elapsed.TotalSeconds))"
}
