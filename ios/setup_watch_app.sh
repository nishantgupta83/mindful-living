#!/bin/bash

# Setup Apple Watch App for Mindful Living
# This script prepares the Watch app configuration

echo "🎯 Setting up Apple Watch App for Mindful Living..."

# Create necessary directories
mkdir -p "MindfulWatch App/Assets.xcassets/AppIcon.appiconset"
mkdir -p "MindfulWatch Extension/Preview Content"

# Create Watch App Assets
cat > "MindfulWatch App/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "notification-center-icon-24@2x.png",
      "idiom" : "watch",
      "role" : "notificationCenter",
      "scale" : "2x",
      "size" : "24x24",
      "subtype" : "38mm"
    },
    {
      "filename" : "notification-center-icon-27.5@2x.png",
      "idiom" : "watch",
      "role" : "notificationCenter",
      "scale" : "2x",
      "size" : "27.5x27.5",
      "subtype" : "42mm"
    },
    {
      "filename" : "companion-settings-icon-29@2x.png",
      "idiom" : "watch",
      "role" : "companionSettings",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "companion-settings-icon-29@3x.png",
      "idiom" : "watch",
      "role" : "companionSettings",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "app-icon-40@2x.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "40x40",
      "subtype" : "38mm"
    },
    {
      "filename" : "app-icon-44@2x.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "44x44",
      "subtype" : "40mm"
    },
    {
      "filename" : "app-icon-46@2x.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "46x46",
      "subtype" : "41mm"
    },
    {
      "filename" : "app-icon-50@2x.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "50x50",
      "subtype" : "44mm"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create Watch App Assets directory structure
cat > "MindfulWatch App/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create Preview Content
cat > "MindfulWatch Extension/Preview Content/Preview Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ Watch app structure created!"
echo ""
echo "📋 Next Steps:"
echo "1. Open Xcode: cd ios && open Runner.xcworkspace"
echo "2. Add Watch Target:"
echo "   - File → Add Target → watchOS → Watch App"
echo "   - Product Name: 'MindfulWatch'"
echo "   - Bundle ID: com.hub4apps.mindfulliving.watchkitapp"
echo "   - Check 'Include Companion watchOS App'"
echo "3. Link existing Watch Extension files to the project"
echo "4. Build and run on Watch simulator"
echo ""
echo "🎉 Ready to test on Apple Watch!"