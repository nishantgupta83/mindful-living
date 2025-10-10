/**
 * Firebase Migration Script
 * Uploads transformed Mindful Living content to Firestore
 */

const admin = require('firebase-admin');
const fs = require('fs');

interface MindfulLifeSituation {
  id: string;
  title: string;
  description: string;
  lifeArea: string;
  difficulty: string;
  mindfulApproach: string;
  practicalSteps: string[];
  keyInsights: string[];
  tags: string[];
  voiceKeywords: string[];
  spokenTitle: string;
  estimatedReadTime: number;
  wellnessFocus: string[];
  created: string;
  updated: string;
}

async function uploadToFirestore(): Promise<void> {
  console.log('🔥 Firebase Migration: Uploading Mindful Living Content');
  console.log('======================================================');
  console.log('');

  // Initialize Firebase Admin SDK
  if (!admin.apps || admin.apps.length === 0) {
    const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS ||
                                './service-account-key.json';

    let credential;
    try {
      if (fs.existsSync(serviceAccountPath)) {
        const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf-8'));
        credential = admin.credential.cert(serviceAccount);
        console.log(`✅ Using service account: ${serviceAccountPath}`);
      } else {
        credential = admin.credential.applicationDefault();
        console.log('✅ Using application default credentials');
      }
    } catch (error) {
      console.log('⚠️  Falling back to application default credentials');
      credential = admin.credential.applicationDefault();
    }

    admin.initializeApp({
      credential,
      projectId: 'hub4apps-mindfulliving',
    });
  }

  const db = admin.firestore();

  // Read transformed content
  const data = fs.readFileSync('mindful_situations.json', 'utf-8');
  const situations: MindfulLifeSituation[] = JSON.parse(data);

  console.log(`📥 Loaded ${situations.length} situations`);
  console.log('');

  let count = 0;
  const BATCH_SIZE = 500;
  let batch = db.batch();

  console.log('🚀 Starting upload...');
  console.log('');

  for (const situation of situations) {
    const docRef = db.collection('life_situations').doc(situation.id);
    
    batch.set(docRef, {
      ...situation,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
      viewCount: 0,
      favoriteCount: 0,
    });

    count++;

    // Commit batch every 500 documents
    if (count % BATCH_SIZE === 0) {
      await batch.commit();
      console.log(`   ✅ Uploaded ${count}/${situations.length} situations...`);
      batch = db.batch(); // Create new batch for next iteration
    }
  }

  // Commit remaining documents
  if (count % BATCH_SIZE !== 0) {
    await batch.commit();
  }

  console.log('');
  console.log(`✅ Upload complete! ${situations.length} situations uploaded to Firestore`);
  console.log('');

  // Create metadata document
  const metadataRef = db.collection('metadata').doc('content_stats');
  await metadataRef.set({
    totalSituations: situations.length,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    version: '1.0.0',
    source: 'GitaWisdom (transformed)',
  });

  console.log('✅ Metadata created');
  console.log('');
  console.log('🎉 Migration complete!');
  console.log('');
  console.log('📊 Next Steps:');
  console.log('   1. Verify in Firebase Console: https://console.firebase.google.com/u/0/project/hub4apps-mindfulliving/firestore');
  console.log('   2. Create indexes: firebase deploy --only firestore:indexes');
  console.log('   3. Deploy security rules: firebase deploy --only firestore:rules');
  console.log('');
}

// Run migration
uploadToFirestore()
  .then(() => {
    console.log('✅ Success!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('');
    console.error('❌ Migration failed!');
    console.error('==================');
    console.error('');
    console.error('Error:', error.message);
    console.error('');
    console.error('💡 Troubleshooting:');
    console.error('   1. Ensure service-account-key.json exists in current directory');
    console.error('   2. Verify Firebase project ID: hub4apps-mindfulliving');
    console.error('   3. Check internet connection');
    console.error('   4. Run: firebase login');
    console.error('');
    process.exit(1);
  });
