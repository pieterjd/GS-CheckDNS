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
            $hostName = ([System.Net.Dns]::GetHostByAddress($ip)).HostName
            #lookup hostname
            $ipCheck = ([System.Net.Dns]::GetHostAddresses($hostName)) |  select -ExpandProperty IPAddressToString
            $sameIP = $ip -eq $ipCheck    
            $properties = @{'inputIP'=$ip;'pingResult'=$ping;'hostname'=$hostName;'ipLookup'=$ipCheck;'SameIP'=$sameIP;}
            #create result object
            $result = New-Object -TypeName PSObject -Property $properties
            #write it out
            $result  
        }
    }  
}