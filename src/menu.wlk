import wollok.game.*
import arena.*
import jugador.*
import partida.*
import src.audio.*
import src.victorias.*
import src.direcciones.*

class SlotSelectorJugador {
    const property numero
    const property columnaUI
    var property activo = true
    var property indicePersonaje = 0
    const property posicionSpawn
    const property descripcionControles
    const property teclaArriba
    const property teclaAbajo
    const property teclaIzquierda
    const property teclaDerecha
    const property teclaBomba

    method personajeActual() = catalogoPersonajes.personajeEn(indicePersonaje)
    method personajeElegido() = catalogoPersonajes.nombreEn(indicePersonaje)

    method siguientePersonaje() {
        activo = true
        indicePersonaje = catalogoPersonajes.siguienteIndice(indicePersonaje)
    }

    method anteriorPersonaje() {
        activo = true
        indicePersonaje = catalogoPersonajes.anteriorIndice(indicePersonaje)
    }

    method crearJugador() {
        const nuevoJugador = new Jugador(
            posicion = posicionSpawn,
            numeroJugador = numero
        )
        nuevoJugador.personaje(self.personajeActual())
        return nuevoJugador
    }

    method configurarControlesPara(unJugador) {
        const mapeo = new MapeoTeclas(
            jugador = unJugador,
            teclaArriba = teclaArriba,
            teclaAbajo = teclaAbajo,
            teclaIzquierda = teclaIzquierda,
            teclaDerecha = teclaDerecha,
            teclaBomba = teclaBomba
        )
        mapeo.configurar()
    }
}

object fondoSelectorUI {
    method position() = game.at(0, 0)
    method image() = "fondo_selector.png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

object logoTituloUI {
    method position() = game.at(1.5, 11)
    method image() = "titulo_banner.png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

object tituloSelectorUI {
    method position() = new PosicionFluida(x = 7, y = 10.45)
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method text() {
        return "● MODO TODOS CONTRA TODOS (" + menuSeleccion.cantidadActivos() + " de 4 activos) ●"
    }
    method textColor() = "FFD700"
}

object instruccionesSelectorUI {
    method position() = game.at(7, 1.0)
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method text() {
        return "[1-4 / ESPACIO] Unirse/Salir   |   [Flechas] Cambiar personaje\n"
            + "▶   PRESIONA [ENTER] PARA COMENZAR LA BATALLA   ◀"
    }
    method textColor() = "66E0FF"
}

class TarjetaSlotUI {
    const property slot
    method position() = game.at(slot.columnaUI(), 3)
    method image() = if (slot.activo()) "tarjeta_slot_activa.png" else "tarjeta_slot_inactiva.png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

object cursorSelectorUI {
    method position() = game.at(menuSeleccion.slotSeleccionado().columnaUI(), 3)
    method image() = "cursor_tarjeta.png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

class CabeceraSlotUI {
    const property slot
    method position() = game.at(slot.columnaUI() + 1, 8.8)
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method victorias() = registroVictorias.victoriasDe(slot.numero())

    method text() {
        const estado = if (slot.activo()) "● ACTIVO" else "○ ESPERANDO"
        return "JUGADOR " + slot.numero() + " (★" + self.victorias() + ")\n" + estado
    }

    method textColor() = if (slot.activo()) "7CFC00" else "888888"
}

class SpritePersonajeSlotUI {
    const property slot
    method position() = game.at(slot.columnaUI() + 1, 6)
    method image() = "jugador_" + slot.personajeElegido() + "_abajo_1.png"
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}
}

class DetalleSlotUI {
    const property slot
    method position() = game.at(slot.columnaUI() + 1, 3.7)
    method permitePaso() = false
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {}

    method text() {
        if (not slot.activo()) {
            return "Sin participar\n[ESPACIO / " + slot.numero() + "]"
        }
        return "< " + slot.personajeElegido().toUpperCase() + " >\n" + slot.descripcionControles()
    }

    method textColor() = if (slot.activo()) "FFFFFF" else "777777"
}

object menuSeleccion {
    const property slots = []
    var property indiceCursor = 0
    var property enMenu = false

    method reiniciarSlotsPorDefecto() {
        slots.clear()
        slots.add(new SlotSelectorJugador(
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
        ))
        slots.add(new SlotSelectorJugador(
            numero = 2,
            columnaUI = 4,
            activo = true,
            indicePersonaje = 1,
            posicionSpawn = game.at(arena.ancho() - 2, arena.alto() - 2),
            descripcionControles = "WASD + Tecla E",
            teclaArriba = keyboard.w(),
            teclaAbajo = keyboard.s(),
            teclaIzquierda = keyboard.a(),
            teclaDerecha = keyboard.d(),
            teclaBomba = keyboard.e()
        ))
        slots.add(new SlotSelectorJugador(
            numero = 3,
            columnaUI = 8,
            activo = false,
            indicePersonaje = 2,
            posicionSpawn = game.at(1, arena.alto() - 2),
            descripcionControles = "IJKL + Tecla U",
            teclaArriba = keyboard.i(),
            teclaAbajo = keyboard.k(),
            teclaIzquierda = keyboard.j(),
            teclaDerecha = keyboard.l(),
            teclaBomba = keyboard.u()
        ))
        slots.add(new SlotSelectorJugador(
            numero = 4,
            columnaUI = 12,
            activo = false,
            indicePersonaje = 3,
            posicionSpawn = game.at(arena.ancho() - 2, 1),
            descripcionControles = "PadNum + Tecla 0",
            teclaArriba = keyboard.num8(),
            teclaAbajo = keyboard.num5(),
            teclaIzquierda = keyboard.num4(),
            teclaDerecha = keyboard.num6(),
            teclaBomba = keyboard.num0()
        ))
    }

    method inicializarSlotsPorDefecto() {
        if (slots.isEmpty()) {
            self.reiniciarSlotsPorDefecto()
        }
    }

    method reiniciarValoresJugadores() {
        registroVictorias.reiniciar()
        self.reiniciarSlotsPorDefecto()
        partida.reiniciar()
    }

    method iniciar() {
        gestorAudio.detenerMusica()
        gestorLava.detener()
        gestorGeiseres.detener()
        game.clear()
        enMenu = true
        indiceCursor = 0
        self.reiniciarValoresJugadores()
        if (not game.running()) {
            game.title("El Señor de las Bombas")
            game.width(arena.ancho())
            game.height(arena.alto() + 1)
            game.cellSize(48)
            game.ground("baldosa_suelo.png")
            game.boardGround("fondo_tablero.png")
        }

        game.addVisual(fondoSelectorUI)
        game.addVisual(logoTituloUI)
        game.addVisual(tituloSelectorUI)
        game.addVisual(instruccionesSelectorUI)

        slots.forEach({ slot =>
            game.addVisual(new TarjetaSlotUI(slot = slot))
            game.addVisual(new CabeceraSlotUI(slot = slot))
            game.addVisual(new SpritePersonajeSlotUI(slot = slot))
            game.addVisual(new DetalleSlotUI(slot = slot))
        })

        game.addVisual(cursorSelectorUI)
        self.configurarControlesMenu()
    }

    method configurarControlesMenu() {
        keyboard.left().onPressDo({ if (enMenu) self.moverCursorIzquierda() })
        keyboard.right().onPressDo({ if (enMenu) self.moverCursorDerecha() })
        keyboard.up().onPressDo({ if (enMenu) self.cambiarPersonajeSiguiente() })
        keyboard.down().onPressDo({ if (enMenu) self.cambiarPersonajeAnterior() })
        keyboard.space().onPressDo({ if (enMenu) self.alternarSlotActual() })

        keyboard.num1().onPressDo({ if (enMenu) self.alternarSlot(0) })
        keyboard.num2().onPressDo({ if (enMenu) self.alternarSlot(1) })
        keyboard.num3().onPressDo({ if (enMenu) self.alternarSlot(2) })
        keyboard.num4().onPressDo({ if (enMenu) self.alternarSlot(3) })

        keyboard.enter().onPressDo({ if (enMenu) self.confirmarSeleccionEIniciar() })
    }

    method slotSeleccionado() = slots.get(indiceCursor)

    method moverCursorIzquierda() {
        indiceCursor = (indiceCursor - 1 + slots.size()) % slots.size()
    }

    method moverCursorDerecha() {
        indiceCursor = (indiceCursor + 1) % slots.size()
    }

    method cambiarPersonajeSiguiente() {
        self.slotSeleccionado().siguientePersonaje()
    }

    method cambiarPersonajeAnterior() {
        self.slotSeleccionado().anteriorPersonaje()
    }

    method alternarSlotActual() {
        self.alternarSlot(indiceCursor)
    }

    method alternarSlot(indice) {
        indiceCursor = indice
        const slot = slots.get(indice)
        if (slot.activo()) {
            if (self.cantidadActivos() > 1) {
                slot.activo(false)
            }
        } else {
            slot.activo(true)
        }
    }

    method slotsActivos() = slots.filter({ slot => slot.activo() })
    method cantidadActivos() = self.slotsActivos().size()

    method confirmarSeleccionEIniciar() {
        if (self.cantidadActivos() >= 1) {
            enMenu = false
            partida.iniciarConSlots(self.slotsActivos())
        }
    }
}
