function global:get_counts {
    $run_id = (New-Guid).Guid

    $j = Start-Job -Name "Disabled.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -AccountDisabled | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Expired.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -AccountExpired | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Expiring 30 Days.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -AccountExpiring -TimeSpan 30.00:00:00 | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Locked Out.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -LockedOut | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Inactive 30 Days.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 30.00:00:00 | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Inactive 60 Days.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 60.00:00:00 | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Inactive 90 Days.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 90.00:00:00 | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Inactive 180 Days.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 180.00:00:00 | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Password Expired.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -PasswordExpired | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Password Never Expires.${run_id}" -InitializationScript $global:init -ScriptBlock {
        (Search-ADAccount -UsersOnly -PasswordNeverExpires | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)


    $ad_users = Get-ADUser -Filter '*' -Properties EmployeeID,LastLogonTimestamp

    $j = Start-Job -Name "All.${run_id}" -InitializationScript $global:init -ScriptBlock {
        ($using:ad_users | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Enabled.${run_id}" -InitializationScript $global:init -ScriptBlock {
        ($using:ad_users | ?{ $_.Enabled -eq $true } | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Enabled Employee.${run_id}" -InitializationScript $global:init -ScriptBlock {
        ($using:ad_users | ?{ $_.Enabled -eq $true } | ?{ $_.EmployeeID -ne $null } | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $j = Start-Job -Name "Enabled Active Employee.${run_id}" -InitializationScript $global:init -ScriptBlock {
        $d180 = (Get-Date).AddDays(-180).ToFileTime()
        ($using:ad_users | ?{ $_.Enabled -eq $true } | ?{ $_.EmployeeID -ne $null } | ?{ $_.LastLogonTimestamp -gt $d180 } | Measure-Object).Count
    }
    Write-Verbose ('Job Started: {0}: {1}' -f $j.Id, $j.Name)

    $jobs = Wait-Job -Name "*.${run_id}"
    [System.Collections.ArrayList] $rows = @()
    foreach ($job in ($jobs | Sort-Object 'Name')) {
        $rows.Add(@($job.Name.TrimEnd(".${run_id}"), (Receive-Job $job.Id))) | Out-Null
    }

    return ConvertTo-Json @{
        'response_type' = 'in_channel';
        'text' = ConvertTo-MarkdownTable -Title 'CAS AD User Counts' -Data @{
            'header' = @('CAS AD Users', 'Count');
            'justify' = @('l', 'r');
            'rows' = $rows;
        };
    }
}

function global:get_computer_counts {

}