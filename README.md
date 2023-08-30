# FirstRepository
Azure ATP Sensor Cleanup Script
Description:
This PowerShell script is designed to help administrators cleanly uninstall and remove traces of the Azure Advanced Threat Protection (ATP) Sensor from their systems. It provides interactive prompts to guide users through each cleanup step, ensuring clarity and control throughout the process.

Features:
Uninstall Azure ATP Sensor: The script attempts to locate the setup executable of the Azure ATP Sensor in the ProgramData\Package Cache folder and runs the uninstall command.

Remove Services: The script identifies and removes the services related to Azure ATP Sensor, specifically aatpsensor and aatpsensorupdater.

Cleanup Package Cache: Any residual Azure ATP Sensor-related directories in the ProgramData\Package Cache folder are renamed for backup purposes.

Registry Cleanup: The script scans and removes specific registry entries associated with the Azure ATP Sensor.

User Interaction: At every step, the script asks for user confirmation before executing. This ensures that users have full control over what actions are taken.

Error Handling: Incorporated throughout the script to ensure that any issues during execution are reported back to the user, offering a more robust user experience.

Usage:
Prerequisites: Ensure you have PowerShell permissions to execute scripts on your system. If not, run PowerShell as an administrator and execute Set-ExecutionPolicy RemoteSigned to allow script execution.

Running the Script: Navigate to the location of the script in PowerShell and run it by typing .\script_name.ps1 (replace script_name.ps1 with the actual name of the script).

Follow the Prompts: The script will guide you through each step, asking for confirmation before executing any action. Read the prompts carefully and provide the necessary inputs.

Completion: Once all steps are complete, the script will display a "Sensor cleanup is done!" message.

Safety & Security:
The script is designed with safety in mind:

User Consent: Each significant action requires user approval, ensuring that unintended actions aren't taken inadvertently.

Error Reporting: If an issue arises during any operation, the script will report it to the user.

Script Signing: Users are advised to ensure the script's integrity via digital signatures. This ensures that the script hasn't been tampered with since its creation.

Note:
Before running any script, especially those that modify system settings or files, it's always a good practice to review the script contents and ensure you understand its operations. Make backups of essential data and system settings when possible.
