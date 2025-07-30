#!/bin/bash

# GitHub Actions signing setup script
# This script sets up Android app signing for GitHub Actions

set -e

echo "🔐 Setting up Android app signing..."

# Create signing directory if it doesn't exist
mkdir -p android/signing

# Decode the keystore from base64 (stored in GitHub Secrets)
if [ -n "$KEYSTORE_BASE64" ]; then
    echo "📁 Decoding keystore file..."
    echo "$KEYSTORE_BASE64" | base64 -d > android/signing/release.keystore
    echo "✅ Keystore file created"
else
    echo "❌ KEYSTORE_BASE64 environment variable not found"
    exit 1
fi

# Create keystore.properties file
echo "📝 Creating keystore.properties..."
cat > android/signing/keystore.properties << EOF
storeFile=../signing/release.keystore
storePassword=${STORE_PASSWORD}
keyAlias=${KEY_ALIAS}
keyPassword=${KEY_PASSWORD}
EOF

echo "✅ Signing configuration completed"
echo "📁 Keystore file: android/signing/release.keystore"
echo "📝 Properties file: android/signing/keystore.properties"