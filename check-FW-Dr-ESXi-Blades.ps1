#Script to get HPE-ESXi Drivers for Gen8-9-6.0-6.5U1QFle3 Drivers
#Hardcode the NIC's in the script that are in USE on the Cluster/Hosts.

$vmhosts = Get-Cluster "Cluster-Name" | get-vmHost
$report = @()

foreach( $ESXHost in $vmhosts) {

$HWModel = get-vmHost $ESXHost | Select Name, Model
$esxcli = Get-ESXcli -vmhost $ESXHost
$ESXversion = $esxcli.system.version.get()
$ESXv = $ESXversion.version + "-Update" + $Esxversion.update + " " + $ESXversion.build

if($HWModel.Model -Match "gen8")
{

write-host "`n Checking Driver and Firmware info on Host $ESXHost"

$info = $esxcli.network.nic.get("vmnic0").DriverInfo  | select  Driver,Hardwaremodel, FirmwareVersion, Version
$ModuleName =  "$($info.Driver)"
$Firmware = "$($info.FirmwareVersion)"
$Driver   = "$($info.Version)"
$lpfc = $esxcli.software.vib.list() | where { $_.name -eq "lpfc"}
$report += $info | select @{N="Hostname"; E={$ESXHost}},@{N="Hardware-Model"; E={$HWModel.Model}},@{N="ESXi-Version"; E={$ESXv}},@{N="Adapter-Firmware"; E={$Firmware}}, @{N="Network-Driver"; E={$Driver}}, @{N="FC-Driver"; E={$lpfc.version.substring(0,11)}}
}#closing Gen8 Loop

elseif ($HWModel.Model -Match "gen9" -OR "gen10")
{
write-host "`n Checking Driver and Firmware info on Host $ESXHost"

$info = $esxcli.network.nic.get("vmnic0").DriverInfo  | select  Driver, FirmwareVersion, Version
$ModuleName =  "$($info.Driver)"
$Firmware = "$($info.FirmwareVersion)"
$Driver   = "$($info.Version)"
$FCDrivers =  $vmkload_mod
$QFle3f = $esxcli.storage.core.adapter.list() | where { $_.name -eq "qfle3f"}
$FCDriver =   $esxcli.software.vib.list() | where { $_.name -eq "qfle3f"}
$report += ($info | select @{N="Hostname"; E={$ESXHost}},@{N="Hardware-Model"; E={$HWModel.Model}},@{N="ESXi-Version"; E={$ESXv}},@{N="Adapter-Firmware"; E={$Firmware}},@{N="Network-Driver"; E={$Driver}}, @{N="FC-Driver"; E={$FCDriver.version.substring(0,13)}})

}
}
$report | out-gridview

$CurrentDateTime = Get-Date -format "ddMMMyyyy-HH-mm"
$Filename = "Hosts-DR-FW-" + $CurrentDateTime + ".csv"
$report | Export-Csv "$Filename" -NoTypeInformation -UseCulture 
