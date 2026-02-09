#!/bin/bash

# OpenRight Backend Setup Script
# This script helps set up Cloudflare Workers KV namespaces

echo "🚀 OpenRight Backend Setup"
echo "=========================="
echo ""

# Check if wrangler is installed
if ! command -v npx &> /dev/null; then
    echo "❌ Error: Node.js/npm not found. Please install Node.js first."
    exit 1
fi

echo "📦 Step 1: Installing dependencies..."
npm install
echo "✅ Dependencies installed"
echo ""

echo "🔧 Step 2: Creating KV namespaces..."
echo ""
echo "Creating production KV namespace..."
PROD_OUTPUT=$(npx wrangler kv namespace create "LINKS" 2>&1)
echo "$PROD_OUTPUT"
PROD_ID=$(echo "$PROD_OUTPUT" | grep -oE 'id = "[^"]+' | cut -d'"' -f2)

echo ""
echo "Creating preview KV namespace..."
PREVIEW_OUTPUT=$(npx wrangler kv namespace create "LINKS" --preview 2>&1)
echo "$PREVIEW_OUTPUT"
PREVIEW_ID=$(echo "$PREVIEW_OUTPUT" | grep -oE 'preview_id = "[^"]+' | cut -d'"' -f2)

echo ""
echo "✅ KV namespaces created!"
echo ""
echo "📝 Step 3: Updating wrangler.toml..."

# Update wrangler.toml with the namespace IDs
if [ -n "$PROD_ID" ] && [ -n "$PREVIEW_ID" ]; then
    # Backup original file
    cp wrangler.toml wrangler.toml.backup
    
    # Replace the placeholder IDs
    sed -i.tmp "s/YOUR_KV_NAMESPACE_ID/$PROD_ID/g" wrangler.toml
    sed -i.tmp "s/YOUR_PREVIEW_KV_NAMESPACE_ID/$PREVIEW_ID/g" wrangler.toml
    rm wrangler.toml.tmp
    
    echo "✅ wrangler.toml updated with KV namespace IDs"
    echo ""
    echo "Production ID: $PROD_ID"
    echo "Preview ID: $PREVIEW_ID"
else
    echo "⚠️  Warning: Could not automatically extract KV namespace IDs."
    echo "Please manually update wrangler.toml with the IDs shown above."
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review wrangler.toml to ensure KV namespace IDs are set"
echo "2. Run 'npm run dev' to start the development server"
echo "3. Visit http://localhost:8787 to test the API"
echo ""
echo "To deploy to production:"
echo "1. Run 'npx wrangler login' to authenticate"
echo "2. Run 'npm run deploy' to deploy your worker"
echo ""
