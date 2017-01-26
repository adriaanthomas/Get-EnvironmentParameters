<#
.SYNOPSIS
    Returns a collection of objects with each holding an ARM template parameter value for each environment.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]] $TemplateParameterFiles,

    [string] $NotSetValue = $null
)

begin {
    $environments = @()
    $values = @{}

    # Returns the tail of the strings that is unique, that is, trims the heads that are the same on all strings.
    function Get-UniquePart([string[]] $names) {
        if ($names | ForEach-Object { $total = $false } { $total = $total -or [string]::IsNullOrEmpty($_) -or (-not $_.StartsWith($names[0][0])) } { $total }) {
            $names
        } else {
            Get-UniquePart $names.Substring(1)
        }
    }
}

process {
    $TemplateParameterFiles | ForEach-Object {
        $file = $_
        $environmentName = ([System.IO.FileInfo] $file).BaseName
        $environments += $environmentName

        (Get-Content $file | ConvertFrom-Json).parameters.PSObject.Properties | ForEach-Object {
            $parameterName = $_.Name
            $parameterValue = $_.Value.value
            if (-not $values.ContainsKey($parameterName)) {
                $values[$parameterName] = @{}
            }
            $values[$parameterName][$environmentName] = $parameterValue
        }
    }
}

end {
    $shortEnvironmentNames = Get-UniquePart $environments
    $envMapping = @{}
    for ($i = 0; $i -lt $environments.Length; $i++) {
        $envMapping[$environments[$i]] = $shortEnvironmentNames[$i]
    }

    $values.GetEnumerator() | ForEach-Object {
        $envToValue = $_.Value
        $parameter = [PSCustomObject] @{
            Name = $_.Key
        }
        $environments | ForEach-Object {
            $value = if ($envToValue.ContainsKey($_)) { $envToValue[$_]} else { $NotSetValue }
            $parameter | Add-Member $envMapping[$_] $value
        }
        $parameter
    }
}