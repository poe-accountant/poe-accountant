#!/usr/bin/env bash

# Setup environment variables script
# This script copies .env.example to .env and prompts user to edit it

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_EXAMPLE_FILE="$PROJECT_ROOT/.env.example"
ENV_FILE="$PROJECT_ROOT/.env"

echo "🔧 Setting up environment variables..."

# Check if .env.example exists
if [[ ! -f "$ENV_EXAMPLE_FILE" ]]; then
    echo "❌ Error: .env.example file not found at $ENV_EXAMPLE_FILE"
    exit 1
fi

# Check if .env already exists
if [[ -f "$ENV_FILE" ]]; then
    echo "⚠️  Warning: .env file already exists at $ENV_FILE"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Aborted. Existing .env file was not modified."
        exit 1
    fi
fi

# Copy .env.example to .env
echo "📋 Copying .env.example to .env..."
cp "$ENV_EXAMPLE_FILE" "$ENV_FILE"

echo "✅ Successfully created .env file"
echo ""
echo "📝 IMPORTANT: You need to edit the .env file with your actual values!"
echo "   File location: $ENV_FILE"
echo ""

# Prompt user to edit the file
read -p "Please edit the .env file now and press Enter when you're done..." -r
echo ""

# Confirm they have edited it
echo "🔍 Have you updated the .env file with your actual values?"
echo "   (Make sure to replace placeholder values like 'your_digitalocean_token_here')"
read -p "Confirm you have edited the file (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Please edit the .env file before proceeding."
    echo "   Run this script again after editing: $0"
    exit 1
fi

echo "✅ Environment setup finished!"
