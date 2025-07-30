# GitHub Secrets Setup Guide

## 🔐 Configure Android App Signing for GitHub Actions

To enable automatic signed APK generation in GitHub Actions, you need to configure the following secrets in your GitHub repository.

### 📋 Required GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, then add these secrets:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `KEYSTORE_BASE64` | Base64 encoded keystore file | `MIIKYAIBAzCCCgoGCSqGSIb3DQEHAa...` |
| `STORE_PASSWORD` | Keystore password | `your_store_password` |
| `KEY_ALIAS` | Key alias name | `key` |
| `KEY_PASSWORD` | Key password | `your_key_password` |

### 🔧 Step-by-Step Setup

#### 1. Get Base64 Encoded Keystore

The keystore file has already been encoded. Use this value for `KEYSTORE_BASE64`:

```
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
```

#### 2. Find Your Keystore Information

You need to provide the following information from your keystore:

- **Store Password**: The password used to create the keystore
- **Key Alias**: The alias name of your key (usually "key" or similar)
- **Key Password**: The password for the specific key

If you don't remember these values, you may need to create a new keystore.

#### 3. Create New Keystore (Optional)

If you need to create a new keystore:

```bash
keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

#### 4. Add Secrets to GitHub

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each of the four secrets listed above

### 🔄 How It Works

Once configured, the GitHub Actions workflow will:

1. ✅ Decode the keystore file from Base64
2. ✅ Create signing configuration files
3. ✅ Build signed release APKs
4. ✅ Upload signed APKs to releases

### 📱 Output Files

With signing configured, you'll get properly signed APKs:

- `friends-flutter-v27-release-{timestamp}-{hash}.apk` (Signed)
- `friends-flutter-v29-release-{timestamp}-{hash}.apk` (Signed)

### 🚨 Security Notes

- ✅ Keystore file is stored securely as a Base64 encoded secret
- ✅ Passwords are stored as encrypted GitHub secrets
- ✅ Secrets are never exposed in logs or outputs
- ✅ Only authorized collaborators can access secrets

### 🔍 Troubleshooting

If builds fail with signing errors:

1. Check that all four secrets are correctly set
2. Verify the keystore password is correct
3. Ensure the key alias matches your keystore
4. Check GitHub Actions logs for specific error messages

---

💡 **Note**: Without these secrets configured, the build will fall back to debug signing, which still produces working APKs but they won't be suitable for production distribution.