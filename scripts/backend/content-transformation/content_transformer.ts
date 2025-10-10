/**
 * Content Transformer: GitaWisdom → Mindful Living
 * Removes ALL religious references and creates secular wellness content
 */

import * as fs from 'fs';

interface SupabaseScenario {
  id: number;
  sc_title: string;
  sc_description: string;
  sc_category: string;
  sc_chapter: number;
  sc_heart_response: string;
  sc_duty_response: string;
  sc_gita_wisdom: string;
  sc_verse: string;
  sc_verse_number: string;
  sc_tags: string[];
  sc_action_steps: string[];
  created_at: string;
  updated_at: string;
}

interface MindfulLifeSituation {
  id: string;
  title: string;
  description: string;
  lifeArea: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
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

class ContentTransformer {
  private readonly secularMapping: Record<string, string> = {
    'Krishna': 'wisdom',
    'Krishna teaches': 'Research shows',
    'Krishna says': 'Studies indicate',
    'The Gita': 'mindfulness principles',
    'Bhagavad Gita': 'ancient philosophy',
    'Arjuna': 'the seeker',
    'Divine': 'inner',
    'Divine guidance': 'inner wisdom',
    'Sacred': 'meaningful',
    'Spiritual practice': 'mindful practice',
    'Dharma': 'purpose',
    'Karma': 'actions and consequences',
  };

  transform(inputFile: string, outputFile: string): void {
    const rawData = fs.readFileSync(inputFile, 'utf-8');
    const supabaseScenarios: SupabaseScenario[] = JSON.parse(rawData);
    console.log(`Loaded ${supabaseScenarios.length} scenarios`);

    const transformed: MindfulLifeSituation[] = supabaseScenarios.map((s, i) => {
      if (i % 100 === 0) console.log(`Transformed ${i}...`);
      return this.transformScenario(s);
    });

    fs.writeFileSync(outputFile, JSON.stringify(transformed, null, 2));
    console.log(`Saved ${transformed.length} situations to ${outputFile}`);
  }

  private transformScenario(s: SupabaseScenario): MindfulLifeSituation {
    const cleanedTags = this.cleanTags(s.sc_tags);
    return {
      id: `situation_${s.id}`,
      title: this.removeReligious(s.sc_title),
      description: this.removeReligious(s.sc_description),
      lifeArea: this.mapCategory(s.sc_category),
      difficulty: 'intermediate',
      mindfulApproach: this.removeReligious(s.sc_heart_response),
      practicalSteps: (s.sc_action_steps || []).map(step => this.removeReligious(step)),
      keyInsights: [this.removeReligious(s.sc_gita_wisdom)],
      tags: cleanedTags,
      voiceKeywords: this.generateKeywords(this.removeReligious(s.sc_title), cleanedTags),
      spokenTitle: this.removeReligious(s.sc_title),
      estimatedReadTime: 5,
      wellnessFocus: ['mindfulness'],
      created: s.created_at,
      updated: s.updated_at,
    };
  }

  private removeReligious(text: string): string {
    let cleaned = text || '';

    // Remove all Gita references (multiple patterns)
    cleaned = cleaned.replace(/Gita\s+Chapter\s+\d+:\s*/gi, '');
    cleaned = cleaned.replace(/Gita\s+chapter\s+\d+/gi, 'ancient wisdom');
    cleaned = cleaned.replace(/Gita\s*\(chapter\s+\d+\)/gi, 'mindfulness principles');
    cleaned = cleaned.replace(/Chapter\s+\d+:\s+Gita/gi, 'Research');
    cleaned = cleaned.replace(/\(BG\s*\d+\.\d+\)/gi, '');
    cleaned = cleaned.replace(/Bhagavad\s+Gītā\s+\d+\.\d+[-–]\d+/gi, 'Studies');
    cleaned = cleaned.replace(/Bhagavad\s+Gita\s+\d+\.\d+/gi, 'Research');
    cleaned = cleaned.replace(/\bGita\b/gi, 'wisdom');
    cleaned = cleaned.replace(/\bBhagavad\s+Gita\b/gi, 'ancient philosophy');
    cleaned = cleaned.replace(/\bBhagavad\s+Gītā\b/gi, 'ancient philosophy');

    // Remove other religious terms
    cleaned = cleaned.replace(/\bKrishna\b/gi, 'wisdom');
    cleaned = cleaned.replace(/\bArjuna\b/gi, 'the seeker');
    cleaned = cleaned.replace(/\bDivine\b/gi, 'inner');
    cleaned = cleaned.replace(/\bSacred\b/gi, 'meaningful');
    cleaned = cleaned.replace(/\bDharma\b/gi, 'purpose');
    cleaned = cleaned.replace(/\bdharmictrue\b/gi, 'purposeful');
    cleaned = cleaned.replace(/\bKarma\b/gi, 'action');

    // Apply remaining word mappings
    for (const [old, neu] of Object.entries(this.secularMapping)) {
      cleaned = cleaned.replace(new RegExp(`\\b${old}\\b`, 'gi'), neu);
    }

    // Clean up extra spaces and punctuation
    cleaned = cleaned.replace(/\s+/g, ' ').trim();
    cleaned = cleaned.replace(/\s+([.,!?])/g, '$1');

    return cleaned;
  }

  private cleanTags(tags: string[]): string[] {
    return (tags || [])
      .map(tag => this.removeReligious(tag))
      .map(tag => tag.toLowerCase().replace(/\s+/g, '-'))
      .filter(tag => {
        // Filter out religious terms from tags
        const religious = ['krishna', 'gita', 'divine', 'sacred', 'spiritual', 'god', 'lord'];
        return !religious.some(r => tag.includes(r));
      });
  }

  private mapCategory(cat: string): string {
    const map: Record<string, string> = {
      'Health & Wellness': 'wellness',
      'Parenting & Family': 'relationships',
      'Personal Growth': 'growth',
      'Work & Career': 'career',
    };
    return map[cat] || 'life-challenges';
  }

  private generateKeywords(title: string, tags: string[]): string[] {
    const words = title.toLowerCase().split(/\s+/).filter(w => w.length > 3);
    return [...words, ...(tags || []).slice(0, 3)].slice(0, 5);
  }
}

const args = process.argv.slice(2);
const transformer = new ContentTransformer();
transformer.transform(args[0] || 'gitawisdom_scenarios.json', args[1] || 'mindful_situations.json');
