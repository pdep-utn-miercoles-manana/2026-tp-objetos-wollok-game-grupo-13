import wollok.game.*
import arena.*
import victorias.*
import menu.*
import src.direcciones.*

object barraSuperiorFondoUI {
    method position() = game.at(0, arena.alto())
    method image() = "barra_ui.png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

class IndicadorJugadorUI {
    const property jugador
    var property position

    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method victorias() = registroVictorias.victoriasDe(jugador.numeroJugador())

    method text() {
        const cabecera = "J" + jugador.numeroJugador() + " " + jugador.color().toUpperCase() + " (★" + self.victorias() + ")"
        if (not jugador.estaVivo()) {
            return cabecera + "\n[CAIDO]"
        }
        return cabecera + "\n"
            + "B:" + jugador.bombasDisponibles() + "/" + jugador.maxBombas()
            + " F:" + jugador.alcanceFuego()
            + " V:" + jugador.nivelVelocidad()
    }

    method textColor() = if (jugador.estaVivo()) "FFFFFF" else "FF4444"
}

object indicadorRelojLavaUI {
    method position() = game.at(10, arena.alto())
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method text() {
        if (interfazUI.victoriaVisible()) {
            const ganador = interfazUI.jugadorGanador()
            return "¡GANADOR: J" + ganador.numeroJugador() + " " + ganador.color().toUpperCase() + "!\nPartida finalizada"
        }
        if (interfazUI.gameOverVisible()) return "¡GAME OVER!\nPartida finalizada"
        if (interfazUI.pausaVisible()) return "JUEGO EN PAUSA\n[ESC] para continuar"
        return gestorLava.textoRelojLava()
    }

    method textColor() {
        if (interfazUI.victoriaVisible()) return "7CFC00"
        if (interfazUI.gameOverVisible()) return "FF4444"
        if (interfazUI.pausaVisible()) return "66E0FF"
        return gestorLava.colorRelojLava()
    }
}

object indicadorEstadoArenaUI {
    method position() = game.at(13, arena.alto())
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method text() {
        return "ANILLO MAGMA: " + gestorLava.nivelColapso() + "/" + gestorLava.maxNiveles() + "\n"
            + "Activos: " + interfazUI.cantidadJugadoresVivos() + "/" + interfazUI.jugadores().size()
    }

    method textColor() = if (interfazUI.cantidadJugadoresVivos() > 0) "66E0FF" else "FF4444"
}

object cartelGameOverUI {
    method position() = game.at(3, 5)
    method image() = "game_over.png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

object textoGameOverUI {
    method position() = game.at(4.5, 5)
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method text() = "Ningun jugador sobrevivio\n[R] Reiniciar  |  [M] Selector"
    method textColor() = "FFFFFF"
}

object cartelVictoriaUI {
    method position() = game.at(3, 5)
    method image() = "victoria.png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

object textoVictoriaUI {
    method position() = game.at(4.3, 5)
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method text() {
        const ganador = interfazUI.jugadorGanador()
        return "¡GANADOR: JUGADOR " + ganador.numeroJugador() + " (" + ganador.color().toUpperCase() + ")!\n[R] Revancha  |  [M] Selector"
    }
    method textColor() = "FFD700"
}

object cartelPausaUI {
    method position() = game.at(3, 5)
    method image() = "pausa.png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

object textoPausaUI {
    method position() = game.at(4.6, 5)
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method text() = "Partida en pausa\n[ESC] Continuar  |  [M] Selector"
    method textColor() = "FFFFFF"
}

object interfazUI {
    const property jugadores = []
    var property gameOverVisible = false
    var property victoriaVisible = false
    var property pausaVisible = false
    var property jugadorGanador = null

    method reiniciar() {
        jugadores.clear()
        gameOverVisible = false
        victoriaVisible = false
        pausaVisible = false
        jugadorGanador = null
    }

    method iniciar(listaJugadores) {
        jugadores.clear()
        jugadores.addAll(listaJugadores)
        gameOverVisible = false
        victoriaVisible = false
        pausaVisible = false
        jugadorGanador = null

        game.addVisual(barraSuperiorFondoUI)

        // Ubicaciones de columnas de jugadores calibradas hacia la derecha con PosicionFluida (decimales exactos sin truncamiento)
        const posicionesX = [0.8, 3.1, 5.4, 7.7]
        (0 .. jugadores.size() - 1).forEach({ indiceJugador =>
            const jugador = jugadores.get(indiceJugador)
            game.addVisual(new IndicadorJugadorUI(
                jugador = jugador,
                position = new PosicionFluida(x = posicionesX.get(indiceJugador), y = arena.alto())
            ))
        })

        game.addVisual(indicadorRelojLavaUI)
        game.addVisual(indicadorEstadoArenaUI)
    }

    method mostrarPausa() {
        if (not pausaVisible and not gameOverVisible and not victoriaVisible) {
            pausaVisible = true
            game.addVisual(cartelPausaUI)
            game.addVisual(textoPausaUI)
        }
    }

    method ocultarPausa() {
        if (pausaVisible) {
            pausaVisible = false
            if (game.hasVisual(cartelPausaUI)) game.removeVisual(cartelPausaUI)
            if (game.hasVisual(textoPausaUI)) game.removeVisual(textoPausaUI)
        }
    }

    method mostrarVictoria(ganador) {
        self.ocultarPausa()
        if (not victoriaVisible and not gameOverVisible) {
            victoriaVisible = true
            jugadorGanador = ganador
            game.addVisual(cartelVictoriaUI)
            game.addVisual(textoVictoriaUI)
        }
    }

    method mostrarGameOver() {
        self.ocultarPausa()
        if (not gameOverVisible and not victoriaVisible) {
            gameOverVisible = true
            game.addVisual(cartelGameOverUI)
            game.addVisual(textoGameOverUI)
        }
    }

    method cantidadJugadoresVivos() = jugadores.count({ jugador => jugador.estaVivo() })
    method unicoJugadorVivo() = jugadores.find({ jugador => jugador.estaVivo() })
}

object imagenChisteUI {
    method position() = game.at(0, 0)
    method image() = "chiste_easter_egg_" + cinematicaChiste.frameActual() + ".png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

object textoChisteUI {
    method position() = game.at(3.5, 0.7)
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method text() {
        if (cinematicaChiste.frameActual() >= cinematicaChiste.totalFrames()) {
            const nombreGanador = if (cinematicaChiste.ganador() != null) cinematicaChiste.ganador().color().toUpperCase() else "CAMPEON"
            return "★ ¡" + nombreGanador + " OBTUVO 5 VICTORIAS! ★\n▶ Presiona [ENTER] para ir al selector ◀"
        }
        return ""
    }

    method textColor() = "FFD700"
}

object cinematicaChiste {
    var property activo = false
    var property frameActual = 1
    const property totalFrames = 25
    var property ganador = null
    var relojFadeActivo = false

    method iniciar(unGanador) {
        activo = true
        ganador = unGanador
        frameActual = 1

        game.clear()
        game.addVisual(imagenChisteUI)
        game.addVisual(textoChisteUI)
        self.asegurarLimpiezaVisual()

        keyboard.enter().onPressDo({
            if (activo) {
                self.salirAlMenu()
            }
        })

        self.iniciarFade()
    }

    method asegurarLimpiezaVisual() {
        const visualesPermitidos = [imagenChisteUI, textoChisteUI]
        game.allVisuals().forEach({ visual =>
            if (not visualesPermitidos.contains(visual)) {
                game.removeVisual(visual)
            }
        })
    }

    method iniciarFade() {
        relojFadeActivo = true
        game.onTick(260, "FADE_CHISTE", { self.avanzarFade() })
    }

    method avanzarFade() {
        if (activo) {
            self.asegurarLimpiezaVisual()
            if (frameActual < totalFrames) {
                frameActual = frameActual + 1
            } else if (relojFadeActivo) {
                relojFadeActivo = false
                game.removeTickEvent("FADE_CHISTE")
            }
        }
    }

    method salirAlMenu() {
        if (activo) {
            activo = false
            if (relojFadeActivo) {
                relojFadeActivo = false
                game.removeTickEvent("FADE_CHISTE")
            }
            menuSeleccion.iniciar()
        }
    }
}
