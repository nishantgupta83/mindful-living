/**
 * Content Transformer - GitaWisdom to Mindful Living
 * Removes ALL religious references and creates secular wellness content
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// Initialize Firebase Admin
admin.initializeApp({
  projectId: 'hub4apps-mindfulliving',
});

const db = admin.firestore();

interface GitaWisdomScenario {
  id: string;
  sc_title: string;
  sc_description: string;
  sc_heart_response: string;
  sc_duty_response: string;
  sc_gita_wisdom: string;
  sc_category: string;
  sc_tags: string[];
  sc_action_steps?: string[];
  quality_score?: number;
}

interface MindfulLifeSituation {
  id: string;
  title: string;
  description: string;
  mindfulApproach: string;
  practicalSteps: string[];
  keyInsights: string;
  lifeArea: string;
  tags: string[];
  wellnessFocus: string;
  voiceKeywords: string[];
  spokenTitle: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  estimatedReadTime: number;
  isVoiceOptimized: boolean;
  voicePopularity: number;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

class ContentTransformer {
  // CRITICAL: Comprehensive religious term mapping
  private readonly secularMapping: Record<string, string> = {
    // Direct deity references
    'Krishna': 'wisdom',
    'Lord Krishna': 'ancient wisdom',
    'Arjuna': 'the seeker',
    'Lord': 'inner guide',

    // Religious texts
    'Gita': 'teachings',
    'Bhagavad Gita': 'ancient teachings',
    'The Gita': 'wisdom tradition',
    'Gita Wisdom': 'Key Insights',
    'Chapter': 'principle',
    'Verse': 'insight',

    // Spiritual terms
    'Krishna teaches': 'Research shows',
    'The Gita says': 'Studies indicate',
    'Divine guidance': 'Inner wisdom',
    'Divine': 'inner',
    'Sacred': 'meaningful',
    'Holy': 'significant',
    'Spiritual': 'mindful',
    'Spirituality': 'mindfulness',
    'Spiritual practice': 'mindful practice',
    'Soul': 'inner self',
    'Atman': 'true self',

    // Hindu concepts
    'Dharma': 'purpose',
    'Karma': 'actions and consequences',
    'Yoga': 'practice',
    'Meditation on the divine': 'mindful meditation',
    'Prayer': 'reflection',
    'Devotion': 'dedication',
    'Faith': 'trust',
    'Worship': 'practice',

    // Sanskrit terms
    'Sattva': 'clarity',
    'Rajas': 'activity',
    'Tamas': 'inertia',
    'Moksha': 'liberation',
    'Nirvana': 'peace',

    // Religious language
    'Ancient wisdom': 'proven principles',
    'Eternal truth': 'universal insight',
    'Heavenly': 'ideal',
    'Blessed': 'fortunate',
    'Righteous': 'ethical',
  };

  // Category mapping to secular life areas
  private readonly categoryMapping: Record<string, string> = {
    'Work & Career': 'Work-Life Balance',
    'Health & Wellness': 'Mental Wellness',
    'Relationships': 'Relationships',
    'Personal Growth': 'Personal Growth',
    'Parenting & Family': 'Mindful Parenting',
    'Financial': 'Financial Wellness',
    'Social & Community': 'Social Connections',
    'Life Transitions': 'Life Transitions',
    'Education': 'Learning & Development',
    'Leadership': 'Leadership & Influence',
  };

  /**
   * Transform a GitaWisdom scenario to Mindful Living situation
   */
  async transformScenario(gita: GitaWisdomScenario): Promise<MindfulLifeSituation> {
    console.log(`Transforming: ${gita.sc_title}`);

    const transformed: MindfulLifeSituation = {
      id: this.generateUUID(),
      title: this.secularizeText(gita.sc_title),
      description: this.secularizeText(gita.sc_description),
      mindfulApproach: this.transformHeartResponse(gita.sc_heart_response),
      practicalSteps: this.transformDutyResponse(
        gita.sc_duty_response,
        gita.sc_action_steps || []
      ),
      keyInsights: this.transformWisdom(gita.sc_gita_wisdom),
      lifeArea: this.mapCategory(gita.sc_category),
      tags: this.generateSecularTags(gita.sc_tags),
      wellnessFocus: this.determineWellnessFocus(gita),
      voiceKeywords: this.generateVoiceKeywords(gita.sc_title, gita.sc_tags),
      spokenTitle: this.createSpokenTitle(gita.sc_title),
      difficulty: this.assessDifficulty(gita),
      estimatedReadTime: this.calculateReadTime(gita),
      isVoiceOptimized: true,
      voicePopularity: 0,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    };

    // Validate: Ensure no religious content remains
    this.validateSecular(transformed);

    return transformed;
  }

  /**
   * Secularize text - Remove ALL religious references
   */
  private secularizeText(text: string): string {
    if (!text) return '';

    let result = text;

    // Apply all secular mappings (case insensitive)
    Object.entries(this.secularMapping).forEach(([religious, secular]) => {
      const regex = new RegExp(`\\b${religious}\\b`, 'gi');
      result = result.replace(regex, secular);
    });

    // Remove remaining religious patterns
    const religiousPatterns = [
      // Deity names
      /\b(Krishna|Arjuna|Shiva|Vishnu|Brahma|Rama|Hanuman)\b/gi,
      // Text references
      /\b(Bhagavad|Gita|Upanishad|Vedas?|Vedic|Purana)\b/gi,
      // Sanskrit terms
      /\b(Sanskrit|Hindu|Hinduism)\b/gi,
      // Chapter/Verse references
      /Chapter\s+\d+,?\s*Verse\s+\d+/gi,
      /\d+\.\d+/g, // e.g., "2.47"
      // Religious concepts
      /\b(reincarnation|rebirth|enlightenment)\b/gi,
    ];

    religiousPatterns.forEach(pattern => {
      result = result.replace(pattern, '');
    });

    // Clean up formatting
    result = result
      .replace(/\s+/g, ' ') // Multiple spaces
      .replace(/\s+([.,!?;:])/g, '$1') // Space before punctuation
      .replace(/\(\s*\)/g, '') // Empty parentheses
      .replace(/\[\s*\]/g, '') // Empty brackets
      .trim();

    return result;
  }

  /**
   * Transform heart response (emotional/spiritual) to mindful approach
   */
  private transformHeartResponse(heartResponse: string): string {
    let mindful = this.secularizeText(heartResponse);

    // Add mindfulness framework
    const mindfulPrefixes = [
      'Take a moment to notice',
      'Begin by acknowledging',
      'Observe with gentle awareness',
      'Recognize without judgment',
      'Notice the feeling of',
      'Bring mindful attention to',
    ];

    // If doesn't already have mindful language, add it
    if (!mindful.toLowerCase().match(/\b(mindful|awareness|notice|observe|acknowledge)\b/)) {
      const prefix = mindfulPrefixes[Math.floor(Math.random() * mindfulPrefixes.length)];
      mindful = `${prefix} ${mindful.charAt(0).toLowerCase()}${mindful.slice(1)}`;
    }

    // Replace emotional/spiritual language with psychological language
    mindful = mindful
      .replace(/\b(peace of mind|inner peace)\b/gi, 'emotional balance')
      .replace(/\b(connect with your soul)\b/gi, 'connect with your values')
      .replace(/\b(trust in the divine)\b/gi, 'trust in the process')
      .replace(/\b(surrender to)\b/gi, 'accept')
      .replace(/\b(higher power)\b/gi, 'inner strength');

    return mindful;
  }

  /**
   * Transform duty response to practical steps
   */
  private transformDutyResponse(dutyResponse: string, actionSteps: string[]): string[] {
    const practical = this.secularizeText(dutyResponse);
    const steps: string[] = [];

    // Parse existing action steps
    if (actionSteps && actionSteps.length > 0) {
      actionSteps.forEach((step, index) => {
        const cleaned = this.secularizeText(step);
        if (cleaned.trim().length > 0) {
          // Ensure starts with number
          const numbered = cleaned.match(/^\d+\./)
            ? cleaned
            : `${index + 1}. ${cleaned}`;
          steps.push(numbered);
        }
      });
    }

    // If no steps, extract from duty response
    if (steps.length === 0) {
      const sentences = practical
        .split(/[.!?]+/)
        .filter(s => s.trim().length > 20)
        .slice(0, 7); // Max 7 steps

      sentences.forEach((sentence, index) => {
        const cleaned = sentence.trim();
        if (cleaned.length > 0) {
          steps.push(`${index + 1}. ${cleaned.charAt(0).toUpperCase()}${cleaned.slice(1)}.`);
        }
      });
    }

    // Ensure we have at least 3 steps
    if (steps.length < 3) {
      steps.push(
        '1. Take time to reflect on the situation.',
        '2. Consider your options and their consequences.',
        '3. Choose a course of action aligned with your values.'
      );
    }

    return steps.slice(0, 7); // Max 7 steps
  }

  /**
   * Transform Gita wisdom to evidence-based insights
   */
  private transformWisdom(gitaWisdom: string): string {
    let insights = this.secularizeText(gitaWisdom);

    // Add evidence-based framing
    const evidenceFrames = [
      'Research in positive psychology suggests that',
      'Studies have consistently shown that',
      'Evidence from behavioral science indicates that',
      'Psychological research demonstrates that',
      'Experts in well-being recommend that',
      'Scientific studies support the idea that',
    ];

    // If starts with religious attribution, replace with evidence-based
    if (insights.match(/^(The|Ancient|Eternal|Sacred|Divine)/i)) {
      const frame = evidenceFrames[Math.floor(Math.random() * evidenceFrames.length)];
      // Find the first verb and insert frame before it
      insights = `${frame} ${insights.charAt(0).toLowerCase()}${insights.slice(1)}`;
    }

    return insights;
  }

  /**
   * Map category to secular life area
   */
  private mapCategory(gitaCategory: string): string {
    return this.categoryMapping[gitaCategory] || 'Personal Growth';
  }

  /**
   * Generate secular tags
   */
  private generateSecularTags(gitaTags: string[]): string[] {
    return gitaTags
      .map(tag => this.secularizeText(tag))
      .filter(tag => tag.length > 0)
      .filter(tag => !this.isReligiousTerm(tag))
      .map(tag => tag.toLowerCase())
      .slice(0, 10);
  }

  /**
   * Check if term is still religious
   */
  private isReligiousTerm(term: string): boolean {
    const religiousKeywords = [
      'krishna', 'gita', 'divine', 'sacred', 'spiritual',
      'holy', 'lord', 'god', 'deity', 'worship', 'prayer',
      'soul', 'karma', 'dharma', 'yoga', 'meditation',
      'sanskrit', 'hindu', 'vedic', 'upanishad'
    ];

    return religiousKeywords.some(keyword =>
      term.toLowerCase().includes(keyword)
    );
  }

  /**
   * Determine wellness focus
   */
  private determineWellnessFocus(gita: GitaWisdomScenario): string {
    const text = `${gita.sc_title} ${gita.sc_description}`.toLowerCase();

    if (text.match(/\b(stress|anxiety|overwhelm|pressure)\b/)) return 'stress-management';
    if (text.match(/\b(relation|conflict|communication|partner)\b/)) return 'relationships';
    if (text.match(/\b(work|career|job|professional)\b/)) return 'work-life';
    if (text.match(/\b(parent|child|family|kids)\b/)) return 'parenting';
    if (text.match(/\b(health|wellness|exercise|sleep)\b/)) return 'health';
    if (text.match(/\b(emotion|feeling|mood|mental)\b/)) return 'emotional-wellness';
    if (text.match(/\b(decision|choice|problem|solve)\b/)) return 'decision-making';
    if (text.match(/\b(money|financial|budget|savings)\b/)) return 'financial-wellness';

    return 'general-wellness';
  }

  /**
   * Generate voice-optimized keywords
   */
  private generateVoiceKeywords(title: string, tags: string[]): string[] {
    const keywords = new Set<string>();

    // Extract from title
    const titleWords = title.toLowerCase().split(/\s+/);
    titleWords.forEach(word => {
      const clean = word.replace(/[^a-z0-9]/g, '');
      if (clean.length > 3 && !this.isReligiousTerm(clean)) {
        keywords.add(clean);
      }
    });

    // Add tags
    tags.forEach(tag => {
      const clean = tag.toLowerCase().replace(/[^a-z0-9]/g, '');
      if (clean.length > 0 && !this.isReligiousTerm(clean)) {
        keywords.add(clean);
      }
    });

    // Add common synonyms for voice queries
    const voiceSynonyms: Record<string, string[]> = {
      'stress': ['pressure', 'tension', 'anxiety', 'overwhelm'],
      'work': ['job', 'career', 'office', 'professional'],
      'relationship': ['partner', 'spouse', 'marriage', 'dating'],
      'parent': ['parenting', 'child', 'kids', 'family'],
      'conflict': ['argument', 'fight', 'disagreement', 'dispute'],
      'decision': ['choice', 'decide', 'choose', 'option'],
      'anxious': ['worried', 'nervous', 'afraid', 'fearful'],
      'angry': ['mad', 'furious', 'upset', 'frustrated'],
    };

    Array.from(keywords).forEach(keyword => {
      if (voiceSynonyms[keyword]) {
        voiceSynonyms[keyword].forEach(syn => keywords.add(syn));
      }
    });

    return Array.from(keywords).slice(0, 15);
  }

  /**
   * Create spoken-friendly title
   */
  private createSpokenTitle(title: string): string {
    return this.secularizeText(title)
      .replace(/&/g, 'and')
      .replace(/\//g, ' or ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  /**
   * Assess difficulty level
   */
  private assessDifficulty(gita: GitaWisdomScenario): 'beginner' | 'intermediate' | 'advanced' {
    const combinedText = `${gita.sc_description} ${gita.sc_heart_response} ${gita.sc_duty_response}`;
    const wordCount = combinedText.split(/\s+/).length;

    if (wordCount < 150) return 'beginner';
    if (wordCount < 300) return 'intermediate';
    return 'advanced';
  }

  /**
   * Calculate read time
   */
  private calculateReadTime(gita: GitaWisdomScenario): number {
    const combinedText = `${gita.sc_description} ${gita.sc_heart_response} ${gita.sc_duty_response}`;
    const wordCount = combinedText.split(/\s+/).length;
    const wordsPerMinute = 200;

    return Math.max(1, Math.ceil(wordCount / wordsPerMinute));
  }

  /**
   * Validate no religious content remains
   */
  private validateSecular(situation: MindfulLifeSituation): void {
    const textToCheck = JSON.stringify(situation).toLowerCase();

    const religiousTerms = [
      'krishna', 'gita', 'bhagavad', 'arjuna', 'lord',
      'divine', 'sacred', 'holy', 'spiritual', 'soul',
      'prayer', 'worship', 'deity', 'god',
      'karma', 'dharma', 'sanskrit', 'hindu', 'vedic'
    ];

    const foundTerms = religiousTerms.filter(term => textToCheck.includes(term));

    if (foundTerms.length > 0) {
      console.error(`⚠️  WARNING: Religious terms found in ${situation.title}:`, foundTerms);
      throw new Error(`Religious content detected: ${foundTerms.join(', ')}`);
    }
  }

  /**
   * Generate UUID
   */
  private generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
}

/**
 * Main transformation function
 */
export async function transformGitaWisdomContent(
  inputFile: string,
  outputFile: string
): Promise<void> {
  console.log('🔄 Starting content transformation...');
  console.log(`Input: ${inputFile}`);
  console.log(`Output: ${outputFile}`);

  const transformer = new ContentTransformer();

  // Read GitaWisdom scenarios
  const gitaScenarios: GitaWisdomScenario[] = JSON.parse(
    fs.readFileSync(inputFile, 'utf-8')
  );

  console.log(`\nFound ${gitaScenarios.length} scenarios to transform`);

  const transformed: MindfulLifeSituation[] = [];
  const errors: Array<{ scenario: string; error: string }> = [];

  // Transform each scenario
  for (const [index, scenario] of gitaScenarios.entries()) {
    try {
      console.log(`\n[${index + 1}/${gitaScenarios.length}] Processing: ${scenario.sc_title}`);

      const mindfulSituation = await transformer.transformScenario(scenario);
      transformed.push(mindfulSituation);

      console.log(`✅ Transformed successfully`);
      console.log(`   Title: ${mindfulSituation.title}`);
      console.log(`   Life Area: ${mindfulSituation.lifeArea}`);
      console.log(`   Voice Keywords: ${mindfulSituation.voiceKeywords.slice(0, 5).join(', ')}...`);

    } catch (error) {
      console.error(`❌ Failed:`, error.message);
      errors.push({
        scenario: scenario.sc_title,
        error: error.message
      });
    }
  }

  // Save transformed content
  fs.writeFileSync(outputFile, JSON.stringify(transformed, null, 2));

  // Generate report
  console.log('\n' + '='.repeat(60));
  console.log('📊 TRANSFORMATION REPORT');
  console.log('='.repeat(60));
  console.log(`Total scenarios: ${gitaScenarios.length}`);
  console.log(`✅ Successfully transformed: ${transformed.length}`);
  console.log(`❌ Failed: ${errors.length}`);
  console.log(`📁 Output saved to: ${outputFile}`);

  if (errors.length > 0) {
    console.log('\n⚠️  ERRORS:');
    errors.forEach(({ scenario, error }) => {
      console.log(`  - ${scenario}: ${error}`);
    });
  }

  // Validate all content is secular
  console.log('\n🔍 Validating secular content...');
  const validationErrors: string[] = [];

  transformed.forEach(situation => {
    try {
      const textToCheck = JSON.stringify(situation).toLowerCase();
      const religiousTerms = ['krishna', 'gita', 'divine', 'sacred', 'holy'];

      religiousTerms.forEach(term => {
        if (textToCheck.includes(term)) {
          validationErrors.push(`${situation.title} contains: ${term}`);
        }
      });
    } catch (error) {
      validationErrors.push(`${situation.title}: Validation error`);
    }
  });

  if (validationErrors.length === 0) {
    console.log('✅ All content is secular - No religious references found!');
  } else {
    console.log(`❌ Found ${validationErrors.length} validation issues:`);
    validationErrors.forEach(error => console.log(`  - ${error}`));
  }

  console.log('\n✅ Transformation complete!');
}

// CLI execution
if (require.main === module) {
  const inputFile = process.argv[2] || './gitawisdom_scenarios.json';
  const outputFile = process.argv[3] || './mindful_situations.json';

  transformGitaWisdomContent(inputFile, outputFile)
    .then(() => process.exit(0))
    .catch(error => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}
