const admin = require('firebase-admin');
const fs = require('fs');

async function uploadToFirestore() {
  console.log('🔥 Firebase Migration: Uploading Mindful Living Content');
  console.log('======================================================');
  console.log('');

  // Initialize Firebase
  const serviceAccount = JSON.parse(fs.readFileSync('./service-account-key.json', 'utf-8'));
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'hub4apps-mindfulliving',
  });

  console.log(`✅ Connected to project: ${serviceAccount.project_id}`);
  console.log('');

  const db = admin.firestore();

  // Read transformed content
  const data = fs.readFileSync('mindful_situations.json', 'utf-8');
  const situations = JSON.parse(data);

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
      batch = db.batch(); // Create new batch
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
  console.log('📊 Verify at: https://console.firebase.google.com/u/0/project/hub4apps-mindfulliving/firestore');
  console.log('');
}

uploadToFirestore()
  .then(() => {
    console.log('✅ Success!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('');
    console.error('❌ Migration failed!');
    console.error('Error:', error.message);
    console.error('');
    process.exit(1);
  });
