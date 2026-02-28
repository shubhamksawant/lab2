#!/bin/bash

# --- Configuration ---
LOG_FILE="terraform_validate.log"
BASE_TF_DIR="terraform"  # This is the magic fix
SERVICES=("ec2" "ecs" "eks" "vpc")
ENVS=("dev" "qa" "prod")

# Clear previous logs
echo "Terraform Validation Report - $(date)" > "$LOG_FILE"
echo "===========================================" >> "$LOG_FILE"

# Track overall status
FAILED_COUNT=0
SUCCESS_COUNT=0

# --- Execution ---
for SERVICE in "${SERVICES[@]}"; do
    for ENV in "${ENVS[@]}"; do
        # Correct path: terraform/service/env
        RELATIVE_PATH="$BASE_TF_DIR/$SERVICE/$ENV"

        if [ -d "$RELATIVE_PATH" ]; then
            echo "--- Validating $RELATIVE_PATH ---"
            echo "Environment: $RELATIVE_PATH" >> "$LOG_FILE"
            
            # Move to directory
            cd "$RELATIVE_PATH" || continue

            # Initialize (plugin check only, no backend)
            # We use -input=false to prevent the script from hanging
            terraform init -backend=false -input=false > /dev/null 2>&1

            # Run validation
            # Capture output to log file if it fails
            VALIDATE_OUTPUT=$(terraform validate 2>&1)
            VALIDATE_STATUS=$?

            if [ $VALIDATE_STATUS -eq 0 ]; then
                echo "Result: SUCCESS" >> "../../../$LOG_FILE"
                ((SUCCESS_COUNT++))
            else
                echo "Result: FAILED" >> "../../../$LOG_FILE"
                echo "$VALIDATE_OUTPUT" >> "../../../$LOG_FILE"
                echo "Check $RELATIVE_PATH for issues."
                ((FAILED_COUNT++))
            fi

            echo "-------------------------------------------" >> "../../../$LOG_FILE"
            
            # Go back THREE levels (env -> service -> terraform -> iac)
            cd ../../../
        else
            echo "Skip: $RELATIVE_PATH (Directory not found)"
        fi
    done
done

# --- Summary ---
echo ""
echo "=== Validation Summary ==="
echo "Success: $SUCCESS_COUNT"
echo "Failed:  $FAILED_COUNT"
echo "Details: $LOG_FILE"

if [ $FAILED_COUNT -gt 0 ]; then
    exit 1
fi
