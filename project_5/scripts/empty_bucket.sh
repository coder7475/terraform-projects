#!/bin/bash

set -e

BUCKET_NAME="$1"

if [ -z "$BUCKET_NAME" ]; then
  echo "❌ Usage: $0 <bucket-name>"
  exit 1
fi

echo "🧹 Cleaning versioned bucket: $BUCKET_NAME"

while true; do
  RESPONSE=$(aws s3api list-object-versions \
    --bucket "$BUCKET_NAME" \
    --output json)

  OBJECTS=$(echo "$RESPONSE" | jq '{
    Objects: [
      (.Versions[]? | {Key: .Key, VersionId: .VersionId}),
      (.DeleteMarkers[]? | {Key: .Key, VersionId: .VersionId})
    ]
  }')

  COUNT=$(echo "$OBJECTS" | jq '.Objects | length')

  if [ "$COUNT" -eq 0 ]; then
    echo "✅ Bucket is fully cleaned."
    break
  fi

  echo "🗑️ Deleting $COUNT objects..."

  aws s3api delete-objects \
    --bucket "$BUCKET_NAME" \
    --delete "$OBJECTS"

done

echo "🎉 Done."