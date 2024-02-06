# StableDiff-EasySetup
Powershell Script to Setup Stable Diffusion on Windows

## Description

This PowerShell script automates the installation of Git, Anaconda, Stable Diffusion, and the Stable Diffusion Web UI. It creates a new Anaconda environment, installs required packages, downloads a weight file, sets up the Stable Diffusion Web UI, and opens it in the default browser.

## Versions

- Git: Latest version ([Download Git](https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe))
- Anaconda: Latest version ([Download Anaconda](https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Windows-x86_64.exe))
- Python: 3.8
- PyTorch: Latest version with GPU support
- Stable Diffusion: Latest version
- Stable Diffusion Web UI: AUTOMATIC1111's version

## Instructions

1. Run this script in PowerShell to automate the installation process.
2. Follow the prompts to enter the necessary information.
3. The script will download dependencies, set up the environment, and open the Stable Diffusion Web UI in the default browser.

**Note:** Adjust paths and file names as needed based on your specific environment configurations and requirements.

## Script Usage

1. Clone this repository:

    ```powershell
    git clone https://github.com/YourUsername/YourRepository.git
    ```
2. Navigate to the repository directory:

    ```powershell
    cd YourRepository
    ```

3. Run the script with bypassing execution policy:

    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\StableDiff-EasySetup.ps1
    ```

4. Follow the prompts to complete the installation.

**Important Note:**
- Make sure to review and modify the script according to your requirements.
- Ensure PowerShell execution policy allows script execution.



# Important Note
- Make sure to review and modify the script according to your requirements.
- Ensure PowerShell execution policy allows script execution.

# License

This script is provided under the [MIT License](https://mit-license.org/).
