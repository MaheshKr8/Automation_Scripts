# Azure Role Assignment Automation

Automates assigning Azure RBAC roles to Azure AD groups across multiple subscriptions.  
Supports **dry-run mode**, avoids duplicate assignments, and skips missing groups gracefully.  

---

## Features
- Multiple subscriptions via `subscriptions.txt`
- Multiple groups and roles via `mappings.csv`
- Dry-run mode (default) to preview changes
- Duplicate role assignments skipped
- Uses group Object IDs (no ambiguity)

---

## Repository Structure
├── main.sh # Main automation script
├── subscriptions.txt # Subscription IDs (one per line)
├── mappings.csv # Group → Role mapping
└── README.md


---

## Prerequisites
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed  
- Logged in with `az login`  
- User has role assignment permissions (e.g., Owner or User Access Administrator)  

---

## Input Files

### `subscriptions.txt`
d199062a-9d18-43ed-bee5-666c1b771e79
4b73bb5c-25e2-4784-9f8c-66a7f53fd7aa


### `mappings.csv`
group,roles

department_rg,Contributor;Monitoring Reader
staff_rg,Reader
finance_rg,Reader;Storage Blob Data Reader

---

## Usage

### Dry Run (default)
./main.sh

### Apply Changes
DRY_RUN=false ./main.sh

## Example Output

Dry run:
DEBUG: DRY_RUN=true
🔄 Switching to subscription: d199062a-9d18-43ed-bee5-666c1b771e79
ℹ Found group: department_rg
[DRY RUN] Would assign role 'Contributor' to group: department_rg
[DRY RUN] Would assign role 'Monitoring Reader' to group: department_rg


Apply:
DEBUG: DRY_RUN=false
🔄 Switching to subscription: d199062a-9d18-43ed-bee5-666c1b771e79
ℹ Found group: department_rg
➡ Assigning role 'Contributor' to group: department_rg
✅ Role 'Contributor' successfully assigned


## Notes
- Groups not found in Azure AD will be skipped.  
- Safe to rerun; duplicate assignments are ignored.  
==============================================


# vi mappings.csv
group,roles

department_rg,Contributor;Monitoring Reader
staff_rg,Reader
finance_rg,Reader;Storage Blob Data Reader

# vi subscriptions.txt 
d199062a-9d18-43ed-bee5-666c1b771e79

falfdlkd-lakjdkla-dklajkfd-dkladjall

# Dry run (default):
./main.sh

# Apply changes:
DRY_RUN=false ./main.sh


