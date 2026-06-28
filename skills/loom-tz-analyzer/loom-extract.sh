#!/bin/bash
# loom-extract.sh - Extract Loom video transcript and metadata
# Usage: ./loom-extract.sh https://www.loom.com/share/VIDEO_ID [output_dir]

set -e

VIDEO_URL=$1
OUTPUT_DIR=${2:-"docs/transcripts"}
VIDEO_ID=$(echo "$VIDEO_URL" | sed 's#.*/##')
DATE=$(date +%Y-%m-%d)

if [ -z "$VIDEO_ID" ]; then
  echo "Usage: $0 <loom-url> [output-dir]"
  echo "Example: $0 https://www.loom.com/share/abc123def456"
  exit 1
fi

echo "📥 Fetching video data for $VIDEO_ID..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Fetch page HTML
PAGE_HTML=$(curl -s "https://www.loom.com/share/$VIDEO_ID")

# Extract transcript URL
TRANSCRIPT_URL=$(echo "$PAGE_HTML" | \
  grep -o '"source_url":"[^"]*transcription[^"]*' | \
  sed 's/"source_url":"//' | \
  head -1)

if [ -z "$TRANSCRIPT_URL" ]; then
  echo "❌ Could not find transcript URL."
  echo "   - Video might be private (check sharing settings)"
  echo "   - Transcript might still be processing (wait 2-3 min)"
  exit 1
fi

# Download transcript JSON
echo "📥 Downloading transcript..."
TRANSCRIPT_FILE="${OUTPUT_DIR}/${DATE}_${VIDEO_ID}.json"
curl -s "$TRANSCRIPT_URL" > "$TRANSCRIPT_FILE"

# Extract metadata from Apollo State
echo "📊 Extracting metadata..."
echo "$PAGE_HTML" | python3 -c "
import re, json, sys
html = sys.stdin.read()

# Find Apollo State
match = re.search(r'window\.__APOLLO_STATE__\s*=\s*({.*?});', html, re.DOTALL)
if match:
    state = json.loads(match.group(1))
    
    # Find video data
    video_key = 'RegularUserVideo:$VIDEO_ID'
    for key in state:
        if '$VIDEO_ID' in key and 'Video' in key:
            video = state[key]
            print(f\"Title: {video.get('title', 'Untitled')}\")
            
            # Find owner
            owner_ref = video.get('owner', {}).get('__ref', '')
            if owner_ref and owner_ref in state:
                user = state[owner_ref]
                print(f\"Author: {user.get('display_name', 'Unknown')}\")
            break
    
    # Find transcript details
    for key in state:
        if 'VideoTranscriptDetails' in key:
            details = state[key]
            print(f\"Created: {details.get('createdAt', 'N/A')}\")
            print(f\"Language: {details.get('captionsTranslatedLanguage', 'en')}\")
            break
" > "${OUTPUT_DIR}/${DATE}_${VIDEO_ID}_meta.txt"

# Parse transcript to readable text
echo "📝 Parsing transcript..."
python3 <<EOF
import json

with open('$TRANSCRIPT_FILE') as f:
    data = json.load(f)
    
    # Full text
    full_text = ' '.join([p['value'] for p in data['phrases']])
    
    # Save readable version
    with open('${OUTPUT_DIR}/${DATE}_${VIDEO_ID}.txt', 'w') as out:
        out.write(full_text)
    
    # Print summary
    duration = int(data['phrases'][-1]['ts'])
    print(f"\n✅ Transcript extracted successfully!")
    print(f"📊 Duration: {duration//60}:{duration%60:02d}")
    print(f"📊 Phrases: {len(data['phrases'])}")
    print(f"📄 Files saved:")
    print(f"   - ${TRANSCRIPT_FILE}")
    print(f"   - ${OUTPUT_DIR}/${DATE}_${VIDEO_ID}.txt")
    print(f"   - ${OUTPUT_DIR}/${DATE}_${VIDEO_ID}_meta.txt")
EOF

echo ""
cat "${OUTPUT_DIR}/${DATE}_${VIDEO_ID}_meta.txt"
