# Google Drive Backup Setup Guide

This guide will help you configure Google Cloud Console to enable Google Drive backup functionality in the Internet Billing app.

## Prerequisites

- A Google account
- Access to [Google Cloud Console](https://console.cloud.google.com/)
- Your app's package name: `internet_billing` (or as defined in your `android/app/build.gradle`)

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project dropdown at the top
3. Click "NEW PROJECT"
4. Enter project name: `Internet Billing App`
5. Click "CREATE"
6. Wait for the project to be created and select it

## Step 2: Enable Google Drive API

1. In your project, go to "APIs & Services" > "Library"
2. Search for "Google Drive API"
3. Click on "Google Drive API"
4. Click "ENABLE"
5. Wait for the API to be enabled

## Step 3: Configure OAuth Consent Screen

1. Go to "APIs & Services" > "OAuth consent screen"
2. Select "External" user type
3. Click "CREATE"
4. Fill in the required information:
   - **App name**: Internet Billing
   - **User support email**: Your email
   - **Developer contact information**: Your email
5. Click "SAVE AND CONTINUE"
6. On "Scopes" page, click "ADD OR REMOVE SCOPES"
7. Search for "Google Drive API" and select:
   - `.../auth/drive.file` (View and manage Google Drive files and folders that you have opened or created with this app)
8. Click "UPDATE" then "SAVE AND CONTINUE"
9. On "Test users" page (optional for testing):
   - Click "ADD USERS"
   - Add your Google account email
   - Click "ADD" then "SAVE AND CONTINUE"
10. Click "BACK TO DASHBOARD"

## Step 4: Create OAuth 2.0 Credentials

### For Android:

1. Go to "APIs & Services" > "Credentials"
2. Click "CREATE CREDENTIALS" > "OAuth client ID"
3. Select "Android" as application type
4. Fill in the information:
   - **Name**: Internet Billing Android
   - **Package name**: `com.example.internet_billing` (check your `android/app/build.gradle`)
   - **SHA-1 certificate fingerprint**: See below how to get this

#### Getting SHA-1 Fingerprint:

**For Debug Build:**
```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 under "Variant: debug" > "Config: debug"

**For Release Build:**
```bash
keytool -list -v -keystore path/to/your/keystore.jks -alias your-key-alias
```

5. Click "CREATE"
6. Note down the Client ID (you won't need to add it to the app, but keep it for reference)

### For iOS (if needed):

1. Click "CREATE CREDENTIALS" > "OAuth client ID"
2. Select "iOS" as application type
3. Fill in:
   - **Name**: Internet Billing iOS
   - **Bundle ID**: Your iOS bundle identifier
4. Click "CREATE"

### For Web (for Google Sign-In):

1. Click "CREATE CREDENTIALS" > "OAuth client ID"
2. Select "Web application"
3. Fill in:
   - **Name**: Internet Billing Web
   - **Authorized JavaScript origins**: (leave empty for now)
   - **Authorized redirect URIs**: (leave empty for now)
4. Click "CREATE"
5. **IMPORTANT**: Copy the "Client ID" - you'll need this

## Step 5: Configure Your Flutter App

### Update `android/app/build.gradle`:

Make sure your package name matches what you entered in OAuth credentials:

```gradle
defaultConfig {
    applicationId "com.example.internet_billing"
    // ... other config
}
```

### No additional configuration needed!

The `google_sign_in` package will automatically use the OAuth credentials you created.

## Step 6: Test the Integration

1. Run your app on a physical Android device (Google Sign-In doesn't work well on emulators)
2. Go to Settings
3. Click "Connect" under Google Drive
4. Sign in with your Google account
5. Grant permissions when prompted
6. You should see "Connected to Google Drive" message

## Troubleshooting

### "Sign in failed" or "Error 10"
- Make sure SHA-1 fingerprint is correct
- Verify package name matches in OAuth credentials and `build.gradle`
- Try using a different Google account
- Make sure Google Drive API is enabled

### "Permission denied"
- Check OAuth consent screen is configured correctly
- Make sure you added the Drive scope (`.../auth/drive.file`)
- If using test users, make sure your account is added

### "API not enabled"
- Go back to "APIs & Services" > "Library"
- Search for "Google Drive API" and make sure it's enabled

### Still having issues?
- Delete and recreate OAuth credentials
- Make sure you're using a physical device, not an emulator
- Check that your app's package name is correct
- Verify the SHA-1 fingerprint matches your debug/release keystore

## Important Notes

1. **Testing**: During development, you can use "External" user type with test users
2. **Production**: Before publishing, you'll need to verify your app in OAuth consent screen
3. **Backup Folder**: Backups are stored in a folder called "InternetBillingBackups" in the user's Google Drive
4. **File Format**: Backups are SQLite database files (.db extension)
5. **Privacy**: Only the user who created the backup can access it

## Security Best Practices

- Never commit OAuth credentials to version control
- Use different OAuth clients for debug and release builds
- Regularly review and rotate credentials
- Implement proper error handling in the app
- Inform users about data being stored in their Google Drive

## Next Steps

Once setup is complete:
1. Test backup creation
2. Test backup restoration
3. Test with multiple Google accounts
4. Test backup deletion
5. Verify backups appear in Google Drive web interface

---

**Need Help?**
- [Google Cloud Console](https://console.cloud.google.com/)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google Drive API Documentation](https://developers.google.com/drive/api/v3/about-sdk)
