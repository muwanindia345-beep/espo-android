#!/data/data/com.termux/files/usr/bin/bash
# setup_ui.sh — Kreas Theme.kt, retan tavolon, kaj MainActivity.kt

set -e

mkdir -p app/src/main/res/xml

# ============================================================
# network_security_config.xml — permesas HTTP al localhost
# (la Flask-servilo funkcias en Termux sur la SAMA telefono)
# ============================================================
cat > app/src/main/res/xml/network_security_config.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="false">127.0.0.1</domain>
        <domain includeSubdomains="false">localhost</domain>
    </domain-config>
</network-security-config>
EOF

# Ĝisdatigi AndroidManifest.xml por uzi la sekurecan agordon
python3 << 'PYEOF'
with open("app/src/main/AndroidManifest.xml", "r") as f:
    enhavo = f.read()
if "networkSecurityConfig" not in enhavo:
    enhavo = enhavo.replace(
        'android:allowBackup="true"',
        'android:allowBackup="true"\n        android:networkSecurityConfig="@xml/network_security_config"'
    )
    with open("app/src/main/AndroidManifest.xml", "w") as f:
        f.write(enhavo)
    print("✅ AndroidManifest.xml ĝisdatigita.")
PYEOF

# ============================================================
# Theme.kt
# ============================================================
cat > app/src/main/java/com/espo/roboto/ui/theme/Theme.kt << 'EOF'
package com.espo.roboto.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val EspoSkemo = darkColorScheme(
    background = FonaKoloro,
    surface = BabilejoFono,
    primary = UzantaVeziko,
    onBackground = TekstoBlanka,
    onSurface = TekstoBlanka
)

@Composable
fun EspoTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = EspoSkemo,
        content = content
    )
}
EOF

# ============================================================
# ApiClient.kt — reto-tavolo al la Flask-backend
# ============================================================
cat > app/src/main/java/com/espo/roboto/network/ApiClient.kt << 'EOF'
package com.espo.roboto.network

import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.util.concurrent.TimeUnit

data class EspoRespondo(
    val teksto: String,
    val ligilo: String?,
    val bildo: String?
)

object ApiClient {
    // La Flask-servilo funkcias en Termux, sur la SAMA telefono ĉe la loka pordo 5000.
    private const val BAZA_URL = "http://127.0.0.1:5000"

    private val kliento = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

    fun sendiMesaĝon(mesaĝo: String): EspoRespondo {
        val korpo = JSONObject().apply {
            put("mesaĝo", mesaĝo)
        }.toString().toRequestBody("application/json; charset=utf-8".toMediaType())

        val peto = Request.Builder()
            .url("$BAZA_URL/babili")
            .post(korpo)
            .build()

        kliento.newCall(peto).execute().use { respondo ->
            if (!respondo.isSuccessful) {
                throw Exception("Servila eraro: ${respondo.code}")
            }
            val teksto = respondo.body?.string() ?: "{}"
            val json = JSONObject(teksto)
            return EspoRespondo(
                teksto = json.optString("respondo", ""),
                ligilo = json.optString("ligilo", null),
                bildo = json.optString("bildo", null)
            )
        }
    }
}
EOF

echo "✅ Theme.kt kaj ApiClient.kt kreitaj."
