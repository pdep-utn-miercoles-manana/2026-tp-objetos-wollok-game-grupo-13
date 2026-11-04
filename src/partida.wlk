import wollok.game.*
import superficie.*
import elementos.*
import jugador.*
import arena.*
import ui.*
import menu.*
import src.direcciones.*
import src.audio.*
import src.victorias.*

object partida {
    var property frameGlobal = 1
    var property jugadorPrincipal = null
    const property jugadoresActivos = []
    const slotsConfigurados = []
    var property partidaTerminada = false
    var property juegoPausado = false

    method reiniciar() {
        jugadoresActivos.clear()
        slotsConfigurados.clear()
        partidaTerminada = false
        juegoPausado = false
        jugadorPrincipal = null
        interfazUI.reiniciar()
    }

    method iniciar() {
        if (slotsConfigurados.isEmpty()) {
            const slotFrodo = new SlotSelectorJugador(
                numero = 1,
                columnaUI = 0,
                activo = true,
                indicePersonaje = 0,
                posicionSpawn = game.at(1, 1),
                descripcionControles = "Flechas + Espacio",
                teclaArriba = keyboard.up(),
                teclaAbajo = keyboard.down(),
                teclaIzquierda = keyboard.left(),
                teclaDerecha = keyboard.right(),
                teclaBomba = keyboard.space()
            )
            self.iniciarConSlots([slotFrodo])
        } else {
            const copiaSlots = []
            copiaSlots.addAll(slotsConfigurados)
            self.iniciarConSlots(copiaSlots)
        }
    }

    method iniciarConSlots(listaSlots) {
        game.clear()
        menuSeleccion.enMenu(false)
        partidaTerminada = false
        juegoPausado = false
        slotsConfigurados.clear()
        slotsConfigurados.addAll(listaSlots)

        if (not game.running()) {
            game.title("El Señor de las Bombas")
            game.width(arena.ancho())
            game.height(arena.alto() + 1)
            game.cellSize(48)
            game.ground("baldosa_suelo.png")
            game.boardGround("fondo_tablero.png")
        }

        // 1. Inicializar la arena y sus gestores autónomos
        arena.inicializarSuperficies()
        arena.inicializarObstaculos()
        gestorBombas.iniciar()
        gestorGeiseres.iniciar()
        gestorLava.iniciar()

        // 2. Instanciar los jugadores configurados desde los slots
        jugadoresActivos.clear()
        listaSlots.forEach({ slot =>
            const nuevoJugador = slot.crearJugador()
            jugadoresActivos.add(nuevoJugador)
            game.addVisual(nuevoJugador)
            slot.configurarControlesPara(nuevoJugador)
        })
        jugadorPrincipal = jugadoresActivos.first()

        // 3. Inicializar la interfaz visual
        interfazUI.iniciar(jugadoresActivos)

        // 4. Iniciar la música de fondo de la arena
        gestorAudio.iniciarMusica()

        // 5. Configurar atajos globales de teclado
        self.configurarTeclasGlobales()
    }

    method configurarTeclasGlobales() {
        const teclaEscape = new Key(keyCodes = ["Escape", ""])
        teclaEscape.onPressDo({ self.alternarPausa() })
        keyboard.p().onPressDo({ self.alternarPausa() })

        keyboard.r().onPressDo({
            if (partidaTerminada) {
                self.iniciar()
            }
        })

        keyboard.m().onPressDo({
            if (partidaTerminada or juegoPausado) {
                menuSeleccion.iniciar()
            }
        })

        keyboard.enter().onPressDo({
            if (cinematicaChiste.activo()) {
                cinematicaChiste.salirAlMenu()
            }
        })
    }

    method alternarPausa() {
        if (not partidaTerminada and not menuSeleccion.enMenu()) {
            if (juegoPausado) {
                self.reanudar()
            } else {
                self.pausar()
            }
        }
    }

    method pausar() {
        if (not juegoPausado and not partidaTerminada) {
            juegoPausado = true
            gestorAudio.pausarMusica()
            gestorLava.pausado(true)
            gestorGeiseres.pausado(true)
            interfazUI.jugadores().forEach({ jugador => jugador.detenerTodoMovimiento() })
            interfazUI.mostrarPausa()
        }
    }

    method reanudar() {
        if (juegoPausado) {
            juegoPausado = false
            gestorAudio.reanudarMusica()
            gestorLava.pausado(false)
            gestorGeiseres.pausado(false)
            interfazUI.ocultarPausa()
        }
    }

    method verificarFinDeJuego() {
        if (not partidaTerminada) {
            if (jugadoresActivos.size() > 1 and interfazUI.cantidadJugadoresVivos() == 1) {
                self.terminarConGanador(interfazUI.unicoJugadorVivo())
            } else if (interfazUI.cantidadJugadoresVivos() == 0) {
                self.terminarConGameOver()
            }
        }
    }

    method terminarConGanador(ganador) {
        partidaTerminada = true
        juegoPausado = false
        registroVictorias.registrarVictoria(ganador.numeroJugador())
        gestorAudio.detenerMusica()
        gestorBombas.detener()
        gestorLava.detener()
        gestorGeiseres.detener()
        ganador.detenerTodoMovimiento()
        if (registroVictorias.victoriasDe(ganador.numeroJugador()) >= 5) {
            cinematicaChiste.iniciar(ganador)
        } else {
            interfazUI.mostrarVictoria(ganador)
        }
    }

    method terminarConGameOver() {
        partidaTerminada = true
        juegoPausado = false
        gestorAudio.detenerMusica()
        gestorBombas.detener()
        gestorLava.detener()
        gestorGeiseres.detener()
        interfazUI.mostrarGameOver()
    }
}
