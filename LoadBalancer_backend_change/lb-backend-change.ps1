
<#
  .SYNOPSIS
  Getting a VM out the Azure Load Balancer backend pool.

  .DESCRIPTION
  The lb-backend-change.ps1 adds and removes VMs from the Load Balancer backend pool.

  .INPUTS
  C:\PS> .\lb-backend-change.ps1 Operation "ResourceGroupName" "LoadBalancerName" "VmName"

  .OUTPUTS
  lb-backend-change.ps1 does not generate any output.

  .EXAMPLE
  C:\PS> .\lb-backend-change.ps1 remove "ob-lb-ph-demo-rsg" "lb-demo-lb" "lb-demo-vm1"

  .EXAMPLE
  C:\PS> .\lb-backend-change.ps1 add "rsg-dev-centralus" "lbe-dev" "vm1"
#>
Param(
   [Parameter(Mandatory=$True)][string]$Operation = "",
   [Parameter(Mandatory=$True)][string]$resourceGroupName = "",
   [Parameter(Mandatory=$True)][string]$LoadBalancerName = "",
   [Parameter(Mandatory=$True)][string]$VmName = ""
)

    write-output "Getting VM $VmName"
    $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $VmName

    $rs = Get-AzResource -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].id
    write-output "Getting NIC $($rs.Name)"
    $nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name $rs.Name

    write-output "Getting LoadBalancer $LoadBalancerName"
    $lb = Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $resourceGroupName



    if ( $Operation.ToLower() -eq "add" ) {
        write-output "Adding NIC from LoadBalancerBackendAddressPools $($lb.BackendAddressPools.name)"
        $nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $lb.BackendAddressPools
    } else {
        write-output "Removing NIC from LoadBalancerBackendAddressPools $($lb.BackendAddressPools.name)"
        $nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $null
    }
    
    write-output "Updating NIC"
    Set-AzNetworkInterface -NetworkInterface $nic
