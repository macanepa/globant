#!/bin/bash

# Function to prompt the user for the AWS profile name
get_aws_profile_name() {
    read -p "Enter AWS profile name: " aws_profile_name
    if [ -z "$aws_profile_name" ]; then
        echo "AWS profile name cannot be empty."
        get_aws_profile_name
    fi
}

# Check if a profile name argument is provided
if [ $# -eq 0 ]; then
    get_aws_profile_name
else
    aws_profile_name="$1"
fi

# Run the AWS CLI command to get the caller identity using the specified profile
caller_identity=$(aws sts get-caller-identity --profile "$aws_profile_name")

# Extract the AWS account ID from the JSON response
aws_account_id=$(echo "$caller_identity" | jq -r '.Account')

# Check if the AWS account ID is not empty
if [ -n "$aws_account_id" ]; then
    echo "AWS Account ID for profile '$aws_profile_name': $aws_account_id"
    
    # Get the name of the parent folder (current directory)
    parent_folder_name=$(basename "$(pwd)")
    
    # AWS CLI command to log in to ECR (replace with your region)
    aws ecr get-login-password --profile $aws_profile_name  --region us-east-1 | docker login --username AWS --password-stdin "$aws_account_id.dkr.ecr.us-east-1.amazonaws.com"
    
    # Docker build command
    docker build -t "$parent_folder_name" .
    
    # Docker tag command
    docker tag "$parent_folder_name:latest" "$aws_account_id.dkr.ecr.us-east-1.amazonaws.com/$parent_folder_name:latest"
    
    # Docker push command
    docker push "$aws_account_id.dkr.ecr.us-east-1.amazonaws.com/$parent_folder_name:latest"
    
    echo "Docker image pushed to ECR repository."
else
    echo "Failed to retrieve AWS Account ID for profile '$aws_profile_name'."
fi
