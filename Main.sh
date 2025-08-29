#!/bin/bash
set -euo pipefail

# ================================
# Configurable input files
# ================================
SUBS_FILE="subscriptions.txt"   # contains subscription IDs (one per line)
MAPPING_FILE="mappings.csv"     # CSV file: group,roles
DRY_RUN=${DRY_RUN:-true}        # default is dry-run mode unless overridden

echo "DEBUG: DRY_RUN=$DRY_RUN"

# ================================
# Main Loop: Subscriptions & Mappings
# ================================
while read -r SUBSCRIPTION_ID; do
    if [[ -z "$SUBSCRIPTION_ID" ]]; then
        continue
    fi

    echo "🔄 Switching to subscription: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"

    # Read mappings.csv (skip header row)
    tail -n +2 "$MAPPING_FILE" | while IFS=',' read -r GROUP ROLE_LIST; do
        if [[ -z "$GROUP" || -z "$ROLE_LIST" ]]; then
            continue
        fi

        # Check if group exists
        GROUP_ID=$(az ad group show --group "$GROUP" --query "id" -o tsv 2>/dev/null || true)
        if [ -z "$GROUP_ID" ]; then
            echo "❌ Group '$GROUP' does not exist. Skipping..."
            continue
        fi
        echo "ℹ Found group: $GROUP"

        # Split multiple roles by semicolon (;)
        IFS=';' read -ra ROLES <<< "$ROLE_LIST"

        for ROLE_NAME in "${ROLES[@]}"; do
            ROLE_NAME=$(echo "$ROLE_NAME" | xargs) # trim whitespace

            if [ "$DRY_RUN" = "true" ]; then
                echo "[DRY RUN] Would check and assign role '$ROLE_NAME' to group: $GROUP in subscription $SUBSCRIPTION_ID"
            else
                # Check if role already exists
                EXISTS=$(az role assignment list \
                    --assignee-object-id "$GROUP_ID" \
                    --role "$ROLE_NAME" \
                    --scope "/subscriptions/$SUBSCRIPTION_ID" \
                    --query "[].id" -o tsv 2>/dev/null || true)

                if [ -n "$EXISTS" ]; then
                    echo "✅ Role '$ROLE_NAME' already assigned to group: $GROUP (skipping)"
                else
                    echo "➡ Assigning role '$ROLE_NAME' to group: $GROUP in subscription $SUBSCRIPTION_ID"
                    az role assignment create \
                        --assignee-object-id "$GROUP_ID" \
                        --assignee-principal-type Group \
                        --role "$ROLE_NAME" \
                        --scope "/subscriptions/$SUBSCRIPTION_ID" \
                        --only-show-errors \
                        --output none
                fi
            fi
        done
    done

done < "$SUBS_FILE"

echo "🎯 Script execution completed (DRY_RUN=$DRY_RUN)"

