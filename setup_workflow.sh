#!/data/data/com.termux/files/usr/bin/bash
# setup_workflow.sh — Kreas la GitHub Actions-fluon kiu konstruas la APK-on

set -e

cat > .github/workflows/build.yml << 'EOF'
name: Konstrui Espo APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Elŝuti la kodon
        uses: actions/checkout@v4

      - name: Agordi JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Agordi Gradle
        uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.10.2'

      - name: Konstrui Debug APK
        run: gradle assembleDebug --no-daemon

      - name: Alŝuti la APK kiel artefakto
        uses: actions/upload-artifact@v4
        with:
          name: espo-debug-apk
          path: app/build/outputs/apk/debug/app-debug.apk
EOF

echo "✅ .github/workflows/build.yml kreita."
