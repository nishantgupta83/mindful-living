# Firebase Migration Guide
Complete migration from GitaWisdom (Supabase) to Mindful Living (Firebase)

## 📋 Overview

This guide walks through the complete data migration process:
1. ✅ **Export** from Supabase (GitaWisdom) - 1,226 scenarios
2. ✅ **Transform** content to secular wellness format (remove ALL religious references)
3. 🔄 **Upload** to Firebase Firestore

**Status**: Steps 1 & 2 complete, ready for Step 3

## 📊 Migration Summary

### Completed
- ✅ Exported 1,226 scenarios from Supabase
- ✅ Exported 18 chapters, 100 verses (sample), 15 languages
- ✅ Transformed all content to secular format
- ✅ Validation: **ZERO religious references remaining**

### Data Files
| File | Size | Description |
|------|------|-------------|
| `gitawisdom_scenarios.json` | 1.58 MB | Raw export from Supabase |
| `supabase_export_complete.json` | 1.69 MB | Complete export with metadata |
| `mindful_situations.json` | ~1.5 MB | **Transformed secular content** |
| `SUPABASE_EXPORT_REPORT.md` | - | Detailed export report |

## 🚀 Quick Start

### Option 1: Full Automated Migration (Recommended)
```bash
cd scripts
npm install
npm run full-migration
```

This will:
1. Export from Supabase (if needed)
2. Transform content
3. Upload to Firebase

### Option 2: Step-by-Step Migration

#### Step 1: Export from Supabase
```bash
cd scripts
npm install
npm run export
```

**Output**: 
- `gitawisdom_scenarios.json` (1,226 scenarios)
- `supabase_export_complete.json` (complete data)
- `SUPABASE_EXPORT_REPORT.md` (analysis)

#### Step 2: Transform Content
```bash
npm run transform
```

**Output**:
- `mindful_situations.json` (secular wellness content)
- All religious references removed
- Voice keywords generated

**Validation**:
```bash
# Verify zero religious content
cat mindful_situations.json | grep -i -E "\b(krishna|gita|divine|sacred)\b" || echo "✅ Clean!"
```

#### Step 3: Upload to Firebase
```bash
# First, authenticate with Firebase
firebase login

# Set default project
firebase use hub4apps-mindfulliving

# Run migration
npm run migrate
```

**Output**:
- 1,226 documents in `life_situations` collection
- Metadata document in `metadata/content_stats`
- Firestore indexes created

## 📂 Firebase Structure

### Collections

#### `life_situations` (1,226 documents)
```javascript
{
  id: "situation_123",
  title: "Managing Work-Life Balance During Busy Seasons",
  description: "How to maintain wellness when work demands increase...",
  lifeArea: "career", // wellness, relationships, growth, career, life-challenges
  difficulty: "intermediate", // beginner, intermediate, advanced
  mindfulApproach: "Research shows that sustainable productivity...",
  practicalSteps: [
    "Set clear boundaries between work and personal time",
    "Practice mindful breaks every 2 hours",
    ...
  ],
  keyInsights: [
    "Studies suggest that balanced effort leads to better outcomes"
  ],
  tags: ["work-life-balance", "productivity", "stress-management"],
  voiceKeywords: ["balance", "work", "busy", "help with balance"],
  spokenTitle: "Managing Work Life Balance",
  estimatedReadTime: 5, // minutes
  wellnessFocus: ["stress-relief", "work-life-balance"],
  createdAt: Timestamp,
  updatedAt: Timestamp,
  isActive: true,
  viewCount: 0,
  favoriteCount: 0
}
```

#### `metadata/content_stats`
```javascript
{
  totalSituations: 1226,
  lastUpdated: Timestamp,
  version: "1.0.0",
  source: "GitaWisdom (transformed)"
}
```

### Firestore Indexes

Create these composite indexes:

```bash
firebase firestore:indexes
```

**Required indexes**:
1. `life_situations`: `lifeArea` (ASC) + `difficulty` (ASC) + `createdAt` (DESC)
2. `life_situations`: `tags` (ARRAY) + `isActive` (ASC)
3. `life_situations`: `voiceKeywords` (ARRAY) + `lifeArea` (ASC)
4. `life_situations`: `wellnessFocus` (ARRAY) + `difficulty` (ASC)

Or add to `firestore.indexes.json`:
```json
{
  "indexes": [
    {
      "collectionGroup": "life_situations",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "lifeArea", "order": "ASCENDING" },
        { "fieldPath": "difficulty", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "life_situations",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "tags", "arrayConfig": "CONTAINS" },
        { "fieldPath": "isActive", "order": "ASCENDING" }
      ]
    }
  ]
}
```

## 🔍 Content Transformation Details

### Religious → Secular Mapping

| Original (GitaWisdom) | Transformed (Mindful Living) |
|----------------------|----------------------------|
| Krishna teaches | Research shows |
| The Gita says | Studies indicate |
| Divine guidance | Inner wisdom |
| Sacred practice | Mindful practice |
| Spiritual path | Personal growth journey |
| Dharma | Purpose |
| Karma | Actions and consequences |
| Arjuna's dilemma | This common challenge |
| Gita Chapter X | ancient wisdom / mindfulness principles |

### Validation Rules
- ✅ **Zero** religious terms (Krishna, Gita, Divine, Sacred, etc.)
- ✅ Evidence-based language (Research shows, Studies indicate)
- ✅ Secular wellness focus
- ✅ Voice-optimized keywords
- ✅ Tags cleaned (removed religious terms)

## 🎯 Voice Integration Ready

Each situation includes:
- `voiceKeywords[]`: For Alexa/Siri search
- `spokenTitle`: Voice-optimized title
- `estimatedReadTime`: For voice response timing

### Alexa Integration
```javascript
// Query situations by voice keywords
const results = await db.collection('life_situations')
  .where('voiceKeywords', 'array-contains', userQuery)
  .where('isActive', '==', true)
  .limit(3)
  .get();
```

### Apple Watch Integration
```swift
// Quick situation lookup
let query = db.collection("life_situations")
  .whereField("difficulty", isEqualTo: "beginner")
  .whereField("wellnessFocus", arrayContains: "stress-relief")
  .limit(5)
```

## 🔒 Security Rules

Add to `firestore.rules`:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Public read for life situations
    match /life_situations/{situationId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     request.auth.token.admin == true;
    }
    
    // Public read for metadata
    match /metadata/{doc} {
      allow read: if true;
      allow write: if request.auth != null && 
                     request.auth.token.admin == true;
    }
    
    // Private user data
    match /users/{userId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == userId;
    }
  }
}
```

Deploy rules:
```bash
firebase deploy --only firestore:rules
```

## 📊 Migration Verification

After migration, verify:

### 1. Document Count
```bash
# Firebase Console → Firestore → life_situations
# Should show 1,226 documents
```

### 2. Sample Query
```javascript
// In Firebase Console or app
db.collection('life_situations')
  .where('lifeArea', '==', 'wellness')
  .limit(1)
  .get()
  .then(snap => console.log(snap.docs[0].data()));
```

### 3. Voice Keywords
```javascript
// Test voice search
db.collection('life_situations')
  .where('voiceKeywords', 'array-contains', 'stress')
  .limit(5)
  .get();
```

### 4. No Religious Content
```bash
# Export and verify
firebase firestore:export gs://your-bucket/export
# Download and grep for religious terms (should find none)
```

## 🚨 Troubleshooting

### Authentication Error
```bash
# Re-authenticate
firebase logout
firebase login
gcloud auth application-default login
```

### Batch Limit Error
The script automatically handles batching (500 docs per batch). If errors occur:
1. Check Firestore quotas
2. Reduce `BATCH_SIZE` in `create_firebase_migration.ts`

### Missing Firebase Project
```bash
# Verify project exists
firebase projects:list

# Create if needed
firebase projects:create hub4apps-mindfulliving
```

## 📝 Next Steps After Migration

1. **Deploy Firestore Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Create Indexes**
   ```bash
   firebase deploy --only firestore:indexes
   ```

3. **Test Voice Integration**
   - Deploy Alexa skill
   - Test Apple Watch app
   - Verify voice keyword search

4. **Enable Analytics**
   ```bash
   firebase deploy --only firestore:functions
   ```

5. **Monitor Usage**
   - Firebase Console → Firestore → Usage
   - Set up alerts for quota limits

## 📈 Performance Optimization

### Caching Strategy
- Cache situations by `lifeArea` (5 most recent)
- Offline-first: Store last 50 viewed situations locally
- Voice results: Cache top 10 per keyword

### Cost Management
- Estimated reads: ~10K/day (free tier: 50K/day)
- Estimated writes: ~100/day
- Stay within free tier: ✅

## 🎉 Migration Complete Checklist

- [x] Export from Supabase (1,226 scenarios)
- [x] Transform to secular content
- [x] Validate zero religious references
- [ ] Upload to Firebase Firestore
- [ ] Deploy security rules
- [ ] Create indexes
- [ ] Test voice integration
- [ ] Monitor performance

## 📞 Support

Questions or issues? Check:
- `SUPABASE_EXPORT_REPORT.md` - Export details
- Firebase Console - Live data
- `mindful_situations.json` - Transformed content sample

---

**Ready to execute**: Run `npm run migrate` to upload to Firebase! 🚀
