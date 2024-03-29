cls
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$FlashArrayName = @('pure1','pure2','pure3','pure4')

$AuthAction = @{
    password = "pass"
    username = "user"
}




# will ignore SSL or TLS warnings when connecting to the site
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$pass = cat C:\temp\cred.txt | ConvertTo-SecureString
$mycred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist "admin",$pass

# function to perform the HTTP Post web request
function post-vcops ($custval,$custval2,$custval3)
{
# url for the vCOps UI VM. Should be the IP, NETBIOS name or FQDN
$url = "<vcops ip>"
#write-host "Enter in the admin account for vCenter Operations"

# prompts for admin credentials for vCOps. If running as scheduled task replace with static credentials
$cred = $mycred

# sets resource name
$resname = $custval3

# sets adapter kind
$adaptkind = "Http Post"
$reskind = "Pure FlashArray"

# sets resource description
$resdesc = "<flasharraydesc>"

# sets the metric name
$metname = $custval2

# sets the alarm level
$alrmlev = "0"

# sets the alarm message
$alrmmsg = "alarm message"

# sets the time in epoch and in milliseconds
#This is setting us 7 hours behind
$epoch = [decimal]::Round((New-TimeSpan -Start (get-date -date "01/01/1970") -End (get-date)).TotalMilliseconds)

# takes the above values and combines them to set the body for the Http Post request
# these are comma separated and because they are positional, extra commas exist as place holders for
# parameters we didn't specify
$body = "$resname,$adaptkind,$reskind,,$resdesc`n$metname,$alrmlev,$alrmmsg,$epoch,$custval"

# executes the Http Post Request
Invoke-WebRequest -Uri "https://$url/HttpPostAdapter/OpenAPIServlet" -Credential $cred -Method Post -Body $body
#write-host $resname
#write-host $custval2 "=" $custval "on" $custval3
}


ForEach($element in $FlashArrayName)
{
$faName = $element.ToString()
$ApiToken = Invoke-RestMethod -Method Post -Uri "https://${faName}/api/1.1/auth/apitoken" -Body $AuthAction

$SessionAction = @{
    api_token = $ApiToken.api_token
}
Invoke-RestMethod -Method Post -Uri "https://${faName}/api/1.1/auth/session" -Body $SessionAction -SessionVariable Session
 
 $PureStats = Invoke-RestMethod -Method Get -Uri "https://${faName}/api/1.1/array?action=monitor" -WebSession $Session
 $PureArray = Invoke-RestMethod -Method Get -Uri "https://${faName}/api/1.1/array?space=true" -WebSession $Session
ForEach($FlashArray in $PureStats) {
    
   
    $wIOs = $FlashArray.writes_per_sec
    $rIOs = $FlashArray.reads_per_sec
    $rLatency = $FlashArray.usec_per_read_op
    $wLatency = $FlashArray.usec_per_write_op
    $queueDepth = $FlashArray.queue_depth
    $bwInbound = $FlashArray.input_per_sec
    $bwOutbound = $FlashArray.output_per_sec
    
    

}
ForEach($FlashArray in $PureArray) {
    
   
    $arrayCap =($FlashArray.capacity)
    $arrayDR =($FlashArray.data_reduction)
    $arraySS =($FlashArray.shared_space)
    $arraySnap =($FlashArray.snapshots)
    $arraySys =($FlashArray.system)
    $arrayTP =($FlashArray.thin_provisioning)
    $arrayTot =($FlashArray.total)
    $arrayTR =($FlashArray.total_reduction)
    $arrayVol =($FlashArray.volumes)
    
    

}


 
    post-vcops($wIOs)("Write IO")($faName)
    post-vcops($rIOs)("Read IO")($faName)
    post-vcops($rLatency)("Read Latency")($faName)
    post-vcops($wLatency)("Write Latency")($faName)
    post-vcops($queueDepth)("Queue Depth")($faName)
    post-vcops($bwInbound)("Input per Sec")($faName)
    post-vcops($bwOutbound)("Output per Sec")($faName)

    
    
    post-vcops($FlashArray.capacity)("Capacity")($faName)
    post-vcops($FlashArray.data_reduction)("Real Data Reduction")($faName)
    post-vcops($FlashArray.shared_space)("Shared Space")($faName)
    post-vcops($FlashArray.snapshots)("Snapshot Space")($faName)
    post-vcops($FlashArray.system)("System Space")($faName)
    post-vcops($FlashArray.thin_provisioning)("TP Space")($faName)
    post-vcops($FlashArray.total)("Total Space")($faName)
    post-vcops($FlashArray.total_reduction)("Faker Total Reduction")($faName)
    post-vcops($FlashArray.volumes)("Volumes")($faName)

 } 