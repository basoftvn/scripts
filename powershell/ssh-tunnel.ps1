#!/usr/bin/env pwsh

$SSH_USER = 'user'
$SSH_HOST = 'host'
$SSH_PORT = 'port'

function Bootstrap() {
    # Tunnels declaration, this should be the only part to be changed
    <# Declaration syntax:
    <Tunnel name (should be service name with identifier if duplicated)> = CreateTunnel `
        -LocalPort <the port to be listened on local machine> `
        -RemotePort <the port to be listened on remote machine (ssh target)> `
        -TargetAddress <address of the target to be listened, relatively to remote machine (if not specified, target will be the remote machine)>
    #>

    $tunnels = @{
        Cockpit = CreateTunnel -LocalPort 9090  -RemotePort 9090 -TargetAddress $INT_ALL
    }

    $keepAliveCommand = ""
    # If keep alive options are not available, uncomment the line below
    # $keepAliveCommand = "ping google.com -i 29"



































































    $remoteTunnels = @()

    foreach ($tunnel in $tunnels.Values) {
        $remoteTunnels += "-L 127.0.0.1:$($tunnel.LocalPort):$($tunnel.TargetAddress):$($tunnel.RemotePort)"
    }

    $remoteTunnel = [String]::Join(' ', $remoteTunnels)

    $command = "ssh -N ${remoteTunnel} ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT} ${keepAliveCommand}"
    
    if ($IsWindows -or $ENV:OS) {
        $command | cmd
    }
    else {
        $command | bash
    }
}

class Tunnel {
    [ValidateNotNullOrEmpty()][UInt16] $LocalPort       # Port on local machine
    [ValidateNotNullOrEmpty()][UInt16] $RemotePort      # Port on remote machine
    [ValidateNotNullOrEmpty()][String] $TargetAddress   # Address of remote machine

    Tunnel([UInt16] $Local, [UInt16] $Remote, [String] $Target) {
        $this.LocalPort = $Local
        $this.RemotePort = $Remote
        $this.TargetAddress = $Target
    }
}

function CreateTunnel {
    param(
        [Parameter(Mandatory = $true)]
        [UInt16] $LocalPort,
        [Parameter(Mandatory = $true)]
        [UInt16] $RemotePort,
        [Parameter(Mandatory = $false)]
        [String] $TargetAddress
    )

    if (($null -eq $TargetAddress) -or (0 -eq $TargetAddress.Length)) {
        return [Tunnel]::new($LocalPort, $RemotePort, "0.0.0.0")
    }
    else {
        return [Tunnel]::new($LocalPort, $RemotePort, $TargetAddress)
    }
}

Bootstrap ''
