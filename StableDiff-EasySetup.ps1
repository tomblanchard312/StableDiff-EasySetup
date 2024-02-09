<#
#Script: StableDiff-EasySetup.ps1
#Author: Tom Blanchard
#Date: February 10, 2024
#Description: This PowerShell script automates the installation of Git, Anaconda, Stable Diffusion, and the Stable Diffusion Web UI. It creates a new Anaconda environment, installs required packages, downloads a weight file, sets up the Stable Diffusion Web UI, and opens it in the default browser.
#
#Versions:
#- Git: Latest version (https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe)
#- Anaconda: Latest version (https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Windows-x86_64.exe)
#- Python: 3.8
#- PyTorch: Latest version with GPU support
#- Stable Diffusion: Latest version
#- Stable Diffusion Web UI: AUTOMATIC1111's version
#
#Instructions:
#1. Run this script in PowerShell to automate the installation process.
#2. Follow the prompts to enter the necessary information.
#3. The script will download dependencies, set up the environment, and open the Stable Diffusion Web UI in the default browser.
#
#Note: Adjust paths and file names as needed based on your specific environment configurations and requirements.
#>
# Check Internet Connectivity
$webRequest = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -ErrorAction SilentlyContinue
if ($webRequest.StatusCode -ne 200) {
    Write-Host "Error: No internet connection detected. Please connect to the internet and run the script again."
    exit
}
else {
    Write-Host "Internet connection detected. Starting installation script."
}
# Latest Git and Anaconda URLs
$gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
$anacondaInstallerUrl = "https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Windows-x86_64.exe"

# Installation directories
$gitInstallDir = "$env:ProgramFiles\Git"
$anacondaInstallDir = "$env:ProgramFiles\Anaconda3"

# Function to add Anaconda to PATH
function Add-AnacondaToPath {
    $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($envPath -notlike "*Anaconda3*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$anacondaInstallDir", [System.EnvironmentVariableTarget]::Machine)
    }
}

# Function to add Python to PATH
function Add-PythonToPath {
    $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($envPath -notlike "*Python*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$anacondaInstallDir\Scripts", [System.EnvironmentVariableTarget]::Machine)
    }
}

# Function to add Git to PATH
function Add-GitToPath {
    $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($envPath -notlike "*Git\cmd*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$gitInstallDir\cmd", [System.EnvironmentVariableTarget]::Machine)
    }
}

# Prompt user for environment name
$envName = Read-Host "Enter the environment name, ex: ldm"

# Check if Git is installed
if (Test-Path (Join-Path $env:ProgramFiles\Git\cmd 'git.exe')) {
    Write-Host "Git is already installed."
} else {
    # Git installation script
    $gitInstallerPath = Join-Path $env:USERPROFILE\Downloads 'Git-2.43.0-64-bit.exe'

    # Download Git installer
    Write-Host "Downloading Git..."
    Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $gitInstallerPath

    # Install Git
    Write-Host "Installing Git..."
    Start-Process -Wait -FilePath $gitInstallerPath -ArgumentList "/VERYSILENT", "/NORESTART", "/LOADINF=$gitInstallerPath.settings"

    # Remove the installer
    Remove-Item $gitInstallerPath
}

# Add Git to PATH
Add-GitToPath

# Check if Python is installed
if (Test-Path "$env:ProgramFiles\Anaconda3") {
    Write-Host "Anaconda is already installed."
} else {
    # Anaconda installation script
    $anacondaInstallerPath = Join-Path $env:USERPROFILE\Downloads 'Anaconda3-2023.09-0-Windows-x86_64.exe'

    # Download Anaconda installer
    Write-Host "Downloading Anaconda..."
    Invoke-WebRequest -Uri $anacondaInstallerUrl -OutFile $anacondaInstallerPath

    # Install Anaconda
    Write-Host "Installing Anaconda..."
    Start-Process -Wait -FilePath $anacondaInstallerPath -ArgumentList "/InstallationType=AllUsers", "/AddToPath=1", "/RegisterPython=1", "/S", "/D=$anacondaInstallDir"
    
    # Remove the installer
    Remove-Item $anacondaInstallerPath

    # Add Anaconda to PATH
    Add-AnacondaToPath
    Add-PythonToPath
}
# Reload PowerShell session with Bypass Execution Policy
Write-Host "Reloading PowerShell session..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-ExecutionPolicy Bypass -Scope Process -Force" -Verb RunAs

# Update Anaconda
Write-Host "Updating Anaconda..."
conda update -n base -c defaults conda

# Prompt user for model weights version
$weightsVersion = Read-Host "Enter 'lite' or 'full' for model weights version"

# Choose weight file URL based on user input
if ($weightsVersion -eq "lite") {
    $weightFileUrl = "https://huggingface.co/CompVis/stable-diffusion-v-1-4-original/resolve/main/sd-v1-4.ckpt"
} elseif ($weightsVersion -eq "full") {
    $weightFileUrl = "https://huggingface.co/CompVis/stable-diffusion-v-1-4-original/resolve/main/sd-v1-4-full-ema.ckpt"
} else {
    Write-Host "Invalid input. Exiting script."
    exit
}

# Prompt user for GPU option
$gpuOption = Read-Host "Enter 'cpu', 'amd', 'nvidia', or 'cuda' for GPU option"

# Choose PyTorch installation based on GPU option
switch ($gpuOption) {
    "cpu" { $pyTorchPackage = "cpuonly" }
    "amd" { $pyTorchPackage = "rocm" }
    "nvidia" {
        $pyTorchPackage = "torch==1.10.0 torchvision==0.11.1 torchaudio==0.10.0 cudatoolkit=11.1 -c pytorch"
        # Install CUDA for NVIDIA GPUs
        Write-Host "Downloading and installing CUDA Toolkit..."
        $cudaInstallerUrl = "https://developer.nvidia.com/compute/cuda/11.1.0/local_installers/cuda_11.1.0_456.81_win10.exe"
        $cudaInstallerPath = Join-Path $env:USERPROFILE\Downloads 'cuda_11.1.0_456.81_win10.exe'
        Invoke-WebRequest -Uri $cudaInstallerUrl -OutFile $cudaInstallerPath
        Start-Process -Wait -FilePath $cudaInstallerPath -ArgumentList "--override", "/silent"
        Remove-Item $cudaInstallerPath
    }
    "cuda" { $pyTorchPackage = "torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 -c pytorch" }
    default {
        Write-Host "Invalid input. Exiting script."
        exit
    }
}

# Create and activate conda environment
conda create -n $envName python=3.8
conda activate $envName

# Install PyTorch with GPU support
conda install pytorch torchvision torchaudio $pyTorchPackage -c pytorch

# Install Stable Diffusion
pip install stable-diffusion

# Create a directory for model weights
$modelDir = Join-Path "models" $envName
if (-not (Test-Path $modelDir)) {
    New-Item -Path $modelDir -ItemType Directory
}

# Download model weights
$weightFilePath = Join-Path $modelDir "model.ckpt"
Write-Host "Downloading model weights..."
Invoke-WebRequest -Uri $weightFileUrl -OutFile $weightFilePath

# Install Stable Diffusion Web UI
Write-Host "Cloning Stable Diffusion Web UI from AUTOMATIC1111..."
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Run Stable Diffusion Web UI setup
Write-Host "Setting up Stable Diffusion Web UI..."
cd stable-diffusion-webui
.\webui.bat setup

# Run Stable Diffusion Web UI
Write-Host "Running Stable Diffusion Web UI..."
.\webui-user.bat

cd $sdDirectory
python scripts/txt2img.py --prompt "a photograph of an astronaut riding a horse" --plms
# Credit: sample prompt courtesy of CompVis (https://github.com/CompVis/stable-diffusion)

# Provide instructions for running the web UI manually if needed
Write-Host "To run the web UI manually, execute webui-user.bat in the stable-diffusion-webui directory."
