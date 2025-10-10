# Alexa Deployment Agent

## 🎯 Purpose
Deploy and manage Mindful Living Alexa skill for voice-activated wellness guidance. Works independently in parallel with other development.

## 📋 Responsibilities
- Create and configure Alexa skill
- Deploy Firebase Functions backend
- Test voice interactions
- Handle certification process
- Monitor skill performance

## ⚡ Quick Start (Complete Workflow)

```bash
# Run full Alexa deployment
./scripts/deploy_alexa.sh

# Individual steps
./scripts/alexa_create_skill.sh
./scripts/alexa_deploy_backend.sh
./scripts/alexa_test_skill.sh
./scripts/alexa_submit_certification.sh
```

---

## 📅 Timeline: 3-4 Days

### Day 1: Skill Creation & Configuration
- Create skill in Amazon Developer Console
- Configure interaction model
- Set up Firebase Functions endpoint

### Day 2: Backend Development
- Deploy Firebase Functions
- Test voice query processing
- Optimize response times

### Day 3: Testing & Refinement
- Test all voice patterns
- Refine responses
- Add error handling

### Day 4: Certification & Launch
- Submit for certification
- Address any issues
- Prepare for launch

---

## 🔧 Step 1: Create Alexa Skill

### Amazon Developer Console Setup

1. **Go to**: https://developer.amazon.com/alexa/console/ask
2. **Click**: "Create Skill"
3. **Configure**:
   - **Skill name**: Mindful Living
   - **Primary locale**: English (US)
   - **Model**: Custom
   - **Hosting**: Provision your own
   - **Backend**: HTTPS endpoint

### Skill Configuration
```json
{
  "manifest": {
    "publishingInformation": {
      "locales": {
        "en-US": {
          "name": "Mindful Living",
          "summary": "Your daily companion for mindful wellness and stress management",
          "description": "Mindful Living provides instant, evidence-based guidance for life's challenges. Get personalized wellness advice, breathing exercises, daily reflections, and practical steps for managing stress, relationships, work-life balance, and more. No religious content - just proven mindfulness techniques and actionable insights.",
          "examplePhrases": [
            "Alexa, ask Mindful Living about work stress",
            "Alexa, ask Mindful Living for a breathing exercise",
            "Alexa, ask Mindful Living to check my wellness score"
          ],
          "keywords": [
            "mindfulness",
            "wellness",
            "stress relief",
            "mental health",
            "life balance",
            "breathing exercises",
            "meditation",
            "self care"
          ],
          "smallIconUri": "https://your-cdn.com/icons/mindful-108.png",
          "largeIconUri": "https://your-cdn.com/icons/mindful-512.png"
        }
      },
      "category": "HEALTH_AND_FITNESS",
      "distributionCountries": ["US", "CA", "GB", "AU", "IN"]
    },
    "privacyAndCompliance": {
      "allowsPurchases": false,
      "usesPersonalInfo": false,
      "isChildDirected": false,
      "isExportCompliant": true,
      "containsAds": false,
      "locales": {
        "en-US": {
          "privacyPolicyUrl": "https://mindfulliving.app/privacy",
          "termsOfUseUrl": "https://mindfulliving.app/terms"
        }
      }
    },
    "apis": {
      "custom": {
        "endpoint": {
          "uri": "https://us-central1-hub4apps-mindfulliving.cloudfunctions.net/alexaSkill"
        }
      }
    }
  }
}
```

---

## 🗣️ Step 2: Interaction Model

### Intents Configuration
```json
{
  "interactionModel": {
    "languageModel": {
      "invocationName": "mindful living",
      "intents": [
        {
          "name": "GetLifeAdviceIntent",
          "slots": [
            {
              "name": "situation",
              "type": "AMAZON.SearchQuery",
              "samples": [
                "{situation}",
                "help with {situation}",
                "advice about {situation}",
                "guidance for {situation}"
              ]
            }
          ],
          "samples": [
            "I'm dealing with {situation}",
            "I need help with {situation}",
            "advice about {situation}",
            "what should I do about {situation}",
            "I'm struggling with {situation}",
            "how to handle {situation}",
            "tips for {situation}",
            "I'm feeling {situation}",
            "help me with {situation}",
            "guidance on {situation}"
          ]
        },
        {
          "name": "StartBreathingExerciseIntent",
          "slots": [],
          "samples": [
            "breathing exercise",
            "help me breathe",
            "calm down",
            "reduce stress",
            "I need to relax",
            "stress relief",
            "help me relax"
          ]
        },
        {
          "name": "GetDailyReflectionIntent",
          "slots": [],
          "samples": [
            "daily reflection",
            "reflection for today",
            "today's reflection",
            "inspire me",
            "motivate me",
            "give me wisdom"
          ]
        },
        {
          "name": "CheckWellnessScoreIntent",
          "slots": [],
          "samples": [
            "check my wellness score",
            "how am I doing",
            "my progress",
            "my wellness",
            "how's my score"
          ]
        },
        {
          "name": "AMAZON.HelpIntent",
          "samples": []
        },
        {
          "name": "AMAZON.CancelIntent",
          "samples": []
        },
        {
          "name": "AMAZON.StopIntent",
          "samples": []
        }
      ]
    }
  }
}
```

---

## 🔥 Step 3: Firebase Functions Backend

### Deploy Alexa Handler
```bash
cd backend/functions
npm install
npm run build
firebase deploy --only functions:alexaSkill
```

### Handler Implementation
```typescript
// backend/functions/src/alexa_handler.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const alexaSkill = functions.https.onRequest(async (req, res) => {
  const request = req.body;

  console.log('Alexa Request:', JSON.stringify(request));

  // Verify request is from Alexa
  if (!verifyAlexaRequest(req)) {
    return res.status(400).send('Invalid request');
  }

  try {
    let response;

    switch (request.request.type) {
      case 'LaunchRequest':
        response = handleLaunch();
        break;

      case 'IntentRequest':
        response = await handleIntent(request);
        break;

      case 'SessionEndedRequest':
        response = handleSessionEnd();
        break;

      default:
        response = buildResponse('Sorry, I didn\'t understand that.');
    }

    res.json(response);

  } catch (error) {
    console.error('Error:', error);
    res.json(buildResponse('Sorry, something went wrong. Please try again.'));
  }
});

function handleLaunch() {
  return buildResponse(
    'Welcome to Mindful Living. I can help you with life situations, breathing exercises, or daily reflections. What can I help you with?',
    false // Don't end session
  );
}

async function handleIntent(request: any) {
  const intentName = request.request.intent.name;
  const userId = request.session.user.userId;

  console.log(`Intent: ${intentName}`);

  switch (intentName) {
    case 'GetLifeAdviceIntent':
      return await handleLifeAdvice(request);

    case 'StartBreathingExerciseIntent':
      return handleBreathingExercise();

    case 'GetDailyReflectionIntent':
      return await handleDailyReflection();

    case 'CheckWellnessScoreIntent':
      return await handleWellnessScore(userId);

    case 'AMAZON.HelpIntent':
      return handleHelp();

    case 'AMAZON.StopIntent':
    case 'AMAZON.CancelIntent':
      return buildResponse('Take care, and remember to breathe.', true);

    default:
      return buildResponse(
        'I\'m not sure how to help with that. Try asking for advice about a specific situation.',
        false
      );
  }
}

async function handleLifeAdvice(request: any) {
  const situation = request.request.intent.slots.situation?.value;

  if (!situation) {
    return buildResponse(
      'I didn\'t catch what you need help with. Could you tell me about your situation?',
      false
    );
  }

  console.log(`Searching for: ${situation}`);

  // Search life situations
  const results = await searchSituations(situation);

  if (results.length === 0) {
    return buildResponse(
      `I couldn't find specific guidance for "${situation}", but I'm here to help. Try asking about common topics like work stress, relationships, or parenting.`,
      false
    );
  }

  const best = results[0];

  // Build voice-optimized response (< 90 seconds)
  const speechText = `
    Here's guidance for ${situation}.

    <break time="500ms"/>

    <emphasis level="moderate">Mindful Approach:</emphasis>
    ${truncateForVoice(best.mindfulApproach, 100)}

    <break time="800ms"/>

    <emphasis level="moderate">Practical Steps:</emphasis>
    ${best.practicalSteps.slice(0, 3).join('. <break time="500ms"/> ')}

    <break time="500ms"/>

    Would you like to hear more, or try a breathing exercise?
  `;

  // Log analytics
  await logVoiceQuery(situation, best.id, 'alexa');

  // Increment popularity
  await db.collection('life_situations').doc(best.id).update({
    voicePopularity: admin.firestore.FieldValue.increment(1)
  });

  return buildResponseWithCard(
    speechText,
    best.title,
    best.description,
    false
  );
}

function handleBreathingExercise() {
  const exercise = `
    <speak>
      Let's do a calming breathing exercise. Find a comfortable position.

      <break time="1s"/>

      Breathe in slowly through your nose for 4 counts.
      <break time="4s"/>

      Hold for 7 counts.
      <break time="7s"/>

      Breathe out slowly through your mouth for 8 counts.
      <break time="8s"/>

      <break time="1s"/>

      Let's do that two more times.

      <break time="1s"/>

      Breathe in for 4.
      <break time="4s"/>
      Hold for 7.
      <break time="7s"/>
      Out for 8.
      <break time="8s"/>

      <break time="1s"/>

      One more time. In for 4.
      <break time="4s"/>
      Hold for 7.
      <break time="7s"/>
      Out for 8.
      <break time="8s"/>

      <break time="2s"/>

      Well done. Notice how you feel. You can practice this anytime you need calm.
    </speak>
  `;

  return buildResponse(exercise, true);
}

async function handleDailyReflection() {
  // Get today's reflection
  const today = new Date().toISOString().split('T')[0];

  const reflection = await db
    .collection('daily_reflections')
    .where('date', '==', today)
    .limit(1)
    .get();

  if (reflection.empty) {
    // Fallback reflection
    return buildResponse(
      'Here\'s today\'s reflection: Small acts of mindfulness create lasting change. What one mindful choice can you make today?',
      false
    );
  }

  const data = reflection.docs[0].data();

  return buildResponse(
    `Today's reflection: ${data.text}. ${data.prompt}`,
    false
  );
}

async function handleWellnessScore(userId: string) {
  const userDoc = await db.collection('users').doc(userId).get();

  if (!userDoc.exists) {
    return buildResponse(
      'I don\'t have your wellness data yet. Open the Mindful Living app to start tracking your progress.',
      true
    );
  }

  const wellnessScore = userDoc.data()?.wellnessScore || 50;
  const streak = userDoc.data()?.streak || 0;

  return buildResponse(
    `Your wellness score is ${wellnessScore} out of 100. You have a ${streak} day streak! Keep up the great work.`,
    false
  );
}

function handleHelp() {
  return buildResponse(
    'I can help you with life situations, breathing exercises, daily reflections, or check your wellness score. What would you like to try?',
    false
  );
}

function handleSessionEnd() {
  return buildResponse('', true);
}

// Helper functions
async function searchSituations(query: string): Promise<any[]> {
  // Implement voice search (reuse from voice_search_service)
  const results = await db
    .collection('life_situations')
    .where('voiceKeywords', 'array-contains-any', query.toLowerCase().split(' '))
    .limit(3)
    .get();

  return results.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

function truncateForVoice(text: string, wordLimit: number): string {
  const words = text.split(' ');
  if (words.length <= wordLimit) return text;
  return words.slice(0, wordLimit).join(' ') + '...';
}

async function logVoiceQuery(query: string, situationId: string, platform: string) {
  await db.collection('voice_queries').add({
    query,
    situationId,
    platform,
    timestamp: admin.firestore.Timestamp.now()
  });
}

function buildResponse(text: string, shouldEndSession: boolean = false) {
  return {
    version: '1.0',
    response: {
      outputSpeech: {
        type: 'SSML',
        ssml: `<speak>${text}</speak>`
      },
      shouldEndSession
    }
  };
}

function buildResponseWithCard(
  text: string,
  title: string,
  content: string,
  shouldEndSession: boolean
) {
  return {
    version: '1.0',
    response: {
      outputSpeech: {
        type: 'SSML',
        ssml: `<speak>${text}</speak>`
      },
      card: {
        type: 'Standard',
        title,
        text: content,
        image: {
          smallImageUrl: 'https://your-cdn.com/card-small.png',
          largeImageUrl: 'https://your-cdn.com/card-large.png'
        }
      },
      shouldEndSession
    }
  };
}

function verifyAlexaRequest(req: any): boolean {
  // In production, verify signature
  // For now, basic check
  return req.body && req.body.request;
}
```

---

## 🧪 Step 4: Testing

### Test Script
```bash
#!/bin/bash
# scripts/test_alexa.sh

echo "Testing Alexa Skill..."

# Test endpoint
ENDPOINT="https://us-central1-hub4apps-mindfulliving.cloudfunctions.net/alexaSkill"

# Test LaunchRequest
curl -X POST $ENDPOINT \
  -H "Content-Type: application/json" \
  -d '{
    "request": {
      "type": "LaunchRequest"
    },
    "session": {
      "user": {
        "userId": "test-user"
      }
    }
  }'

echo "\n\n---\n\n"

# Test Life Advice Intent
curl -X POST $ENDPOINT \
  -H "Content-Type: application/json" \
  -d '{
    "request": {
      "type": "IntentRequest",
      "intent": {
        "name": "GetLifeAdviceIntent",
        "slots": {
          "situation": {
            "value": "work stress"
          }
        }
      }
    },
    "session": {
      "user": {
        "userId": "test-user"
      }
    }
  }'
```

### Testing Checklist
- [ ] Launch request works
- [ ] Life advice intent responds correctly
- [ ] Breathing exercise flows properly
- [ ] Daily reflection returns content
- [ ] Wellness score retrieves data
- [ ] Help intent explains features
- [ ] Response time < 3 seconds
- [ ] SSML formatting is correct
- [ ] Cards display on Echo Show

---

## 📤 Step 5: Certification

### Pre-Submission Checklist
- [ ] Skill works in all regions
- [ ] Privacy policy published
- [ ] Terms of use published
- [ ] Icons uploaded (108x108, 512x512)
- [ ] Example phrases are accurate
- [ ] No religious content in responses
- [ ] Error handling is graceful
- [ ] Help intent is clear

### Certification Process
1. **Submit in Developer Console**
2. **Automated testing** (1-2 hours)
3. **Manual review** (2-5 days)
4. **Address feedback** (if any)
5. **Approval & publication**

### Common Rejection Reasons
- Unclear invocation name
- Poor error handling
- Missing help functionality
- Broken HTTPS endpoint
- Privacy policy issues

---

## 📊 Monitoring & Analytics

### Key Metrics
```typescript
// Track in Firebase
interface AlexaMetrics {
  dailyInvocations: number;
  uniqueUsers: number;
  averageSessionLength: number;
  topQueries: string[];
  successRate: number;
  errorRate: number;
}
```

### Alerts
- Error rate > 5%
- Response time > 5 seconds
- Daily invocations drop > 20%

---

## 🚀 Deployment Commands

```bash
# Full deployment
./scripts/deploy_alexa_full.sh

# Update backend only
firebase deploy --only functions:alexaSkill

# Update interaction model only
./scripts/update_alexa_model.sh

# View logs
firebase functions:log --only alexaSkill
```

---

## 🎯 Success Criteria

### Must Pass
- [ ] Skill launches successfully
- [ ] Responds to all intents
- [ ] Voice responses < 90 seconds
- [ ] Response time < 3 seconds
- [ ] No crashes or errors
- [ ] Certification approved

### Should Have
- [ ] Natural conversation flow
- [ ] Clear, helpful responses
- [ ] Good user ratings (4.5+)
- [ ] 100+ daily active users (month 1)

---

## 📚 Resources
- [Alexa Skills Kit Documentation](https://developer.amazon.com/en-US/docs/alexa/ask-overviews/what-is-the-alexa-skills-kit.html)
- [Voice Design Best Practices](https://developer.amazon.com/en-US/docs/alexa/alexa-design/get-started.html)
- [SSML Reference](https://developer.amazon.com/en-US/docs/alexa/custom-skills/speech-synthesis-markup-language-ssml-reference.html)

---

**Timeline: 3-4 days to live Alexa skill! 🎙️**
