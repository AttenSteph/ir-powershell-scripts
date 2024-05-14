get-mailbox -resultsize unlimited  |
ForEach-Object {
    Write-Verbose "Checking $($_.alias)..." -Verbose
    $inboxrule = get-inboxrule -Mailbox $_.alias -includeHidden
    if ($inboxrule) {
        foreach($rule in $inboxrule){
        [PSCustomObject]@{
            Mailbox         = $_.alias
            Rulename        = $rule.name
            Identity        = $rule.identity
            Enabled         = $rule.enabled
            From            = $rule.from
            Rulepriority    = $rule.priority
            Ruledescription = $rule.description
            RedirectTo      = $rule.redirectto
            ForwardTo       = $rule.forwardto
        }
    }
    }
} | 
Export-csv ".\export.csv" -NoTypeInformation