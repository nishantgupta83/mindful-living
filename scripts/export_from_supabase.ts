/**
 * Supabase to Firebase Migration Script
 * Export data from GitaWisdom Supabase database
 */

import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';

// Supabase configuration (will be provided by user)
const SUPABASE_URL = process.env.SUPABASE_URL || '';
const SUPABASE_KEY = process.env.SUPABASE_KEY || '';

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('❌ Error: Supabase credentials not provided!');
  console.log('');
  console.log('Set environment variables:');
  console.log('  export SUPABASE_URL="your-project-url"');
  console.log('  export SUPABASE_KEY="your-anon-key"');
  console.log('');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

interface GitaWisdomSchema {
  scenarios: any[];
  chapters: any[];
  verses: any[];
  userProfiles?: any[];
  journalEntries?: any[];
}

async function exportFromSupabase(): Promise<void> {
  console.log('📥 Exporting data from Supabase...');
  console.log('==================================');
  console.log('');

  const exportData: GitaWisdomSchema = {
    scenarios: [],
    chapters: [],
    verses: [],
    userProfiles: [],
    journalEntries: [],
  };

  try {
    // Export scenarios
    console.log('📦 Exporting scenarios...');
    const { data: scenarios, error: scenariosError } = await supabase
      .from('scenarios')
      .select('*')
      .gte('quality_score', 70); // Only high quality scenarios

    if (scenariosError) throw scenariosError;

    exportData.scenarios = scenarios || [];
    console.log(`   ✅ Exported ${exportData.scenarios.length} scenarios`);

    // Export chapters
    console.log('📦 Exporting chapters...');
    const { data: chapters, error: chaptersError } = await supabase
      .from('chapters')
      .select('*');

    if (chaptersError) throw chaptersError;

    exportData.chapters = chapters || [];
    console.log(`   ✅ Exported ${exportData.chapters.length} chapters`);

    // Export verses
    console.log('📦 Exporting verses...');
    const { data: verses, error: versesError } = await supabase
      .from('gita_verses')
      .select('*');

    if (versesError) throw versesError;

    exportData.verses = verses || [];
    console.log(`   ✅ Exported ${exportData.verses.length} verses`);

    // Export user profiles (if needed for migration)
    console.log('📦 Exporting user profiles...');
    const { data: profiles, error: profilesError } = await supabase
      .from('user_profiles')
      .select('*');

    if (!profilesError && profiles) {
      exportData.userProfiles = profiles;
      console.log(`   ✅ Exported ${exportData.userProfiles.length} user profiles`);
    } else {
      console.log('   ⚠️  No user profiles found or access denied');
    }

    // Export journal entries
    console.log('📦 Exporting journal entries...');
    const { data: entries, error: entriesError } = await supabase
      .from('journal_entries')
      .select('*');

    if (!entriesError && entries) {
      exportData.journalEntries = entries;
      console.log(`   ✅ Exported ${exportData.journalEntries.length} journal entries`);
    } else {
      console.log('   ⚠️  No journal entries found or access denied');
    }

    // Save to files
    console.log('');
    console.log('💾 Saving export files...');

    // Save scenarios for transformation
    fs.writeFileSync(
      'gitawisdom_scenarios.json',
      JSON.stringify(exportData.scenarios, null, 2)
    );
    console.log('   ✅ Saved: gitawisdom_scenarios.json');

    // Save complete export
    fs.writeFileSync(
      'supabase_export_complete.json',
      JSON.stringify(exportData, null, 2)
    );
    console.log('   ✅ Saved: supabase_export_complete.json');

    // Generate migration report
    const report = `
# Supabase Export Report
Generated: ${new Date().toISOString()}

## Summary
- Scenarios: ${exportData.scenarios.length}
- Chapters: ${exportData.chapters.length}
- Verses: ${exportData.verses.length}
- User Profiles: ${exportData.userProfiles?.length || 0}
- Journal Entries: ${exportData.journalEntries?.length || 0}

## Next Steps
1. Run content transformation:
   \`\`\`bash
   ./scripts/transform_content.sh
   \`\`\`

2. Review transformed content:
   \`\`\`bash
   cat mindful_situations.json | jq '.[0]'
   \`\`\`

3. Deploy to Firebase:
   \`\`\`bash
   firebase deploy --only firestore
   \`\`\`

## Data Quality
- Scenarios with quality_score >= 70: ${exportData.scenarios.length}
- Ready for transformation: ✅

## Migration Notes
- All religious content will be removed during transformation
- Voice keywords will be auto-generated
- User data preserved in separate collection
`;

    fs.writeFileSync('SUPABASE_EXPORT_REPORT.md', report);
    console.log('   ✅ Saved: SUPABASE_EXPORT_REPORT.md');

    console.log('');
    console.log('✅ Supabase export complete!');
    console.log('');
    console.log('📊 Summary:');
    console.log(`   Scenarios: ${exportData.scenarios.length}`);
    console.log(`   Chapters: ${exportData.chapters.length}`);
    console.log(`   Verses: ${exportData.verses.length}`);
    console.log(`   User Profiles: ${exportData.userProfiles?.length || 0}`);
    console.log(`   Journal Entries: ${exportData.journalEntries?.length || 0}`);
    console.log('');
    console.log('📝 Next: Transform content to secular format');
    console.log('   ./scripts/transform_content.sh');
    console.log('');

  } catch (error) {
    console.error('❌ Export failed:', error);
    process.exit(1);
  }
}

// Run export
exportFromSupabase();
