# Firebase Migration Agent

## 🎯 Purpose
Manages Firebase Firestore schema migrations, data transformations, and database evolution for Mindful Living app. Ensures zero-downtime migrations and data integrity.

## 🔍 Responsibilities

### 1. Schema Migration
- Firestore collection structure changes
- Field additions, removals, and modifications
- Index creation and optimization
- Subcollection restructuring
- Document field type changes

### 2. Data Migration
- Bulk data transformations
- Content format updates
- Data cleaning and normalization
- Historical data preservation
- Rollback capability

### 3. Security Rules Updates
- Rules versioning
- Safe deployment of rule changes
- Rules testing and validation
- Access pattern optimization

### 4. Indexes Management
- Composite index creation
- Index optimization
- Query performance improvement
- Index cleanup

## 📋 Migration Workflow

### Phase 1: Planning & Assessment
```bash
# Backup current Firestore data
firebase firestore:export gs://hub4apps-mindfulliving-backups/$(date +%Y%m%d)

# Document current schema
firebase firestore:indexes > current_indexes.json
firebase firestore:rules get > current_rules.txt

# Analyze current usage
firebase firestore:stats
```

### Phase 2: Migration Script Development

#### Migration Template
```typescript
// backend/migrations/migration_YYYYMMDD_description.ts

import * as admin from 'firebase-admin';

interface MigrationConfig {
  name: string;
  version: string;
  description: string;
  author: string;
  date: string;
}

export class Migration_20250101_AddVoiceFields {
  private db: admin.firestore.Firestore;
  private config: MigrationConfig = {
    name: 'AddVoiceFields',
    version: '1.0.0',
    description: 'Add voice optimization fields to life_situations collection',
    author: 'migration-agent',
    date: '2025-01-01'
  };

  constructor() {
    this.db = admin.firestore();
  }

  /**
   * Execute the migration
   */
  async up(): Promise<void> {
    console.log(`Starting migration: ${this.config.name}`);

    const batch = this.db.batch();
    let count = 0;
    const batchSize = 500; // Firestore batch limit

    try {
      const snapshot = await this.db.collection('life_situations').get();

      console.log(`Processing ${snapshot.size} documents...`);

      for (const doc of snapshot.docs) {
        const data = doc.data();

        // Add new fields with default values
        const updates = {
          voiceKeywords: this.generateVoiceKeywords(data.title, data.tags),
          spokenTitle: this.createSpokenTitle(data.title),
          isVoiceOptimized: false,
          voicePopularity: 0,
          migratedAt: admin.firestore.FieldValue.serverTimestamp()
        };

        batch.update(doc.ref, updates);
        count++;

        // Commit batch every 500 documents
        if (count % batchSize === 0) {
          await batch.commit();
          console.log(`Migrated ${count} documents...`);
        }
      }

      // Commit remaining documents
      if (count % batchSize !== 0) {
        await batch.commit();
      }

      console.log(`✅ Migration complete: ${count} documents updated`);

      // Log migration completion
      await this.logMigration('completed', count);

    } catch (error) {
      console.error(`❌ Migration failed:`, error);
      await this.logMigration('failed', count, error);
      throw error;
    }
  }

  /**
   * Rollback the migration
   */
  async down(): Promise<void> {
    console.log(`Rolling back migration: ${this.config.name}`);

    const batch = this.db.batch();
    let count = 0;

    try {
      const snapshot = await this.db
        .collection('life_situations')
        .where('migratedAt', '!=', null)
        .get();

      for (const doc of snapshot.docs) {
        // Remove added fields
        batch.update(doc.ref, {
          voiceKeywords: admin.firestore.FieldValue.delete(),
          spokenTitle: admin.firestore.FieldValue.delete(),
          isVoiceOptimized: admin.firestore.FieldValue.delete(),
          voicePopularity: admin.firestore.FieldValue.delete(),
          migratedAt: admin.firestore.FieldValue.delete()
        });

        count++;

        if (count % 500 === 0) {
          await batch.commit();
          console.log(`Rolled back ${count} documents...`);
        }
      }

      if (count % 500 !== 0) {
        await batch.commit();
      }

      console.log(`✅ Rollback complete: ${count} documents reverted`);
      await this.logMigration('rolled_back', count);

    } catch (error) {
      console.error(`❌ Rollback failed:`, error);
      throw error;
    }
  }

  /**
   * Verify migration success
   */
  async verify(): Promise<boolean> {
    console.log('Verifying migration...');

    try {
      const snapshot = await this.db
        .collection('life_situations')
        .limit(10)
        .get();

      let verified = true;

      for (const doc of snapshot.docs) {
        const data = doc.data();

        // Check required fields exist
        if (!data.voiceKeywords || !data.spokenTitle) {
          console.error(`❌ Document ${doc.id} missing required fields`);
          verified = false;
        }

        // Validate field types
        if (!Array.isArray(data.voiceKeywords)) {
          console.error(`❌ Document ${doc.id} has invalid voiceKeywords type`);
          verified = false;
        }
      }

      if (verified) {
        console.log('✅ Migration verification passed');
      }

      return verified;

    } catch (error) {
      console.error('❌ Verification failed:', error);
      return false;
    }
  }

  // Helper methods
  private generateVoiceKeywords(title: string, tags: string[]): string[] {
    const keywords = new Set<string>();

    // Add words from title
    title.toLowerCase().split(' ').forEach(word => {
      if (word.length > 3) keywords.add(word);
    });

    // Add tags
    tags.forEach(tag => keywords.add(tag.toLowerCase()));

    return Array.from(keywords);
  }

  private createSpokenTitle(title: string): string {
    // Convert to more natural spoken format
    return title
      .replace(/&/g, 'and')
      .replace(/\//g, ' or ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private async logMigration(
    status: string,
    documentsAffected: number,
    error?: any
  ): Promise<void> {
    await this.db.collection('_migrations').add({
      ...this.config,
      status,
      documentsAffected,
      error: error?.message || null,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });
  }
}
```

### Phase 3: Testing Migration

#### Test Script
```typescript
// backend/migrations/test_migration.ts

import { Migration_20250101_AddVoiceFields } from './migration_20250101_add_voice_fields';

async function testMigration() {
  console.log('🧪 Testing migration in staging environment...\n');

  const migration = new Migration_20250101_AddVoiceFields();

  try {
    // Step 1: Backup current state
    console.log('1. Creating backup...');
    // Backup logic here

    // Step 2: Run migration
    console.log('\n2. Running migration...');
    await migration.up();

    // Step 3: Verify results
    console.log('\n3. Verifying migration...');
    const verified = await migration.verify();

    if (!verified) {
      throw new Error('Verification failed');
    }

    // Step 4: Test rollback
    console.log('\n4. Testing rollback...');
    await migration.down();

    // Step 5: Re-run migration
    console.log('\n5. Re-running migration...');
    await migration.up();

    console.log('\n✅ Migration test passed!');

  } catch (error) {
    console.error('\n❌ Migration test failed:', error);
    console.log('Rolling back changes...');
    await migration.down();
    process.exit(1);
  }
}

testMigration();
```

### Phase 4: Production Deployment

#### Deployment Script
```bash
#!/bin/bash
# File: deploy_migration.sh

set -e

MIGRATION_NAME=$1
ENVIRONMENT=${2:-production}

if [ -z "$MIGRATION_NAME" ]; then
    echo "Usage: ./deploy_migration.sh <migration_name> [environment]"
    exit 1
fi

echo "Deploying migration: $MIGRATION_NAME to $ENVIRONMENT"
echo "========================================================"

# Step 1: Backup
echo ""
echo "Step 1: Creating backup..."
BACKUP_PATH="gs://hub4apps-mindfulliving-backups/${ENVIRONMENT}/$(date +%Y%m%d_%H%M%S)"
firebase firestore:export $BACKUP_PATH --project $ENVIRONMENT

# Step 2: Deploy migration function
echo ""
echo "Step 2: Deploying migration function..."
cd backend/functions
npm run build
firebase deploy --only functions:runMigration --project $ENVIRONMENT

# Step 3: Run migration
echo ""
echo "Step 3: Running migration..."
echo "Do you want to proceed? (yes/no)"
read CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Migration cancelled"
    exit 0
fi

# Trigger migration
curl -X POST \
  "https://us-central1-hub4apps-mindfulliving.cloudfunctions.net/runMigration" \
  -H "Content-Type: application/json" \
  -d "{\"migration\": \"$MIGRATION_NAME\"}"

# Step 4: Monitor progress
echo ""
echo "Step 4: Monitoring migration progress..."
echo "Check Firebase Console for logs"
echo "URL: https://console.firebase.google.com/project/hub4apps-mindfulliving/functions/logs"

# Step 5: Verify
echo ""
echo "Step 5: Verifying migration..."
sleep 30  # Wait for migration to complete

curl -X POST \
  "https://us-central1-hub4apps-mindfulliving.cloudfunctions.net/verifyMigration" \
  -H "Content-Type: application/json" \
  -d "{\"migration\": \"$MIGRATION_NAME\"}"

echo ""
echo "✅ Migration deployment complete!"
echo "Backup location: $BACKUP_PATH"
```

## 📊 Common Migration Patterns

### Pattern 1: Adding New Fields
```typescript
async addFieldsToCollection(
  collectionName: string,
  newFields: Record<string, any>
): Promise<void> {
  const snapshot = await this.db.collection(collectionName).get();

  const batch = this.db.batch();
  let count = 0;

  for (const doc of snapshot.docs) {
    batch.update(doc.ref, newFields);
    count++;

    if (count % 500 === 0) {
      await batch.commit();
    }
  }

  if (count % 500 !== 0) {
    await batch.commit();
  }
}
```

### Pattern 2: Renaming Fields
```typescript
async renameField(
  collectionName: string,
  oldFieldName: string,
  newFieldName: string
): Promise<void> {
  const snapshot = await this.db.collection(collectionName).get();

  const batch = this.db.batch();

  for (const doc of snapshot.docs) {
    const data = doc.data();

    if (data[oldFieldName] !== undefined) {
      batch.update(doc.ref, {
        [newFieldName]: data[oldFieldName],
        [oldFieldName]: admin.firestore.FieldValue.delete()
      });
    }
  }

  await batch.commit();
}
```

### Pattern 3: Changing Field Types
```typescript
async convertFieldType(
  collectionName: string,
  fieldName: string,
  converter: (oldValue: any) => any
): Promise<void> {
  const snapshot = await this.db.collection(collectionName).get();

  const batch = this.db.batch();

  for (const doc of snapshot.docs) {
    const data = doc.data();

    if (data[fieldName] !== undefined) {
      const newValue = converter(data[fieldName]);
      batch.update(doc.ref, { [fieldName]: newValue });
    }
  }

  await batch.commit();
}

// Example usage:
// Convert string date to Timestamp
await convertFieldType('life_situations', 'createdAt', (oldValue) => {
  return admin.firestore.Timestamp.fromDate(new Date(oldValue));
});
```

### Pattern 4: Restructuring Data
```typescript
async restructureDocument(
  collectionName: string,
  restructure: (oldData: any) => any
): Promise<void> {
  const snapshot = await this.db.collection(collectionName).get();

  const batch = this.db.batch();

  for (const doc of snapshot.docs) {
    const oldData = doc.data();
    const newData = restructure(oldData);

    batch.set(doc.ref, newData, { merge: false });
  }

  await batch.commit();
}
```

### Pattern 5: Migrating to Subcollections
```typescript
async migrateToSubcollection(
  parentCollection: string,
  arrayField: string,
  subcollectionName: string
): Promise<void> {
  const snapshot = await this.db.collection(parentCollection).get();

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const arrayData = data[arrayField];

    if (Array.isArray(arrayData)) {
      // Create subcollection documents
      const batch = this.db.batch();

      arrayData.forEach((item, index) => {
        const subDocRef = doc.ref.collection(subcollectionName).doc();
        batch.set(subDocRef, {
          ...item,
          order: index,
          migratedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      });

      await batch.commit();

      // Remove array field from parent
      await doc.ref.update({
        [arrayField]: admin.firestore.FieldValue.delete()
      });
    }
  }
}
```

## 🔒 Security Rules Migration

### Rules Versioning
```javascript
// firestore.rules

rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Version tracking
    match /_schema/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }

    // Life Situations - Public read, admin write
    match /life_situations/{situationId} {
      allow read: if true;
      allow write: if request.auth != null &&
                     request.auth.token.admin == true;

      // Validate schema version
      allow write: if request.resource.data.schemaVersion == 2;
    }

    // User data - Private
    match /users/{userId} {
      allow read, write: if request.auth != null &&
                           request.auth.uid == userId;

      // User journal entries
      match /journal_entries/{entryId} {
        allow read, write: if request.auth != null &&
                             request.auth.uid == userId;

        // Validate required fields after migration
        allow create: if request.resource.data.keys().hasAll([
          'content', 'mood', 'createdAt'
        ]);
      }

      // Wellness tracking
      match /wellness_tracking/{trackingId} {
        allow read, write: if request.auth != null &&
                             request.auth.uid == userId;
      }
    }

    // Voice queries (analytics only)
    match /voice_queries/{queryId} {
      allow read: if request.auth != null &&
                    request.auth.token.admin == true;
      allow write: if false; // Only via Cloud Functions
    }

    // Migration tracking (admin only)
    match /_migrations/{migrationId} {
      allow read: if request.auth != null &&
                    request.auth.token.admin == true;
      allow write: if false; // Only via Cloud Functions
    }
  }
}
```

### Rules Deployment
```bash
#!/bin/bash
# File: deploy_rules.sh

echo "Deploying Firestore Rules"
echo "=========================="

# Step 1: Validate rules locally
echo "Validating rules..."
firebase firestore:rules validate firestore.rules

if [ $? -ne 0 ]; then
    echo "❌ Rules validation failed"
    exit 1
fi

# Step 2: Deploy to staging
echo ""
echo "Deploying to staging..."
firebase deploy --only firestore:rules --project staging

# Step 3: Test rules in staging
echo ""
echo "Testing rules in staging..."
# Run test suite
npm run test:rules

# Step 4: Deploy to production
echo ""
echo "Ready to deploy to production?"
read -p "Continue? (yes/no) " CONFIRM

if [ "$CONFIRM" == "yes" ]; then
    firebase deploy --only firestore:rules --project production
    echo "✅ Rules deployed to production"
else
    echo "Deployment cancelled"
fi
```

## 📊 Migration Report Template

```markdown
# Firebase Migration Report
**Migration**: [MIGRATION_NAME]
**Date**: [DATE]
**Environment**: Production/Staging
**Status**: ✅ Success / ❌ Failed

## Summary
- Collections Affected: [COUNT]
- Documents Migrated: [COUNT]
- Duration: [TIME]
- Rollback Available: Yes/No

## Changes

### Schema Changes
- **Collection**: `life_situations`
  - Added fields: `voiceKeywords`, `spokenTitle`, `voicePopularity`
  - Removed fields: None
  - Modified fields: None

### Data Transformations
1. Generated voice keywords from titles and tags
2. Created spoken versions of titles
3. Initialized voice popularity counters

### Index Changes
- Created composite index: `voicePopularity` (descending) + `lifeArea` (ascending)
- Removed unused index: [INDEX_NAME]

### Security Rules Changes
- Added validation for new voice fields
- Updated write permissions for analytics

## Verification

### Pre-Migration State
```json
{
  "totalDocuments": 1000,
  "sampleDocument": {
    "title": "Managing Work Stress",
    "tags": ["work", "stress", "balance"]
  }
}
```

### Post-Migration State
```json
{
  "totalDocuments": 1000,
  "migratedDocuments": 1000,
  "sampleDocument": {
    "title": "Managing Work Stress",
    "tags": ["work", "stress", "balance"],
    "voiceKeywords": ["managing", "work", "stress"],
    "spokenTitle": "Managing Work Stress",
    "voicePopularity": 0,
    "isVoiceOptimized": false
  }
}
```

## Performance Impact
- Query Performance: No change (indexes created)
- Read Operations: +2% (additional fields)
- Write Operations: No change
- Storage: +5KB per document

## Rollback Plan
If issues occur:
1. Run rollback script: `npm run migrate:down migration_20250101`
2. Restore from backup: `gs://...backup-path`
3. Revert security rules to previous version
4. Remove new indexes

## Issues Encountered
None / [DESCRIPTION]

## Recommendations
1. Monitor voice query performance
2. Optimize voice keywords after 1 week of usage data
3. Consider adding voice response caching

## Next Migration
**Planned**: [NEXT_MIGRATION_NAME]
**Date**: [ESTIMATED_DATE]
```

## 🚀 Quick Commands

```bash
# Create new migration
npm run migration:create add_new_field

# Test migration in staging
npm run migration:test migration_20250101

# Deploy migration
./deploy_migration.sh migration_20250101 production

# Rollback migration
npm run migration:rollback migration_20250101

# List all migrations
npm run migration:list

# Check migration status
npm run migration:status
```

## 🎯 Migration Checklist

### Before Migration
- [ ] Backup current Firestore data
- [ ] Document current schema
- [ ] Write migration script with up/down methods
- [ ] Create verification logic
- [ ] Test in staging environment
- [ ] Review security rules changes
- [ ] Create rollback plan
- [ ] Notify team of scheduled maintenance

### During Migration
- [ ] Monitor Firebase console
- [ ] Check for errors in logs
- [ ] Track progress metrics
- [ ] Be ready to rollback if needed

### After Migration
- [ ] Verify data integrity
- [ ] Check application functionality
- [ ] Monitor performance metrics
- [ ] Update documentation
- [ ] Log migration completion
- [ ] Keep backup for 30 days

## 📚 Resources
- [Firestore Data Migration Best Practices](https://firebase.google.com/docs/firestore/solutions/migrate)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Firestore Limits and Quotas](https://firebase.google.com/docs/firestore/quotas)

---

**Note**: Always test migrations in staging before production. Maintain backups for at least 30 days. Document all schema changes for team reference.
