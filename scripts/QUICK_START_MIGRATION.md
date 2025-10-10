# 🚀 Quick Start: Execute Firebase Migration

## Step 1: Download Service Account Key

### Via Firebase Console (Browser):
1. Go to: https://console.firebase.google.com/u/0/project/hub4apps-mindfulliving/settings/serviceaccounts/adminsdk
2. Click **"Generate new private key"**
3. Click **"Generate key"** in the confirmation dialog
4. Save the downloaded JSON file as: `service-account-key.json`
5. Move it to: `/Users/nishantgupta/Documents/MindfulLiving/app/scripts/`

### Alternative: Use Firebase CLI
```bash
cd /Users/nishantgupta/Documents/MindfulLiving/app/scripts
firebase apps:sdkconfig --project hub4apps-mindfulliving
```

## Step 2: Execute Migration

```bash
cd /Users/nishantgupta/Documents/MindfulLiving/app/scripts
npm run migrate
```

**Expected Output:**
```
🔥 Firebase Migration: Uploading Mindful Living Content
======================================================

Using service account: ./service-account-key.json
📥 Loaded 1226 situations

🚀 Starting upload...

   ✅ Uploaded 500/1226 situations...
   ✅ Uploaded 1000/1226 situations...

✅ Upload complete! 1226 situations uploaded to Firestore

📊 Creating indexes...
✅ Metadata created

🎉 Migration complete!
```

## Step 3: Verify in Firebase Console

1. **Check Documents**: https://console.firebase.google.com/u/0/project/hub4apps-mindfulliving/firestore/databases/-default-/data
   - Collection: `life_situations`
   - Expected: **1,226 documents**

2. **Check Metadata**: 
   - Collection: `metadata`
   - Document: `content_stats`
   - Field: `totalSituations` = 1226

## Step 4: Create Indexes

```bash
firebase deploy --only firestore:indexes
```

## 🎯 That's it!

Your 1,226 secular wellness situations are now in Firebase Firestore, ready for:
- Flutter app queries
- Alexa voice search
- Apple Watch integration

---

**⏱️ Total Time**: 2-3 minutes
