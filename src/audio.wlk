import wollok.game.*

// Gestor de audio para efectos y música de fondo con soporte seguro para entornos de prueba
object gestorAudio {
    var musicaFondo = null
    var property sonidoHabilitado = true

    method reproducirEfecto(nombreArchivo) {
        if (sonidoHabilitado) {
            try {
                game.sound(nombreArchivo).play()
            } catch unError {
                // Silencioso si se ejecuta en consola sin motor de audio
            }
        }
    }

    method reproducirExplosion() {
        self.reproducirEfecto("sonido_explosion.wav")
    }

    method reproducirPowerUp() {
        self.reproducirEfecto("sonido_powerup.wav")
    }

    method reproducirErupcionGeiser() {
        self.reproducirEfecto("sonido_geiser.wav")
    }

    method iniciarMusica() {
        self.detenerMusica()
        if (sonidoHabilitado) {
            try {
                musicaFondo = game.sound("musica_fondo.mp3")
                musicaFondo.shouldLoop(true)
                musicaFondo.volume(0.25)
                musicaFondo.play()
            } catch unError {
                musicaFondo = null
            }
        }
    }

    method pausarMusica() {
        try {
            if (musicaFondo != null and musicaFondo.played()) {
                musicaFondo.pause()
            }
        } catch unError {}
    }

    method reanudarMusica() {
        try {
            if (musicaFondo != null) {
                musicaFondo.resume()
            }
        } catch unError {}
    }

    method detenerMusica() {
        try {
            if (musicaFondo != null and musicaFondo.played()) {
                musicaFondo.stop()
            }
        } catch unError {}
        musicaFondo = null
    }
}
