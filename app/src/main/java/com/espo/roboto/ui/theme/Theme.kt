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
