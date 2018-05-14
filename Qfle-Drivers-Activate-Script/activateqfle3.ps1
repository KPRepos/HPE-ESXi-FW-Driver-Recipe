#Activate QFLE3 Driver, Run below script after connecting to vCenter server where the host resides, please reboot the host after running the script.
#This script applies to ESXi Hosts upgraded to 6.5U1 image with qfle3 from 6.0/6.5

$ESXihost = Read-host 'Please type Esxi Host FQDN'
try{
$powerstate = get-vmhost $ESXihost | select ConnectionState
if($powerstate.connectionstate -match "Maintenance")
{
Write-host "`nThe Host is in Maintenance mode" -ForegroundColor Green

$esxcli = Get-Esxcli -vmhost $Esxihost
$vibs = $esxcli.software.vib.list() | Where {$VibNames -contains "qfle" }

$systemmodule=$esxcli.system.module.list() | where { $_.name -eq "qfle3"}

if($systemmodule.Isenabled -match "false")

  {
   Write-host "`nHPE Qfle3 drivers are not active, The drivers will be made active now`n"

   try{
   $qfleenabled=$esxcli.system.module.set($true,$true,"qfle3")
   if($qfleenabled -match "true")
     {
        $esxcli.system.module.set($true,$true,"qfle3")
     }
     else { echo "Something went wrong, pleae check "}

   Write-host "`nQfle3 driver is made active, please reboot the host" -ForegroundColor Green
     }

   catch {
       Write-host "`nerror occured" -ForegroundColor Red
         }

}
else
{

    Write-host "`nThe driver is already active,Please check Manually for next steps" -ForegroundColor Red
}
}
elseif($powerstate.connectionstate -eq "Connected")
{

    Write-host "`nPlease keep the host in Maintenance mode and run the script again"  -ForegroundColor Red
}
}

catch

{
   Write-host "Run the Script again with Correct parameters and make sure ESXcli is installed"
}
