#!/bin/bash

# Fittie ElevenLabs API Test Script
# This script tests ElevenLabs voice synthesis capabilities

set -e  # Exit on error

echo "🎙️  Testing ElevenLabs API for Fittie project..."
echo ""

# Configuration
API_KEY="${ELEVENLABS_API_KEY:-}"
OUTPUT_DIR="./test-audio"
VOICE_ID="21m00Tcm4TlvDq8ikWAM"  # Default voice (Rachel)

# Check if API key is provided
if [ -z "$API_KEY" ]; then
    echo "📝 Please enter your ElevenLabs API key:"
    echo "   (or set ELEVENLABS_API_KEY environment variable)"
    read -r API_KEY
    
    if [ -z "$API_KEY" ]; then
        echo "❌ Error: API key is required"
        exit 1
    fi
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Configuration:"
echo "  Voice ID: $VOICE_ID"
echo "  Output Directory: $OUTPUT_DIR"
echo ""

# Test messages for coaching
TEST_MESSAGES=(
    "Good job! Keep going!"
    "Great form! Focus on your breathing."
    "You're doing amazing! Three more reps."
    "Perfect! Now take a deep breath and reset."
    "Excellent work! Remember to engage your core."
)

echo "🧪 Test 1: Basic Text-to-Speech"
echo "================================"
echo ""

for i in "${!TEST_MESSAGES[@]}"; do
    msg="${TEST_MESSAGES[$i]}"
    output_file="$OUTPUT_DIR/test_${i}.mp3"
    
    echo "Testing message $((i+1)): \"$msg\""
    
    curl -X POST "https://api.elevenlabs.io/v1/text-to-speech/$VOICE_ID" \
        -H "xi-api-key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"$msg\", \"voice_settings\": {\"stability\": 0.5, \"similarity_boost\": 0.75}}" \
        --output "$output_file" \
        --silent \
        --show-error
    
    if [ -f "$output_file" ]; then
        size=$(wc -c < "$output_file")
        echo "  ✅ Generated: $output_file (${size} bytes)"
    else
        echo "  ❌ Failed to generate audio"
    fi
    echo ""
done

echo ""
echo "🧪 Test 2: Streaming API (low latency)"
echo "======================================"
echo ""

STREAM_OUTPUT="$OUTPUT_DIR/stream_test.mp3"
echo "Testing streaming API with: \"${TEST_MESSAGES[0]}\""

curl -X POST "https://api.elevenlabs.io/v1/text-to-speech/$VOICE_ID/stream" \
    -H "xi-api-key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"text\": \"${TEST_MESSAGES[0]}\", \"voice_settings\": {\"stability\": 0.5, \"similarity_boost\": 0.75}}" \
    --output "$STREAM_OUTPUT" \
    --silent \
    --show-error

if [ -f "$STREAM_OUTPUT" ]; then
    size=$(wc -c < "$STREAM_OUTPUT")
    echo "  ✅ Generated: $STREAM_OUTPUT (${size} bytes)"
else
    echo "  ❌ Failed to generate streaming audio"
fi

echo ""
echo "🧪 Test 3: Fetching Available Voices"
echo "====================================="
echo ""

VOICES_OUTPUT="$OUTPUT_DIR/voices.json"
curl -X GET "https://api.elevenlabs.io/v1/voices" \
    -H "xi-api-key: $API_KEY" \
    --output "$VOICES_OUTPUT" \
    --silent \
    --show-error

if [ -f "$VOICES_OUTPUT" ]; then
    echo "  ✅ Voice list saved to: $VOICES_OUTPUT"
    
    # Extract and display voice names and IDs if jq is available
    if command -v jq &> /dev/null; then
        echo ""
        echo "Available voices for coaching:"
        jq -r '.voices[] | "  - \(.name) (\(.voice_id)) - \(.labels | to_entries | map(.value) | join(", "))"' "$VOICES_OUTPUT"
    else
        echo "  ℹ️  Install 'jq' to see formatted voice list"
    fi
else
    echo "  ❌ Failed to fetch voices"
fi

echo ""
echo "🧪 Test 4: Check API Usage/Limits"
echo "=================================="
echo ""

USER_INFO="$OUTPUT_DIR/user_info.json"
curl -X GET "https://api.elevenlabs.io/v1/user" \
    -H "xi-api-key: $API_KEY" \
    --output "$USER_INFO" \
    --silent \
    --show-error

if [ -f "$USER_INFO" ]; then
    echo "  ✅ User info saved to: $USER_INFO"
    
    if command -v jq &> /dev/null; then
        echo ""
        echo "API Usage Information:"
        jq -r '"  Subscription: \(.subscription.tier)
  Character Count: \(.subscription.character_count) / \(.subscription.character_limit)
  Can Extend Limit: \(.subscription.can_extend_character_limit)
  Next Character Reset: \(.subscription.next_character_count_reset_unix | tonumber | strftime("%Y-%m-%d %H:%M:%S"))"' "$USER_INFO" 2>/dev/null || jq '.' "$USER_INFO"
    fi
else
    echo "  ❌ Failed to fetch user info"
fi

echo ""
echo "🎉 ElevenLabs API testing complete!"
echo ""
echo "Summary:"
echo "  📁 Audio files: $OUTPUT_DIR/"
echo "  🔍 Voice list: $VOICES_OUTPUT"
echo "  📊 Usage info: $USER_INFO"
echo ""
echo "Next steps:"
echo "  1. Listen to generated audio files to evaluate quality"
echo "  2. Review available voices in $VOICES_OUTPUT"
echo "  3. Select appropriate voice IDs for coaching scenarios"
echo "  4. Document rate limits and pricing based on subscription tier"
echo "  5. Store API key securely in .env file"
echo ""
echo "Recommended voices for coaching:"
echo "  - Rachel (21m00Tcm4TlvDq8ikWAM) - Calm, clear"
echo "  - Bella (EXAVITQu4vr4xnSDxMaL) - Energetic, motivating"
echo "  - Josh (TxGEqnHWrfWFTfGW9XjX) - Confident, encouraging"
echo ""
