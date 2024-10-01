<# This Script was written on 01/10/2024.
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

# Function to write output in Yellow(General info)
function Write-Yellow($message) {
    Write-Host $message -ForegroundColor Yellow
}

# Function to get and display service status
function Get-ServiceStatus($serviceName) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Red "Service '$serviceName' not found."
        return $null
    }
    $status = $service.Status
    $startType = $service.StartType
    $processId = $service.ProcessId
    Write-Green "Current status of '$serviceName': $status"
    Write-Green "Start Type: $startType"
    Write-Yellow "Process ID: $(if ($null -eq $processId) { 'Not available' } else { $processId })"
    return $service
}

# Service name
$serviceName = "SBA Server"

# Check initial status
Write-Green "Checking initial status:"
$initialService = Get-ServiceStatus $serviceName
if ($null -eq $initialService) { exit }

# Attempt to restart the service
try {
    Write-Green "`nAttempting to restart the service..."
    Restart-Service -Name $serviceName -Force
    Write-Green "Restart command executed successfully."
} catch {
    Write-Red "Failed to restart the service. Error: $_"
    exit
}

# Wait for a moment to allow the service to fully restart
Start-Sleep -Seconds 5

# Check status after restart
Write-Green "`nChecking status after restart attempt:"
$restartedService = Get-ServiceStatus $serviceName

# Compare before and after status
if ($initialService.Status -eq $restartedService.Status) {
    Write-Yellow "`nWarning: Service status did not change after restart attempt."
} else {
    Write-Green "`nService status changed from $($initialService.Status) to $($restartedService.Status)."
}

# Additional verification
$processId = $restartedService.ProcessId
if ($null -ne $processId) {
    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
    if ($null -ne $process) {
        Write-Green "`nProcess details:"
        Write-Green "Name: $($process.Name)"
        Write-Green "ID: $($process.Id)"
        Write-Green "Start Time: $($process.StartTime)"
        Write-Green "CPU Time: $($process.TotalProcessorTime)"
    } else {
        Write-Red "`nWarning: Process with ID $processId not found."
    }
} else {
    Write-Yellow "`nNote: This service does not have an associated process ID."
    Write-Yellow "This can occur with certain types of services, such as shared process or driver services."
}

# Get dependent services
$dependentServices = Get-Service -Name $serviceName -DependentServices
if ($dependentServices) {
    Write-Green "`nDependent services:"
    foreach ($depService in $dependentServices) {
        Write-Green "$($depService.DisplayName) - Status: $($depService.Status)"
    }
} else {
    Write-Yellow "`nNo dependent services found."
}

# Additional troubleshooting info
Write-Green "`nAdditional troubleshooting information:"
Write-Green "1. Check the Windows Event Viewer for any related events."
Write-Green "2. Verify the service configuration in the Services console (services.msc)."
Write-Green "3. Ensure you have the necessary permissions to manage this service."
Write-Green "4. If issues persist, consider checking the service's log files or contacting the service vendor."