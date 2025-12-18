#!/bin/bash

# Script to set up privacy policy on GitHub Pages
# This will create a new repository and push the privacy policy

echo "🚀 Setting up Privacy Policy on GitHub Pages"
echo ""
echo "This script will help you push privacy-policy.html to GitHub Pages"
echo ""

# Check if privacy-policy.html exists
if [ ! -f "privacy-policy.html" ]; then
    echo "❌ Error: privacy-policy.html not found!"
    exit 1
fi

echo "📝 Step 1: Create a new GitHub repository"
echo "   Go to: https://github.com/new"
echo "   Repository name: voxanote-privacy (or any name you prefer)"
echo "   Make it PUBLIC (required for GitHub Pages)"
echo "   DO NOT initialize with README, .gitignore, or license"
echo "   Click 'Create repository'"
echo ""
read -p "Press Enter after you've created the repository..."

echo ""
echo "📤 Step 2: Pushing privacy policy to GitHub..."
echo ""

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    git init
fi

# Add privacy policy
git add privacy-policy.html

# Commit
git commit -m "Add privacy policy for App Store submission"

# Add remote (user will need to replace with their actual repo URL)
echo ""
echo "🔗 Step 3: Add your GitHub repository"
echo "   Replace 'voxanote-privacy' with your actual repository name"
echo ""
read -p "Enter your repository name (e.g., voxanote-privacy): " REPO_NAME

if [ -z "$REPO_NAME" ]; then
    REPO_NAME="voxanote-privacy"
fi

# Remove existing remote if it exists
git remote remove origin 2>/dev/null

# Add new remote
git remote add origin "https://github.com/peetza12/${REPO_NAME}.git"

echo ""
echo "📤 Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "✅ Privacy policy pushed to GitHub!"
echo ""
echo "🌐 Step 4: Enable GitHub Pages"
echo "   1. Go to: https://github.com/peetza12/${REPO_NAME}/settings/pages"
echo "   2. Under 'Source', select 'Deploy from a branch'"
echo "   3. Select branch: 'main'"
echo "   4. Select folder: '/ (root)'"
echo "   5. Click 'Save'"
echo ""
echo "⏳ Wait 1-2 minutes for GitHub Pages to deploy"
echo ""
echo "🔗 Your Privacy Policy URL will be:"
echo "   https://peetza12.github.io/${REPO_NAME}/privacy-policy.html"
echo ""
echo "✅ Use this URL in App Store Connect!"
