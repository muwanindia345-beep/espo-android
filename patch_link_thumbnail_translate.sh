#!/data/data/com.termux/files/usr/bin/bash
# patch_link_thumbnail_translate.sh — Aldonas ligilon, bildon (Coil) kaj Traduki-butonon

set -e

for DOSIERO in app/build.gradle.kts \
               app/src/main/java/com/espo/roboto/MainActivity.kt \
               app/src/main/java/com/espo/roboto/network/ApiClient.kt; do
  if [ ! -f "$DOSIERO" ]; then
    echo "Eraro: $DOSIERO ne ekzistas ĉi tie."
    exit 1
  fi
  cp "$DOSIERO" "$DOSIERO.bak_lt"
done

python3 << 'PYEOF'
import re

# ============================================================
# 1) app/build.gradle.kts — aldoni Coil (bildo-ŝarĝado)
# ============================================================
DOSIERO = "app/build.gradle.kts"
with open(DOSIERO, "r", encoding="utf-8") as f:
    enhavo = f.read()

if "coil-compose" not in enhavo:
    MALNOVA = '''    // Retejaj vokoj al la Flask-backend
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")'''
    NOVA = '''    // Retejaj vokoj al la Flask-backend
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")

    // Bildo-ŝarĝado (thumbnails)
    implementation("io.coil-kt:coil-compose:2.7.0")'''
    if MALNOVA in enhavo:
        enhavo = enhavo.replace(MALNOVA, NOVA)
        with open(DOSIERO, "w", encoding="utf-8") as f:
            f.write(enhavo)
        print("✅ build.gradle.kts — Coil aldonita.")
    else:
        print("⚠️  build.gradle.kts — ne trovis la atenditan blokon.")
else:
    print("ℹ️  build.gradle.kts jam havas Coil — pasita.")


# ============================================================
# 2) ApiClient.kt — aldoni traduki() funkcion
# ============================================================
DOSIERO = "app/src/main/java/com/espo/roboto/network/ApiClient.kt"
with open(DOSIERO, "r", encoding="utf-8") as f:
    enhavo = f.read()

if "fun traduki(" not in enhavo:
    MALNOVA = '''            return EspoRespondo(
                teksto = json.optString("respondo", ""),
                ligilo = json.optString("ligilo", null),
                bildo = json.optString("bildo", null)
            )
        }
    }
}'''
    NOVA = '''            return EspoRespondo(
                teksto = json.optString("respondo", ""),
                ligilo = json.optString("ligilo", null),
                bildo = json.optString("bildo", null)
            )
        }
    }

    fun traduki(teksto: String): String {
        val korpo = JSONObject().apply {
            put("teksto", teksto)
        }.toString().toRequestBody("application/json; charset=utf-8".toMediaType())

        val peto = Request.Builder()
            .url("$BAZA_URL/traduki")
            .post(korpo)
            .build()

        kliento.newCall(peto).execute().use { respondo ->
            if (!respondo.isSuccessful) {
                throw Exception("Servila eraro: ${respondo.code}")
            }
            val korpoTeksto = respondo.body?.string() ?: "{}"
            val json = JSONObject(korpoTeksto)
            return json.optString("traduko", "")
        }
    }
}'''
    if MALNOVA in enhavo:
        enhavo = enhavo.replace(MALNOVA, NOVA)
        with open(DOSIERO, "w", encoding="utf-8") as f:
            f.write(enhavo)
        print("✅ ApiClient.kt — traduki() aldonita.")
    else:
        print("⚠️  ApiClient.kt — ne trovis la atenditan blokon.")
else:
    print("ℹ️  ApiClient.kt jam havas traduki() — pasita.")


# ============================================================
# 3) MainActivity.kt — importoj, Mesaĝo-klaso, sendi(), BabilVeziko
# ============================================================
DOSIERO = "app/src/main/java/com/espo/roboto/MainActivity.kt"
with open(DOSIERO, "r", encoding="utf-8") as f:
    enhavo = f.read()

# 3a) Novaj importoj
if "coil.compose.AsyncImage" not in enhavo:
    enhavo = enhavo.replace(
        "import androidx.compose.ui.unit.sp",
        "import androidx.compose.ui.unit.sp\n"
        "import androidx.compose.foundation.clickable\n"
        "import androidx.compose.ui.platform.LocalUriHandler\n"
        "import coil.compose.AsyncImage"
    )
    print("✅ MainActivity.kt — importoj aldonitaj.")
else:
    print("ℹ️  MainActivity.kt jam havas la importojn — pasita.")

# 3b) Mesaĝo-klaso: aldoni ligilo/bildo/traduko-statojn
MALNOVA_KLASO = 'data class Mesaĝo(val teksto: String, val estasUzanto: Boolean)'
NOVA_KLASO = '''class Mesaĝo(
    val teksto: String,
    val estasUzanto: Boolean,
    val ligilo: String? = null,
    val bildo: String? = null
) {
    var traduko by mutableStateOf<String?>(null)
    var tradukante by mutableStateOf(false)
}'''
if MALNOVA_KLASO in enhavo:
    enhavo = enhavo.replace(MALNOVA_KLASO, NOVA_KLASO)
    print("✅ MainActivity.kt — Mesaĝo-klaso ĝisdatigita.")
else:
    print("⚠️  MainActivity.kt — ne trovis la Mesaĝo data class.")

# 3c) sendi(): transdoni ligilo/bildo de la respondo
MALNOVA_SENDI = '                komenca.add(Mesaĝo(respondo.teksto, estasUzanto = false))'
NOVA_SENDI = '''                komenca.add(
                    Mesaĝo(
                        teksto = respondo.teksto,
                        estasUzanto = false,
                        ligilo = respondo.ligilo,
                        bildo = respondo.bildo
                    )
                )'''
if MALNOVA_SENDI in enhavo:
    enhavo = enhavo.replace(MALNOVA_SENDI, NOVA_SENDI)
    print("✅ MainActivity.kt — sendi() ĝisdatigita.")
else:
    print("⚠️  MainActivity.kt — ne trovis la sendi()-linion.")

# 3d) BabilVeziko: tuta anstataŭigo kun bildo, ligilo, traduki-butono
ŝablono_babil = re.compile(
    r'@Composable\nfun BabilVeziko\(m: Mesaĝo\) \{.*?\n\}\n\n(?=@Composable\nfun AnimaciaVizaĝo)',
    re.DOTALL
)

NOVA_BABIL = '''@Composable
fun BabilVeziko(m: Mesaĝo) {
    val fono = if (m.estasUzanto) UzantaVeziko else RobotaVeziko
    val tekstoKoloro = if (m.estasUzanto) FonaKoloro else Color.White
    val vico = if (m.estasUzanto) Arrangement.End else Arrangement.Start
    val uriTraktilo = LocalUriHandler.current
    val amplekso = rememberCoroutineScope()

    Column(modifier = Modifier.fillMaxWidth()) {

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

        if (!m.bildo.isNullOrBlank()) {
            BoxWithConstraints(modifier = Modifier.fillMaxWidth()) {
                val maksLarĝo = maxWidth * 0.8f
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = vico) {
                    AsyncImage(
                        model = m.bildo,
                        contentDescription = null,
                        modifier = Modifier
                            .padding(top = 4.dp)
                            .widthIn(max = maksLarĝo)
                            .clip(RoundedCornerShape(10.dp))
                    )
                }
            }
        }

        if (!m.ligilo.isNullOrBlank()) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = vico) {
                Text(
                    text = "🔗 Legu pli / Read more",
                    color = UzantaVeziko,
                    fontSize = 13.sp,
                    modifier = Modifier
                        .padding(top = 4.dp)
                        .clickable { uriTraktilo.openUri(m.ligilo) }
                )
            }
        }

        if (!m.estasUzanto) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Start) {
                if (m.traduko == null) {
                    Text(
                        text = if (m.tradukante) "⏳ ..." else "🌐 Traduki",
                        color = UzantaVeziko,
                        fontSize = 12.sp,
                        modifier = Modifier
                            .padding(top = 4.dp, start = 4.dp)
                            .clickable(enabled = !m.tradukante) {
                                m.tradukante = true
                                amplekso.launch {
                                    try {
                                        val t = withContext(Dispatchers.IO) {
                                            ApiClient.traduki(m.teksto)
                                        }
                                        m.traduko = t
                                    } catch (e: Exception) {
                                        m.traduko = "⚠️ Eraro"
                                    } finally {
                                        m.tradukante = false
                                    }
                                }
                            }
                    )
                } else {
                    BoxWithConstraints(modifier = Modifier.fillMaxWidth()) {
                        val maksLarĝo = maxWidth * 0.8f
                        Box(
                            modifier = Modifier
                                .padding(top = 4.dp)
                                .widthIn(max = maksLarĝo)
                                .clip(RoundedCornerShape(16.dp))
                                .background(TradukoVeziko)
                                .padding(horizontal = 14.dp, vertical = 10.dp)
                        ) {
                            Text(
                                text = m.traduko ?: "",
                                color = Color.White,
                                fontSize = 15.sp,
                                fontStyle = androidx.compose.ui.text.font.FontStyle.Italic
                            )
                        }
                    }
                }
            }
        }
    }
}

'''

if ŝablono_babil.search(enhavo):
    enhavo = ŝablono_babil.sub(NOVA_BABIL, enhavo)
    print("✅ MainActivity.kt — BabilVeziko anstataŭigita.")
else:
    print("⚠️  MainActivity.kt — ne trovis BabilVeziko-blokon per la ŝablono.")

with open(DOSIERO, "w", encoding="utf-8") as f:
    f.write(enhavo)
PYEOF

echo ""
echo "🎉 Farita! Puŝu al GitHub por rekonstrui la APK-on."
