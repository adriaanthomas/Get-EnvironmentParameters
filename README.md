# Get-EnvironmentParameters

Takes a number of ARM template parameter files, takes the parameter values for each environment, and outputs them
for easy formatting using `Format-Table`.

Example usage:

    Get-ChildItem | Where-Object { $_.Name -match '.*-parameters.*\.json$' } | Get-EnvironmentParameters.ps1 | Sort-Object Name

This will show a table, with a column per environment and all parameters in rows, with parameters sorted by name.

As this script only writes objects to the pipeline, more filtering and manipulation is possible, eg:

    $parameterFiles | Get-EnvironmentParameters.ps1 | Where-Object { $_.dev -ne $_.prod }

This will only show parameters that have different values in dev and prod.

## License

[MIT](LICENSE.md)