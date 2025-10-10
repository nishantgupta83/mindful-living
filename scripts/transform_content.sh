#!/bin/bash
# Content Transformation Script - GitaWisdom to Mindful Living

set -e

echo "🔄 Content Transformation: GitaWisdom → Mindful Living"
echo "====================================================="
echo ""

INPUT_FILE="${1:-gitawisdom_scenarios.json}"
OUTPUT_FILE="${2:-mindful_situations.json}"

echo "Input:  $INPUT_FILE"
echo "Output: $OUTPUT_FILE"
echo ""

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found!"
    echo ""
    echo "Please provide GitaWisdom export file:"
    echo "  ./scripts/transform_content.sh /path/to/gitawisdom_scenarios.json"
    echo ""
    echo "Or connect to Supabase to export data automatically."
    exit 1
fi

# Run transformation
echo "🔄 Starting transformation..."
echo "   Removing ALL religious references..."
echo "   Creating secular wellness content..."
echo "   Generating voice keywords..."
echo ""

npx ts-node backend/content-transformation/content_transformer.ts \
    "$INPUT_FILE" \
    "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Transformation complete!"
    echo ""
    echo "📊 Summary:"
    echo "----------"

    # Count situations
    TOTAL=$(cat "$OUTPUT_FILE" | jq '. | length')
    echo "   Total situations: $TOTAL"

    # Show sample
    echo ""
    echo "📝 Sample Transformed Situation:"
    echo "------------------------------"
    cat "$OUTPUT_FILE" | jq '.[0] | {title, lifeArea, difficulty, voiceKeywords: .voiceKeywords[0:3]}'

    echo ""
    echo "🔍 Validation:"
    echo "-------------"

    # Check for religious terms
    RELIGIOUS_CHECK=$(cat "$OUTPUT_FILE" | grep -i -E "(krishna|gita|divine|sacred|spiritual|holy)" || echo "None found")

    if [ "$RELIGIOUS_CHECK" == "None found" ]; then
        echo "   ✅ No religious references found - Content is secular!"
    else
        echo "   ⚠️  WARNING: Religious terms detected:"
        echo "$RELIGIOUS_CHECK"
    fi

    echo ""
    echo "📁 Output saved to: $OUTPUT_FILE"
    echo ""
    echo "📤 Next Step: Upload to Firebase"
    echo "   firebase deploy --only firestore"
    echo ""
else
    echo ""
    echo "❌ Transformation failed!"
    exit 1
fi
