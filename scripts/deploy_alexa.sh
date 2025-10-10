#!/bin/bash
# Alexa Deployment Script

set -e

echo "🎙️  Deploying Alexa Skill for Mindful Living"
echo "==========================================="
echo ""

# Step 1: Deploy Firebase Functions
echo "Step 1: Deploying Firebase Functions..."
cd backend/functions
npm install
npm run build
firebase deploy --only functions:alexaSkill
cd ../..
echo "✅ Firebase Functions deployed"
echo ""

# Step 2: Test endpoint
echo "Step 2: Testing Alexa endpoint..."
ENDPOINT="https://us-central1-hub4apps-mindfulliving.cloudfunctions.net/alexaSkill"

TEST_REQUEST='{
  "request": {
    "type": "LaunchRequest"
  },
  "session": {
    "user": {
      "userId": "test-user"
    }
  }
}'

RESPONSE=$(curl -s -X POST $ENDPOINT \
  -H "Content-Type: application/json" \
  -d "$TEST_REQUEST")

if echo "$RESPONSE" | grep -q "Welcome to Mindful Living"; then
    echo "✅ Alexa endpoint working"
else
    echo "❌ Alexa endpoint test failed"
    echo "Response: $RESPONSE"
    exit 1
fi
echo ""

# Step 3: Instructions for Amazon Developer Console
echo "Step 3: Amazon Developer Console Setup"
echo "-------------------------------------"
echo "Manual steps required:"
echo ""
echo "1. Go to: https://developer.amazon.com/alexa/console/ask"
echo "2. Click 'Create Skill'"
echo "3. Configure:"
echo "   - Name: Mindful Living"
echo "   - Locale: English (US)"
echo "   - Model: Custom"
echo "   - Hosting: Provision your own"
echo ""
echo "4. Set endpoint to:"
echo "   $ENDPOINT"
echo ""
echo "5. Upload interaction model from:"
echo "   alexa-skill/interactionModel.json"
echo ""
echo "6. Test in Alexa Simulator"
echo ""
echo "7. Submit for certification when ready"
echo ""

echo "✅ Alexa deployment script complete!"
echo ""
echo "📝 Next: Follow manual steps above to complete setup"
