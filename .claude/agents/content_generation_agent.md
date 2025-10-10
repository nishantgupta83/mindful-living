# Content Generation Agent

## 🎯 Purpose
Automates content creation for Mindful Living app including life situations, wellness guidance, documentation, and localization. Ensures consistent, high-quality, secular content at scale.

## 🔍 Responsibilities

### 1. Life Situations Generation
- Transform GitaWisdom scenarios to secular wellness content
- Generate new life situations from wellness research
- Create mindful and practical approaches
- Generate voice-optimized content
- Tag and categorize scenarios

### 2. Documentation Generation
- API documentation
- Code documentation
- User guides and tutorials
- Release notes
- Change logs

### 3. Localization Content
- Generate translations (English, Spanish, Hindi)
- Cultural adaptation
- RTL text handling
- Locale-specific examples

### 4. Marketing Content
- App Store descriptions
- Social media posts
- Blog articles
- Email campaigns

## 📋 Content Generation Workflows

### Workflow 1: Life Situation Generation

#### From GitaWisdom Transformation
```typescript
// backend/content-generation/transform_gitawisdom.ts

interface GitaWisdomScenario {
  id: string;
  sc_title: string;
  sc_description: string;
  sc_heart_response: string;      // Emotional/spiritual approach
  sc_duty_response: string;       // Practical approach
  sc_gita_wisdom: string;         // Religious wisdom
  sc_category: string;
  sc_tags: string[];
  sc_action_steps: string[];
}

interface MindfulLifeSituation {
  id: string;
  title: string;
  description: string;
  mindfulApproach: string;        // Secular mindfulness approach
  practicalSteps: string[];       // Practical action steps
  keyInsights: string;            // Evidence-based insights
  lifeArea: string;
  tags: string[];
  wellnessFocus: string;
  voiceKeywords: string[];
  spokenTitle: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  estimatedReadTime: number;
}

class ContentTransformer {
  // Mapping of religious terms to secular equivalents
  private readonly secularMapping: Record<string, string> = {
    'Krishna teaches': 'Research shows',
    'The Gita says': 'Wisdom suggests',
    'Gita Wisdom': 'Key Insights',
    'Divine guidance': 'Inner wisdom',
    'Sacred': 'Meaningful',
    'Spiritual practice': 'Mindful practice',
    'Dharma': 'Purpose',
    'Karma': 'Cause and effect',
    'Ancient wisdom': 'Proven principles',
    'Eternal truth': 'Universal insight',
    'Soul': 'Inner self',
    'Meditation on the divine': 'Mindful reflection',
    'Prayer': 'Reflection',
    'Faith': 'Trust',
    'Devotion': 'Dedication',
  };

  async transformScenario(gita: GitaWisdomScenario): Promise<MindfulLifeSituation> {
    return {
      id: this.generateUUID(),
      title: this.secularizeText(gita.sc_title),
      description: this.secularizeText(gita.sc_description),
      mindfulApproach: this.transformHeartResponse(gita.sc_heart_response),
      practicalSteps: this.transformDutyResponse(gita.sc_duty_response, gita.sc_action_steps),
      keyInsights: this.transformWisdom(gita.sc_gita_wisdom),
      lifeArea: this.mapCategory(gita.sc_category),
      tags: this.generateSecularTags(gita.sc_tags),
      wellnessFocus: this.determineWellnessFocus(gita),
      voiceKeywords: this.generateVoiceKeywords(gita.sc_title, gita.sc_tags),
      spokenTitle: this.createSpokenTitle(gita.sc_title),
      difficulty: this.assessDifficulty(gita),
      estimatedReadTime: this.calculateReadTime(gita)
    };
  }

  private secularizeText(text: string): string {
    let result = text;

    // Apply all secular mappings
    Object.entries(this.secularMapping).forEach(([religious, secular]) => {
      const regex = new RegExp(religious, 'gi');
      result = result.replace(regex, secular);
    });

    // Remove remaining religious references
    const religiousPatterns = [
      /\b(Krishna|Arjuna|Bhagavad|Gita|Lord|Hindu|Sanskrit|Vedic|Upanishad)\b/gi,
      /Chapter \d+, Verse \d+/gi
    ];

    religiousPatterns.forEach(pattern => {
      result = result.replace(pattern, '');
    });

    // Clean up extra spaces and punctuation
    result = result
      .replace(/\s+/g, ' ')
      .replace(/\s+([.,!?])/g, '$1')
      .trim();

    return result;
  }

  private transformHeartResponse(heartResponse: string): string {
    // Convert emotional/spiritual guidance to mindful approach
    let mindful = this.secularizeText(heartResponse);

    // Add mindfulness framework
    const mindfulPrefix = [
      'Mindfully acknowledge',
      'Notice with awareness',
      'Observe without judgment',
      'Be present with',
      'Recognize the feeling of'
    ];

    // Enhance with mindfulness language
    if (!mindful.toLowerCase().includes('mindful')) {
      const prefix = mindfulPrefix[Math.floor(Math.random() * mindfulPrefix.length)];
      mindful = `${prefix} ${mindful.charAt(0).toLowerCase()}${mindful.slice(1)}`;
    }

    return mindful;
  }

  private transformDutyResponse(dutyResponse: string, actionSteps: string[]): string[] {
    // Convert duty-based response to practical steps
    const practical = this.secularizeText(dutyResponse);

    // Extract actionable steps
    const steps: string[] = [];

    // Parse existing action steps
    actionSteps.forEach(step => {
      steps.push(this.secularizeText(step));
    });

    // If no steps, generate from duty response
    if (steps.length === 0) {
      // Split by sentences and convert to steps
      const sentences = practical.split(/[.!?]+/).filter(s => s.trim().length > 0);
      sentences.forEach((sentence, index) => {
        if (index < 5) { // Max 5 steps
          steps.push(`${index + 1}. ${sentence.trim()}`);
        }
      });
    }

    return steps;
  }

  private transformWisdom(gitaWisdom: string): string {
    // Convert religious wisdom to evidence-based insights
    let insights = this.secularizeText(gitaWisdom);

    // Add evidence-based framing
    const evidenceFrames = [
      'Research in positive psychology suggests',
      'Studies have shown that',
      'Evidence indicates',
      'Psychological research demonstrates',
      'Wellness experts recommend'
    ];

    // Replace religious attribution with evidence-based attribution
    if (insights.toLowerCase().includes('the gita') || insights.toLowerCase().includes('krishna')) {
      const frame = evidenceFrames[Math.floor(Math.random() * evidenceFrames.length)];
      insights = `${frame} ${insights}`;
    }

    return insights;
  }

  private mapCategory(gitaCategory: string): string {
    const categoryMap: Record<string, string> = {
      'Work & Career': 'Work-Life Balance',
      'Health & Wellness': 'Mental Wellness',
      'Relationships': 'Relationships',
      'Personal Growth': 'Personal Growth',
      'Parenting & Family': 'Mindful Parenting',
      'Financial': 'Financial Wellness',
      'Social & Community': 'Social Connections',
      'Life Transitions': 'Life Transitions'
    };

    return categoryMap[gitaCategory] || 'Personal Growth';
  }

  private generateSecularTags(gitaTags: string[]): string[] {
    return gitaTags
      .map(tag => this.secularizeText(tag))
      .filter(tag => tag.length > 0)
      .map(tag => tag.toLowerCase());
  }

  private determineWellnessFocus(gita: GitaWisdomScenario): string {
    const text = `${gita.sc_title} ${gita.sc_description}`.toLowerCase();

    if (text.includes('stress') || text.includes('anxiety')) return 'stress-management';
    if (text.includes('relation') || text.includes('conflict')) return 'relationships';
    if (text.includes('work') || text.includes('career')) return 'work-life';
    if (text.includes('parent') || text.includes('child')) return 'parenting';
    if (text.includes('health') || text.includes('wellness')) return 'health';
    if (text.includes('emotion') || text.includes('feeling')) return 'emotional-wellness';

    return 'general-wellness';
  }

  private generateVoiceKeywords(title: string, tags: string[]): string[] {
    const keywords = new Set<string>();

    // Add words from title (> 3 chars)
    title.split(' ').forEach(word => {
      const clean = word.toLowerCase().replace(/[^a-z0-9]/g, '');
      if (clean.length > 3) keywords.add(clean);
    });

    // Add tags
    tags.forEach(tag => {
      keywords.add(tag.toLowerCase());
    });

    // Add common synonyms
    const synonymMap: Record<string, string[]> = {
      'stress': ['pressure', 'tension', 'anxiety'],
      'work': ['job', 'career', 'professional'],
      'relationship': ['partner', 'spouse', 'marriage'],
      'parent': ['parenting', 'child', 'kids'],
    };

    keywords.forEach(keyword => {
      if (synonymMap[keyword]) {
        synonymMap[keyword].forEach(syn => keywords.add(syn));
      }
    });

    return Array.from(keywords).slice(0, 15); // Limit to 15 keywords
  }

  private createSpokenTitle(title: string): string {
    return this.secularizeText(title)
      .replace(/&/g, 'and')
      .replace(/\//g, ' or ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private assessDifficulty(gita: GitaWisdomScenario): 'beginner' | 'intermediate' | 'advanced' {
    const text = `${gita.sc_description} ${gita.sc_heart_response}`;
    const wordCount = text.split(' ').length;

    if (wordCount < 100) return 'beginner';
    if (wordCount < 200) return 'intermediate';
    return 'advanced';
  }

  private calculateReadTime(gita: GitaWisdomScenario): number {
    const text = `${gita.sc_description} ${gita.sc_heart_response} ${gita.sc_duty_response}`;
    const wordCount = text.split(' ').length;
    const wordsPerMinute = 200;

    return Math.ceil(wordCount / wordsPerMinute);
  }

  private generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
}

// Batch transformation script
async function transformAllScenarios() {
  const transformer = new ContentTransformer();

  // Read GitaWisdom scenarios from export
  const gitaScenarios = await loadGitaScenarios('gitawisdom_export.json');

  console.log(`Transforming ${gitaScenarios.length} scenarios...`);

  const transformed: MindfulLifeSituation[] = [];

  for (const scenario of gitaScenarios) {
    try {
      const mindfulSituation = await transformer.transformScenario(scenario);
      transformed.push(mindfulSituation);

      console.log(`✅ Transformed: ${mindfulSituation.title}`);
    } catch (error) {
      console.error(`❌ Failed to transform scenario ${scenario.id}:`, error);
    }
  }

  // Save transformed content
  await saveTransformedContent(transformed, 'mindful_situations.json');

  console.log(`\n✅ Transformation complete: ${transformed.length} situations generated`);

  // Generate quality report
  await generateQualityReport(transformed);
}
```

### Workflow 2: New Content Generation

#### AI-Assisted Content Creation
```typescript
// backend/content-generation/generate_new_situations.ts

class SituationGenerator {
  // Template-based generation
  generateFromTemplate(template: SituationTemplate, variables: Record<string, string>): MindfulLifeSituation {
    let content = template.content;

    // Replace variables
    Object.entries(variables).forEach(([key, value]) => {
      content = content.replace(new RegExp(`{{${key}}}`, 'g'), value);
    });

    return {
      ...template.structure,
      ...this.parseTemplate(content)
    };
  }

  // Research-based generation
  async generateFromResearch(topic: string): Promise<MindfulLifeSituation> {
    // Would integrate with research database or API
    const research = await this.fetchWellnessResearch(topic);

    return {
      id: this.generateUUID(),
      title: this.createTitle(topic),
      description: research.summary,
      mindfulApproach: research.mindfulnessApproach,
      practicalSteps: research.actionSteps,
      keyInsights: research.keyFindings,
      lifeArea: research.category,
      tags: research.keywords,
      wellnessFocus: topic,
      voiceKeywords: this.extractKeywords(research),
      spokenTitle: this.createSpokenTitle(topic),
      difficulty: 'intermediate',
      estimatedReadTime: 5
    };
  }

  // Variation generation
  generateVariations(baseSituation: MindfulLifeSituation, count: number): MindfulLifeSituation[] {
    const variations: MindfulLifeSituation[] = [];

    for (let i = 0; i < count; i++) {
      variations.push({
        ...baseSituation,
        id: this.generateUUID(),
        title: this.createVariation(baseSituation.title, i),
        description: this.varyDescription(baseSituation.description),
        tags: [...baseSituation.tags, `variation${i + 1}`]
      });
    }

    return variations;
  }

  private async fetchWellnessResearch(topic: string): Promise<any> {
    // Implementation would fetch from research database
    return {
      summary: '',
      mindfulnessApproach: '',
      actionSteps: [],
      keyFindings: '',
      category: '',
      keywords: []
    };
  }

  private extractKeywords(research: any): string[] {
    // Implementation would use NLP to extract keywords
    return [];
  }

  private createVariation(title: string, index: number): string {
    const variations = [
      `${title} (Alternative Approach)`,
      `Different Perspective on ${title}`,
      `${title} - Advanced Strategies`,
      `Simplified Approach to ${title}`,
    ];

    return variations[index % variations.length];
  }

  private varyDescription(description: string): string {
    // Implementation would rephrase while maintaining meaning
    return description;
  }
}
```

### Workflow 3: Documentation Generation

#### Auto-Generate API Docs
```typescript
// scripts/generate_docs.ts

interface DocTemplate {
  title: string;
  sections: Section[];
  examples: CodeExample[];
}

class DocumentationGenerator {
  async generateAPIDocumentation(sourceFiles: string[]): Promise<void> {
    const docs: DocTemplate[] = [];

    for (const file of sourceFiles) {
      const ast = await this.parseSourceFile(file);
      const doc = await this.extractDocumentation(ast);
      docs.push(doc);
    }

    await this.renderMarkdown(docs, 'docs/api/');
  }

  async generateUserGuide(features: Feature[]): Promise<void> {
    const guide = {
      title: 'Mindful Living User Guide',
      sections: features.map(f => this.featureToSection(f))
    };

    await this.renderMarkdown([guide], 'docs/user-guide/');
  }

  async generateReleaseNotes(version: string, changes: Change[]): Promise<void> {
    const grouped = this.groupChanges(changes);

    const releaseNotes = `
# Release Notes - v${version}

## 🎉 New Features
${this.formatChanges(grouped.features)}

## 🔧 Improvements
${this.formatChanges(grouped.improvements)}

## 🐛 Bug Fixes
${this.formatChanges(grouped.bugFixes)}

## ⚠️ Breaking Changes
${this.formatChanges(grouped.breaking)}

## 📚 Documentation
${this.formatChanges(grouped.documentation)}
    `.trim();

    await this.writeFile(`CHANGELOG.md`, releaseNotes);
  }

  private formatChanges(changes: Change[]): string {
    return changes
      .map(c => `- ${c.description} ([#${c.prNumber}](${c.prUrl}))`)
      .join('\n');
  }

  private groupChanges(changes: Change[]): Record<string, Change[]> {
    return {
      features: changes.filter(c => c.type === 'feature'),
      improvements: changes.filter(c => c.type === 'improvement'),
      bugFixes: changes.filter(c => c.type === 'bugfix'),
      breaking: changes.filter(c => c.breaking),
      documentation: changes.filter(c => c.type === 'docs')
    };
  }
}
```

### Workflow 4: Localization Generation

#### Multi-Language Content
```dart
// tools/generate_l10n_content.dart

class LocalizationGenerator {
  final Map<String, String> baseTranslations = {
    'en': 'English',
    'es': 'Spanish',
    'hi': 'Hindi'
  };

  Future<void> generateTranslations(
    List<MindfulLifeSituation> situations
  ) async {
    for (final locale in baseTranslations.keys) {
      final translations = <String, String>{};

      for (final situation in situations) {
        final key = 'situation_${situation.id}_title';
        translations[key] = await translate(situation.title, locale);

        final descKey = 'situation_${situation.id}_description';
        translations[descKey] = await translate(situation.description, locale);
      }

      // Write ARB file
      await writeARBFile(locale, translations);
    }
  }

  Future<String> translate(String text, String targetLocale) async {
    // Would integrate with translation API (Google Translate, DeepL, etc.)
    // For now, return text (manual translation needed)
    return text;
  }

  Future<void> writeARBFile(String locale, Map<String, String> translations) async {
    final arbContent = {
      '@@locale': locale,
      ...translations
    };

    final file = File('lib/l10n/app_$locale.arb');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(arbContent)
    );
  }

  // Generate culturally adapted content
  Future<MindfulLifeSituation> adaptForCulture(
    MindfulLifeSituation situation,
    String culture
  ) async {
    // Modify examples, references to be culturally appropriate
    return situation;
  }
}
```

## 📊 Content Quality Assurance

### Quality Checklist
```typescript
class ContentQualityChecker {
  async validateContent(situation: MindfulLifeSituation): Promise<QualityReport> {
    const report: QualityReport = {
      passed: true,
      issues: [],
      warnings: [],
      score: 100
    };

    // Check 1: No religious references
    if (this.hasReligiousContent(situation)) {
      report.issues.push('Contains religious references');
      report.score -= 50;
      report.passed = false;
    }

    // Check 2: Minimum content length
    if (situation.description.length < 100) {
      report.warnings.push('Description too short');
      report.score -= 10;
    }

    // Check 3: Has practical steps
    if (situation.practicalSteps.length === 0) {
      report.issues.push('Missing practical steps');
      report.score -= 20;
      report.passed = false;
    }

    // Check 4: Voice optimization
    if (situation.voiceKeywords.length < 3) {
      report.warnings.push('Insufficient voice keywords');
      report.score -= 5;
    }

    // Check 5: Appropriate tags
    if (situation.tags.length === 0) {
      report.warnings.push('No tags assigned');
      report.score -= 10;
    }

    // Check 6: Readability
    const readability = this.calculateReadability(situation.description);
    if (readability < 60) {
      report.warnings.push('Low readability score');
      report.score -= 10;
    }

    return report;
  }

  private hasReligiousContent(situation: MindfulLifeSituation): boolean {
    const text = JSON.stringify(situation).toLowerCase();
    const religiousTerms = [
      'krishna', 'gita', 'bhagavad', 'hindu', 'divine',
      'sacred', 'spiritual', 'soul', 'lord', 'prayer'
    ];

    return religiousTerms.some(term => text.includes(term));
  }

  private calculateReadability(text: string): number {
    // Flesch Reading Ease formula
    const sentences = text.split(/[.!?]+/).length;
    const words = text.split(/\s+/).length;
    const syllables = this.countSyllables(text);

    const score = 206.835 - 1.015 * (words / sentences) - 84.6 * (syllables / words);
    return Math.max(0, Math.min(100, score));
  }

  private countSyllables(text: string): number {
    // Simplified syllable counting
    return text.split(/\s+/).reduce((count, word) => {
      return count + Math.max(1, word.match(/[aeiou]+/gi)?.length || 1);
    }, 0);
  }
}
```

## 🚀 Quick Commands

```bash
# Transform GitaWisdom content
npm run content:transform

# Generate new situations
npm run content:generate --topic "work-stress" --count 10

# Generate documentation
npm run docs:generate

# Generate localization files
npm run l10n:generate

# Validate content quality
npm run content:validate

# Generate release notes
npm run release:notes --version 1.2.0
```

## 🎯 Content Standards

### Quality Targets
- **Readability**: Flesch score > 60
- **Length**: 100-500 words per situation
- **Practical Steps**: 3-7 action items
- **Tags**: 3-8 relevant tags
- **Voice Keywords**: 5-15 keywords
- **Read Time**: 2-5 minutes

### Secular Requirements
- ✅ Zero religious references
- ✅ Evidence-based language
- ✅ Inclusive terminology
- ✅ Culturally neutral examples
- ✅ Scientific backing where possible

## 📚 Resources
- [Content Style Guide](../docs/content-style-guide.md)
- [Mindfulness Language Guide](../docs/mindfulness-language.md)
- [Translation Guidelines](../docs/translation-guidelines.md)
- [Voice Content Optimization](../docs/voice-content.md)

---

**Note**: All content should be reviewed by wellness experts before publication. Automated generation is a starting point, not the final product.
