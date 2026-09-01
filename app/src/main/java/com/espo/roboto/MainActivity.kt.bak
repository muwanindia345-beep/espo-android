package com.espo.roboto

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.espo.roboto.network.ApiClient
import com.espo.roboto.ui.theme.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

data class Mesaĝo(val teksto: String, val estasUzanto: Boolean)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            EspoTheme {
                Surface(color = FonaKoloro) {
                    EspoEkrano()
                }
            }
        }
    }
}

@Composable
fun EspoEkrano() {
    val komenca = remember {
        mutableStateListOf(Mesaĝo("Saluton! Skribu al mi en Esperanto.", estasUzanto = false))
    }
    val tekstoKampo = remember { mutableStateOf("") }
    val ŝarĝante = remember { mutableStateOf(false) }
    val listoStato = rememberLazyListState()
    val scope = rememberCoroutineScope()

    fun sendi() {
        val mesaĝo = tekstoKampo.value.trim()
        if (mesaĝo.isEmpty() || ŝarĝante.value) return

        komenca.add(Mesaĝo(mesaĝo, estasUzanto = true))
        tekstoKampo.value = ""
        ŝarĝante.value = true

        scope.launch {
            try {
                val respondo = withContext(Dispatchers.IO) {
                    ApiClient.sendiMesaĝon(mesaĝo)
                }
                komenca.add(Mesaĝo(respondo.teksto, estasUzanto = false))
            } catch (e: Exception) {
                komenca.add(Mesaĝo("⚠️ Ne eblis atingi la servilon: ${e.message}", estasUzanto = false))
            } finally {
                ŝarĝante.value = false
                listoStato.animateScrollToItem(komenca.size - 1)
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(FonaKoloro)
            .padding(top = 16.dp, bottom = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Espo — Via Esperanto-Roboto",
            color = Color.White,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(12.dp))

        AnimaciaVizaĝo(parolas = ŝarĝante.value)

        Spacer(modifier = Modifier.height(12.dp))

        LazyColumn(
            state = listoStato,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(0.94f)
                .clip(RoundedCornerShape(10.dp))
                .background(BabilejoFono)
                .padding(10.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            items(komenca) { m ->
                BabilVeziko(m)
            }
        }

        Spacer(modifier = Modifier.height(8.dp))

        Row(
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
        }
    }
}

@Composable
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

private fun Modifier.fillMaxWidth(fraction: Float, min: Float): Modifier = this

@Composable
fun AnimaciaVizaĝo(parolas: Boolean) {
    val infinita = rememberInfiniteTransition(label = "vizaĝo")

    val flosado by infinita.animateFloat(
        initialValue = 0f,
        targetValue = -8f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "flosado"
    )

    val palpebrumo by infinita.animateFloat(
        initialValue = 1f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = keyframes {
                durationMillis = 4000
                1f at 0
                1f at 3600
                0.1f at 3800
                1f at 4000
            },
            repeatMode = RepeatMode.Restart
        ),
        label = "palpebrumo"
    )

    Box(
        modifier = Modifier
            .offset(y = flosado.dp)
            .size(80.dp)
            .clip(CircleShape)
            .background(
                Brush.linearGradient(
                    colors = listOf(VizaĝoHelaBlua, VizaĝoProfundaBlua, VizaĝoHelaBlua)
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Row(
            modifier = Modifier.offset(y = (-6).dp),
            horizontalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(10.dp, (10 * palpebrumo).dp)
                    .clip(CircleShape)
                    .background(FonaKoloro)
            )
            Box(
                modifier = Modifier
                    .size(10.dp, (10 * palpebrumo).dp)
                    .clip(CircleShape)
                    .background(FonaKoloro)
            )
        }

        Box(
            modifier = Modifier
                .offset(y = 16.dp)
                .size(if (parolas) 18.dp else 26.dp, if (parolas) 6.dp else 12.dp)
                .clip(RoundedCornerShape(bottomStart = 20.dp, bottomEnd = 20.dp))
                .background(FonaKoloro)
        )
    }
}
