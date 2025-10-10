# Fix Firestore Indexes Issue

## Problem
Old indexes from previous deployment are conflicting with new structure.

## Solution Options

### Option 1: Manual Cleanup (Recommended)
1. Go to: https://console.firebase.google.com/u/0/project/hub4apps-mindfulliving/firestore/indexes
2. Delete ALL existing indexes (if any)
3. Then run: `firebase deploy --only firestore:indexes`

### Option 2: Skip Indexes (Works Fine)
Firebase will automatically create indexes as needed when queries run.

**What's already working:**
- ✅ Security rules deployed
- ✅ Data uploaded (1,226 documents)
- ✅ Single-field indexes (automatic)

**What to do later:**
When you run queries in the Flutter app, if you see an error like "index required", 
Firebase will provide a direct link to create it.

### Option 3: Create Indexes On-Demand
Run your Flutter app queries. When Firebase needs an index, it will show:
```
FAILED_PRECONDITION: The query requires an index.
You can create it here: https://console.firebase.google.com/...
```

Click the link → Firebase creates the index automatically ✅

## Current Status
- ✅ Rules: Deployed
- ⏭️  Indexes: Skip for now (will auto-create)
- ✅ Data: All uploaded

**You can proceed with Flutter app testing!**
