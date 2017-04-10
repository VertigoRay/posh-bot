<#
.SYNOPSIS
Make a Markdown table.
.DESCRIPTION
Convert a specially formatted hashtable into a Markdown table.
.PARAMETER Title
.PARAMETER Data
There are three arrays expected in this hashtable: header, justify, and rows. All arrays should be the same width to ensure no issues.

- Header (`header`) is the header row of the tables.
- Justify (`justify`) determines how the columns should be aligned.
    - Left: `l`
    - Center: `c`
    - Right: `r`
- Rows (`rows`) is an array of arrays containing each row and each column. Should be pretty straght forward, right?
.PARAMETER DoNotWrapInHL
Do not wrap in the *response* in Horizontal Lines
.EXAMPLE
# This is all left justified
ConvertTo-MarkdownTable -Title 'This is a Sample' -DoNotWrapInHL -Data @{
    'header' = @('Tables', 'Are', 'Cool');
    'rows' = @(
        @('abc', '123', '!@#'),
        @('def', '456', '$%^'),
        @('ghi', '789', '&*-')
    );
}
.EXAMPLE
# This is all left justified
ConvertTo-MarkdownTable -Title 'This is a Sample' -Data @{
    'header' = @('Tables', 'Are', 'Cool');
    'rows' = @(
        @('abc', '123', '!@#'),
        @('def', '456', '$%^'),
        @('ghi', '789', '&*-')
    );
}
.EXAMPLE
# Each column is justified differently
ConvertTo-MarkdownTable -Title 'This is a Sample' -Data @{
    'header' = @('Tables', 'Are', 'Cool');
    'justify' = @('l', 'c', 'r');
    'rows' = @(
        @('col 3 is', 'right-aligned', '$1600'),
        @('col 2 is', 'centered', '$12'),
        @('zebra stripes', 'are neat', '$1')
    );
}
#>
function global:ConvertTo-MarkdownTable {
    param(
        [string] $Title,
        [hashtable] $Data,
        [switch] $DoNotWrapInHL
    )

    [Collections.ArrayList] $response = @()
    if (-not $DoNotWrapInHL) {
        $response.Add('---') | Out-Null
        $response.Add('') | Out-Null
    }

    if ($Title) {
        $response.Add("#### ${Title}") | Out-Null
        $response.Add('') | Out-Null
    }

    if ($Data.header) {
        $response.Add(($Data.header -join ' | ')) | Out-Null

        if ($Data.justify) {
            [Collections.ArrayList] $justify = @()
            foreach ($j in $Data.justify) {
                if ($j -eq 'l') {
                    $justify.Add('---') | Out-Null
                } elseif ($j -eq 'c') {
                    $justify.Add(':---:') | Out-Null
                } elseif ($j -eq 'r') {
                    $justify.Add('---:') | Out-Null
                }
            }
        } else {
            $justify = 1..$Data.header.Length | %{ '---' }
        }
        
        $response.Add(($justify -join ' | ')) | Out-Null
    }

    if ($Data.rows) {
        foreach ($row in $Data.rows) {
            $response.Add(($row -join ' | ')) | Out-Null
        }
    }

    if (-not $DoNotWrapInHL) {
        $response.Add('') | Out-Null
        $response.Add('---') | Out-Null
    }

    return $response | Out-String
}