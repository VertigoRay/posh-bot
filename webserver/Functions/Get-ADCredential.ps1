function global:Get-ADCredential {
    if ((Test-Path '/run/secrets/ad_user') -and (Test-Path '/run/secrets/ad_pass')) {
        $ad_user = (Get-Content '/run/secrets/ad_user' | Out-String)
        $ad_pass = ConvertTo-SecureString -String (Get-Content '/run/secrets/ad_pass' | Out-String) -AsPlainText -Force
    } elseif ($env:ad_user -and $env:ad_pass) {
        $ad_user = $env:ad_user
        $ad_pass = ConvertTo-SecureString -String $env:ad_pass -AsPlainText -Force
    } else {
        Throw('AD Credentials must be supplied via a docker secret of environment variables.')
    }
    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ad_user, $ad_pass
}