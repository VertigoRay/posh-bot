$PSDefaultParameterValues.Set_Item('Get-ADUser:Credential', (Get-ADCredential))
$PSDefaultParameterValues.Set_Item('Get-ADUser:SearchBase', $env:AD_SEARCHBASE)
$PSDefaultParameterValues.Set_Item('Get-ADUser:Server', $env:AD_SERVER)
$PSDefaultParameterValues.Set_Item('Search-ADAccount:Credential', (Get-ADCredential))
$PSDefaultParameterValues.Set_Item('Search-ADAccount:SearchBase', $env:AD_SEARCHBASE)
$PSDefaultParameterValues.Set_Item('Search-ADAccount:Server', $env:AD_SERVER)