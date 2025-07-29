#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

echo -e "${BLUE}🚀 WordPress 3-Tier Infrastructure Deployment${NC}"
echo "=================================================="

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found. Please copy from terraform.tfvars.example"
    exit 1
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Apply plan 

echo "🏗️  Applying infrastructure..."
terraform apply tfplan

echo -e "${GREEN}✅ Deployment completed!${NC}"
echo -e "${GREEN}🌐 Website URL: $(terraform output -raw website_url)${NC}"
echo -e "${GREEN}📊 Dashboard URL: $(terraform output -raw dashboard_url)${NC}"