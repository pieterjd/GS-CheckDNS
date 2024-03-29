function check-ip{
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('FullName')]
    [String[]]$ips
    )#end param
    process{
        foreach($ip in $ips){
            $ping = Test-Connection -Quiet $ip
            #arp ping
            $arpOutput = .\arp-ping.exe $ip
            #if arp ping failed, then output contains the text '4 failed'
            $arpPing = ($arpOutput| Select-String -Pattern '4 failed') -eq $null
            $hostName = ([System.Net.Dns]::GetHostByAddress($ip)).HostName
            #lookup hostname
            try{
                $ipCheck = ([System.Net.Dns]::GetHostAddresses($hostName)) |  select -ExpandProperty IPAddressToString
                $sameIP = $ip -eq $ipCheck    
                if($ipCheck -is [system.array]){
                    #if it is an array, do something else
                    $sameIP = $ipCheck -contains $ip
                }
            }
            catch [system.exception]{
                $ipCheck = "Failed to lookup"
            }
            
            $properties = @{'inputIP'=$ip;'pingResult'=$ping;'ARPpingResult'=$arpPing;'hostname'=$hostName;'ipLookup'=$ipCheck;'SameIP'=$sameIP;}
            #create result object
            $result = New-Object -TypeName PSObject -Property $properties
            #change the default order
            $defaultProperties = @(‘inputIP’,'pingResult','ARPpingResult','hostname','ipLookup','SameIP')
            $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
            $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
            #write it out
            $result  
        }
    }  
}