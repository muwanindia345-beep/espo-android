#!/data/data/com.termux/files/usr/bin/bash
# patch_input_bar_fix2.sh — Riparas teksto-tondon kaj imePadding

set -e

DOSIERO="app/src/main/java/com/espo/roboto/MainActivity.kt"

if [ ! -f "$DOSIERO" ]; then
  echo "Eraro: $DOSIERO ne ekzistas ĉi tie."
  exit 1
fi

cp "$DOSIERO" "$DOSIERO.bak2"

python3 << 'PYEOF'
DOSIERO = "app/src/main/java/com/espo/roboto/MainActivity.kt"
with open(DOSIERO, "r", encoding="utf-8") as f:
    enhavo = f.read()

# 1) WindowCompat por ke imePadding ĝuste funkciu (edge-to-edge)
if "WindowCompat" not in enhavo:
    enhavo = enhavo.replace(
        "import androidx.activity.compose.setContent",
        "import androidx.activity.compose.setContent\nimport androidx.activity.enableEdgeToEdge"
    )
    enhavo = enhavo.replace(
        "        super.onCreate(savedInstanceState)\n        setContent {",
        "        super.onCreate(savedInstanceState)\n        enableEdgeToEdge()\n        setContent {"
    )
    print("✅ enableEdgeToEdge aldonita.")
else:
    print("ℹ️  Jam havas edge-to-edge agordon.")

# 2) Ripari la Row-alton — uzi IntrinsicSize.Min anstataŭ fiksa 56dp,
#    tio evitas ke la teksto-kampo tondu la tekston
MALNOVA = '''        Row(
            modifier = Modifier
                .fillMaxWidth(0.94f)
                .height(56.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = tekstoKampo.value,
                onValueChange = { tekstoKampo.value = it },
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight(),'''

NOVA = '''        Row(
            modifier = Modifier
                .fillMaxWidth(0.94f)
                .height(IntrinsicSize.Min),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = tekstoKampo.value,
                onValueChange = { tekstoKampo.value = it },
                textStyle = androidx.compose.ui.text.TextStyle(fontSize = 16.sp),
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight(),'''

if MALNOVA in enhavo:
    enhavo = enhavo.replace(MALNOVA, NOVA)
    print("✅ Row-alto ĝustigita (IntrinsicSize.Min).")
else:
    print("⚠️  Ne trovis la Row-blokon por la alto-ĝustigo.")

with open(DOSIERO, "w", encoding="utf-8") as f:
    f.write(enhavo)
PYEOF

echo ""
echo "🎉 Farita! Puŝu al GitHub por rekonstrui la APK-on."
