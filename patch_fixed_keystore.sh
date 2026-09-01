#!/data/data/com.termux/files/usr/bin/bash
# patch_fixed_keystore.sh — Uzas fiksan keystore-on, evitas de-instalon ĉiufoje

set -e

DOSIERO="app/build.gradle.kts"

if [ ! -f "$DOSIERO" ]; then
  echo "Eraro: $DOSIERO ne ekzistas ĉi tie."
  exit 1
fi

if [ ! -f "app/espo-debug.keystore" ]; then
  echo "Eraro: app/espo-debug.keystore ne ekzistas. Unue kreu ĝin per keytool."
  exit 1
fi

cp "$DOSIERO" "$DOSIERO.bak"

python3 << 'PYEOF'
DOSIERO = "app/build.gradle.kts"
with open(DOSIERO, "r", encoding="utf-8") as f:
    enhavo = f.read()

MALNOVA = '''android {
    namespace = "com.espo.roboto"
    compileSdk = 35'''

NOVA = '''android {
    namespace = "com.espo.roboto"
    compileSdk = 35

    signingConfigs {
        getByName("debug") {
            storeFile = file("espo-debug.keystore")
            storePassword = "espo12345"
            keyAlias = "espo"
            keyPassword = "espo12345"
        }
    }'''

if MALNOVA not in enhavo:
    print("⚠️  Averto: ne trovis la atenditan blokon.")
else:
    enhavo = enhavo.replace(MALNOVA, NOVA)
    with open(DOSIERO, "w", encoding="utf-8") as f:
        f.write(enhavo)
    print("✅ build.gradle.kts ĝisdatigita kun fiksa keystore.")
PYEOF
