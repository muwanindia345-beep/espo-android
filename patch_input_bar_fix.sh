#!/data/data/com.termux/files/usr/bin/bash
# patch_input_bar_fix.sh — Riparas la enigan breton (klavaro/navigacia breto kolizio)

set -e

DOSIERO="app/src/main/java/com/espo/roboto/MainActivity.kt"

if [ ! -f "$DOSIERO" ]; then
  echo "Eraro: $DOSIERO ne ekzistas ĉi tie."
  exit 1
fi

cp "$DOSIERO" "$DOSIERO.bak"

python3 << 'PYEOF'
DOSIERO = "app/src/main/java/com/espo/roboto/MainActivity.kt"
with open(DOSIERO, "r", encoding="utf-8") as f:
    enhavo = f.read()

# 1) Aldoni imePadding + navigationBarsPadding importojn
if "import androidx.compose.foundation.layout.imePadding" not in enhavo:
    enhavo = enhavo.replace(
        "import androidx.compose.foundation.layout.*",
        "import androidx.compose.foundation.layout.*\nimport androidx.compose.foundation.layout.imePadding\nimport androidx.compose.foundation.layout.navigationBarsPadding\nimport androidx.compose.foundation.layout.systemBarsPadding"
    )

# 2) Ĉefa Column: aldoni systemBarsPadding + imePadding
MALNOVA_COLUMN = '''    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(FonaKoloro)
            .padding(top = 16.dp, bottom = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {'''

NOVA_COLUMN = '''    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(FonaKoloro)
            .systemBarsPadding()
            .imePadding()
            .padding(top = 16.dp, bottom = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {'''

if MALNOVA_COLUMN in enhavo:
    enhavo = enhavo.replace(MALNOVA_COLUMN, NOVA_COLUMN)
    print("✅ Ĉefa Column ĝisdatigita kun sistemaj remburoj.")
else:
    print("⚠️  Ne trovis la Column-blokon.")

# 3) Enigan vicon tute anstataŭigi — pli fidinda formo/aranĝo
MALNOVA_ROW = '''        Row(
            modifier = Modifier.fillMaxWidth(0.94f),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = tekstoKampo.value,
                onValueChange = { tekstoKampo.value = it },
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(topStart = 22.dp, bottomStart = 22.dp)),
                placeholder = { Text("Skribu mesaĝon en Esperanto...") },
                singleLine = true,
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Send),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White,
                    focusedTextColor = Color.Black,
                    unfocusedTextColor = Color.Black
                )
            )
            Button(
                onClick = { sendi() },
                shape = RoundedCornerShape(topEnd = 22.dp, bottomEnd = 22.dp),
                colors = ButtonDefaults.buttonColors(containerColor = UzantaVeziko),
                modifier = Modifier.height(56.dp)
            ) {
                Text("Sendi", color = FonaKoloro, fontWeight = FontWeight.Bold)
            }
        }'''

NOVA_ROW = '''        Row(
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
                    .fillMaxHeight(),
                placeholder = { Text("Skribu mesaĝon...", maxLines = 1) },
                singleLine = true,
                shape = RoundedCornerShape(topStart = 22.dp, bottomStart = 22.dp, topEnd = 0.dp, bottomEnd = 0.dp),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Send),
                keyboardActions = KeyboardActions(onSend = { sendi() }),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White,
                    focusedTextColor = Color.Black,
                    unfocusedTextColor = Color.Black,
                    focusedBorderColor = Color.White,
                    unfocusedBorderColor = Color.White
                )
            )
            Button(
                onClick = { sendi() },
                shape = RoundedCornerShape(topStart = 0.dp, bottomStart = 0.dp, topEnd = 22.dp, bottomEnd = 22.dp),
                colors = ButtonDefaults.buttonColors(containerColor = UzantaVeziko),
                modifier = Modifier.fillMaxHeight()
            ) {
                Text("Sendi", color = FonaKoloro, fontWeight = FontWeight.Bold)
            }
        }'''

if MALNOVA_ROW in enhavo:
    enhavo = enhavo.replace(MALNOVA_ROW, NOVA_ROW)
    print("✅ Eniga vico anstataŭigita.")
else:
    print("⚠️  Ne trovis la Row-blokon — kontrolu mane.")

# 4) Aldoni KeyboardActions importon
if "import androidx.compose.foundation.text.KeyboardActions" not in enhavo:
    enhavo = enhavo.replace(
        "import androidx.compose.foundation.text.KeyboardOptions",
        "import androidx.compose.foundation.text.KeyboardOptions\nimport androidx.compose.foundation.text.KeyboardActions"
    )

with open(DOSIERO, "w", encoding="utf-8") as f:
    f.write(enhavo)
PYEOF

echo ""
echo "🎉 Farita! Puŝu al GitHub por rekonstrui la APK-on."
