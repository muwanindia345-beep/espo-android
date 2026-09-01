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
