#!/data/data/com.termux/files/usr/bin/bash
# patch_bubble_width_real_fix.sh — Ĝusta max-width por babilbuloj (BoxWithConstraints)

set -e

DOSIERO="app/src/main/java/com/espo/roboto/MainActivity.kt"

if [ ! -f "$DOSIERO" ]; then
  echo "Eraro: $DOSIERO ne ekzistas ĉi tie."
  exit 1
fi

cp "$DOSIERO" "$DOSIERO.bak3"

python3 << 'PYEOF'
DOSIERO = "app/src/main/java/com/espo/roboto/MainActivity.kt"
with open(DOSIERO, "r", encoding="utf-8") as f:
    enhavo = f.read()

MALNOVA = '''@Composable
fun BabilVeziko(m: Mesaĝo) {
    val fono = if (m.estasUzanto) UzantaVeziko else RobotaVeziko
    val tekstoKoloro = if (m.estasUzanto) FonaKoloro else Color.White
    val vico = if (m.estasUzanto) Arrangement.End else Arrangement.Start

    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = vico) {
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(16.dp))
                .background(fono)
                .padding(horizontal = 14.dp, vertical = 10.dp)
                .fillMaxWidth(0.8f, min = 0f)
        ) {
            Text(text = m.teksto, color = tekstoKoloro, fontSize = 15.sp)
        }
    }
}

private fun Modifier.fillMaxWidth(fraction: Float, min: Float): Modifier = this'''

NOVA = '''@Composable
fun BabilVeziko(m: Mesaĝo) {
    val fono = if (m.estasUzanto) UzantaVeziko else RobotaVeziko
    val tekstoKoloro = if (m.estasUzanto) FonaKoloro else Color.White
    val vico = if (m.estasUzanto) Arrangement.End else Arrangement.Start

    BoxWithConstraints(modifier = Modifier.fillMaxWidth()) {
        val maksLarĝo = maxWidth * 0.8f
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = vico) {
            Box(
                modifier = Modifier
                    .widthIn(max = maksLarĝo)
                    .clip(RoundedCornerShape(16.dp))
                    .background(fono)
                    .padding(horizontal = 14.dp, vertical = 10.dp)
            ) {
                Text(text = m.teksto, color = tekstoKoloro, fontSize = 15.sp)
            }
        }
    }
}'''

if MALNOVA not in enhavo:
    print("⚠️  Averto: ne trovis la atenditan BabilVeziko-blokon. Nenio ŝanĝita.")
else:
    enhavo = enhavo.replace(MALNOVA, NOVA)
    with open(DOSIERO, "w", encoding="utf-8") as f:
        f.write(enhavo)
    print("✅ BabilVeziko riparita — bubloj nun ĝuste tondas je 80% larĝo.")
PYEOF

echo ""
echo "🎉 Farita! Puŝu al GitHub por rekonstrui la APK-on."
