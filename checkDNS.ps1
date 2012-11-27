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
            
            $properties = @{'inputIP'=$ip;'pingResult'=$ping;'hostname'=$hostName;'ipLookup'=$ipCheck;'SameIP'=$sameIP;}
            #create result object
            $result = New-Object -TypeName PSObject -Property $properties
            #write it out
            $result  
        }
    }  
}