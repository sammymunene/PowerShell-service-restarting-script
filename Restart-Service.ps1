<# 
This Script was written on 01/10/2024.
- The reusable script is written in PowerShell. Its function is to restart a specified Windows service.
- Ask for permission before use for copyright purposes.

- Copyright (c) 2024 Sammy Murithi

- All rights reserved.

- This script is the property of Sammy Murithi. It may not be reproduced, distributed, or used
- without explicit written permission from the owner.

- For licensing and usage inquiries, please contact: sammymurithi22@gmail.com
#>

# Function to write output in green (for basic info)
function Write-Green($message) {
    Write-Host $message -ForegroundColor Green
}

# Function to write output in red (for errors and warnings)
function Write-Red($message) {
    Write-Host $message -ForegroundColor Red
}

function Write-Yellow($message) {
    Write-Host $message -ForegroundColor Yellow
}

function Write-Blue($message) {
    Write-Host $message -ForegroundColor Blue
}

# Define service names
$service1 = "SBAMpesaServer"
$service2 = "SBAOnlineSync"
$service3 = "SBADoorController"
$service4 = "SBAServer"

# Function to get and display service status
function Get-ServiceStatus($serviceName) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Red "Service '$serviceName' not found."
        return $null
    }
    $status = $service.Status
    Write-Blue "Current status of '$serviceName': $status"
    return $service
}

# User prompt for service selection
Write-Green "Please choose a service to manage:"
Write-Green "1. $service1"
Write-Green "2. $service2"
Write-Green "3. $service3"
Write-Green "4. $service4"
Write-Green "5. All services"
$choice = Read-Host "Enter 1, 2, 3, 4 or 5"

# Determine the selected service
if ($choice -eq '5') {
    $serviceNames = @($service1, $service2, $service3, $service4)
} else {
    switch ($choice) {
        1 { $serviceNames = @($service1) }
        2 { $serviceNames = @($service2) }
        3 { $serviceNames = @($service3) }
        4 { $serviceNames = @($service4) }
        default { Write-Red "Invalid choice. Exiting script."; exit 1 }
    }
}

# List available services
$availableServices = @()
$missingServices = @()

foreach ($serviceName in $serviceNames) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($null -ne $service) {
        $availableServices += $serviceName
        Write-Green "Available service: $serviceName"
    } else {
        $missingServices += $serviceName
        Write-Red "Service $serviceName is missing from your computer."
    }
}


# Restart available services
foreach ($serviceName in $availableServices) {
    $initialService = Get-ServiceStatus $serviceName

    # Attempt to restart the service
    try {
        Write-Green "`nAttempting to restart the service '$serviceName'..."
        Restart-Service -Name $serviceName -Force -ErrorAction Stop
        Write-Green "Restart command executed successfully for '$serviceName'."
    } catch {
        $errorMessage = $_.Exception.Message  # Extract the error message
        Write-Red "Failed to restart the service '$serviceName'. Error: $errorMessage"
        continue
    }


    # Wait for a moment to allow the service to fully restart
    Start-Sleep -Seconds 5

    # Check status after restart
    $restartedService = Get-ServiceStatus $serviceName

    # Compare before and after status
    if ($initialService.Status -eq $restartedService.Status) {
        Write-Yellow "`nWarning: Service status did not change after restart attempt for '$serviceName'."
    } else {
        Write-Green "`nService status changed from $($initialService.Status) to $($restartedService.Status) for '$serviceName'."
    }
}

# Alert for missing services
if ($missingServices.Count -gt 0) {
    Write-Yellow "`nThe following services were missing and could not be managed: $($missingServices -join ', ')"
}

# Additional troubleshooting info
Write-Green "1. If issues persist, consider checking the service's log files or contacting the service vendor."
