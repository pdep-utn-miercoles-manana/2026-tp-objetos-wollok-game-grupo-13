import wollok.game.*
import src.partida.*
import src.elementos.*
import src.direcciones.*
import src.arena.*

class Personaje {
    var property nombre
    var property velocidadBaseMs = 140
    var property alcanceFuegoBase = 2
    var property bombasIniciales = 1

    method nombre() = nombre
    method nombreIdentificador() = nombre.toLowerCase()
}

object catalogoPersonajes {
    const property frodo = new Personaje(nombre = "Frodo", velocidadBaseMs = 130, alcanceFuegoBase = 2, bombasIniciales = 1)
    const property gandalf = new Personaje(nombre = "Gandalf", velocidadBaseMs = 140, alcanceFuegoBase = 3, bombasIniciales = 1)
    const property aragorn = new Personaje(nombre = "Aragorn", velocidadBaseMs = 140, alcanceFuegoBase = 2, bombasIniciales = 2)
    const property legolas = new Personaje(nombre = "Legolas", velocidadBaseMs = 125, alcanceFuegoBase = 2, bombasIniciales = 1)
    const property sauron = new Personaje(nombre = "Sauron", velocidadBaseMs = 150, alcanceFuegoBase = 3, bombasIniciales = 2)

    const property personajesDisponibles = [frodo, gandalf, aragorn, legolas, sauron]

    method disponibles() = personajesDisponibles.map({ unPersonaje => unPersonaje.nombreIdentificador() })
    method siguienteIndice(indiceActual) = (indiceActual + 1) % personajesDisponibles.size()
    method anteriorIndice(indiceActual) = (indiceActual - 1 + personajesDisponibles.size()) % personajesDisponibles.size()
    method personajeEn(indice) = personajesDisponibles.get(indice)
    method nombreEn(indice) = self.personajeEn(indice).nombreIdentificador()
    method obtenerPorNombre(unNombre) = personajesDisponibles.findOrDefault({ unPersonaje => unPersonaje.nombreIdentificador() == unNombre.toLowerCase() }, frodo)
}

class Jugador {
    var posicion
    var personaje = catalogoPersonajes.frodo()
    var property numeroJugador = 1
    var vistaActual = "abajo"
    var paso = 1
    const totalPasos = 5
    var imagenActual = "jugador_frodo_abajo_1.png"
    var celdaCache = null
    var contadorSubpasos = 0
    var property estaVivo = true
    var property direccionActiva = null
    const direccionesPresionadas = []
    var tickMovimientoActivo = false
    var property velocidadMs = 140
    const tamanioSubpaso = 0.25
    
    var property alcanceFuego = 2
    var property maxBombas = 1
    var property bombasActuales = 0
    var tieneCeldaValidada = false
    var ultimaCeldaValidada = null

    override method initialize() {
        self.actualizarPosicionInterna(posicion.x(), posicion.y())
        self.actualizarImagen()
    }

    method personaje() = personaje
    method personaje(nuevoPersonaje) {
        personaje = nuevoPersonaje
        velocidadMs = nuevoPersonaje.velocidadBaseMs()
        alcanceFuego = nuevoPersonaje.alcanceFuegoBase()
        maxBombas = nuevoPersonaje.bombasIniciales()
        self.actualizarImagen()
    }

    // Compatibilidad con propiedad color
    method color() = personaje.nombreIdentificador()
    method color(unNombreColor) {
        self.personaje(catalogoPersonajes.obtenerPorNombre(unNombreColor))
    }

    method vistaActual() = vistaActual
    method vistaActual(nuevaVista) {
        if (vistaActual != nuevaVista) {
            vistaActual = nuevaVista
            self.actualizarImagen()
        }
    }

    method paso() = paso
    method paso(nuevoPaso) {
        if (paso != nuevoPaso) {
            paso = nuevoPaso
            self.actualizarImagen()
        }
    }

    method totalPasos() = totalPasos

    method actualizarImagen() {
        imagenActual = "jugador_" + self.color() + "_" + vistaActual + "_" + paso + ".png"
    }

    method actualizarPosicionInterna(nuevaCoordenadaX, nuevaCoordenadaY) {
        posicion = new PosicionFluida(x = nuevaCoordenadaX, y = nuevaCoordenadaY)
        celdaCache = game.at(nuevaCoordenadaX.round(), nuevaCoordenadaY.round())
    }

    method posicion() = posicion
    method posicion(nuevaPosicion) {
        self.actualizarPosicionInterna(nuevaPosicion.x(), nuevaPosicion.y())
    }
    method position() = posicion
    method celdaActual() = celdaCache
    method velocidadSubpasoMs() = 15.max((velocidadMs / 4).round())

    method image() = imagenActual
    method permitePaso() = false
    method interactuarCon(unJugador) {}
    method identificadorTickMovimiento() = "MOVIMIENTO_" + numeroJugador + "_" + self.color()
    method idTickMovimiento() = self.identificadorTickMovimiento()
    
    method serAlcanzadoPorFuego() {
        if (estaVivo) {
            estaVivo = false
            self.detenerTodoMovimiento()
            if (game.hasVisual(self)) {
                game.removeVisual(self)
            }
            partida.verificarFinDeJuego()
        }
    }

    method colapsarEnAbismo() {
        self.serAlcanzadoPorFuego()
    }

    method iniciarMovimiento(direccion) {
        if (estaVivo and not partida.juegoPausado() and not partida.partidaTerminada()) {
            if (not direccionesPresionadas.contains(direccion)) {
                direccionesPresionadas.add(direccion)
            }
            if (direccionActiva != direccion) {
                direccionActiva = direccion
                tieneCeldaValidada = false
                self.moverHacia(direccion)
                self.asegurarTickMovimiento()
            }
        }
    }

    method asegurarTickMovimiento() {
        if (not tickMovimientoActivo) {
            tickMovimientoActivo = true
            game.onTick(self.velocidadSubpasoMs(), self.identificadorTickMovimiento(), {
                if (estaVivo and not partida.juegoPausado() and not partida.partidaTerminada() and direccionActiva != null) {
                    self.moverHacia(direccionActiva)
                }
            })
        }
    }

    method detenerMovimiento(direccion) {
        direccionesPresionadas.remove(direccion)
        if (direccionActiva == direccion) {
            if (not direccionesPresionadas.isEmpty()) {
                direccionActiva = direccionesPresionadas.last()
                tieneCeldaValidada = false
            } else {
                self.detenerTodoMovimiento()
            }
        }
    }

    method detenerTodoMovimiento() {
        direccionesPresionadas.clear()
        direccionActiva = null
        tieneCeldaValidada = false
        ultimaCeldaValidada = null
        contadorSubpasos = 0
        self.paso(1)
        if (tickMovimientoActivo) {
            tickMovimientoActivo = false
            game.removeTickEvent(self.identificadorTickMovimiento())
        }
    }

    method moverHacia(direccion) {
        if (estaVivo and not partida.juegoPausado() and not partida.partidaTerminada()) {
            const nuevaVista = direccion.nombreVista()
            const cambioVista = vistaActual != nuevaVista
            vistaActual = nuevaVista
            const cambioPaso = self.alternarPasoSuave()
            if (cambioVista or cambioPaso) {
                self.actualizarImagen()
            }

            const coordenadaXActual = posicion.x()
            const coordenadaYActual = posicion.y()
            const celdaPrevia = self.celdaActual()

            if (direccion.desplazamientoHorizontal() != 0) {
                const filaCarril = coordenadaYActual.round()
                const nuevaCoordenadaX = self.redondearCuarto(coordenadaXActual + direccion.desplazamientoHorizontal() * tamanioSubpaso)
                const columnaAdelante = if (direccion.desplazamientoHorizontal() > 0) nuevaCoordenadaX.ceil() else nuevaCoordenadaX.floor()
                const celdaDestino = game.at(columnaAdelante, filaCarril)

                if (self.puedeAvanzarACelda(celdaPrevia, celdaDestino)) {
                    const nuevaCoordenadaY = self.acercarAlCarril(coordenadaYActual, filaCarril)
                    self.actualizarPosicionInterna(nuevaCoordenadaX, nuevaCoordenadaY)
                    self.verificarCambioDeCelda(celdaPrevia)
                } else if (coordenadaYActual != filaCarril) {
                    const filaAlternativa = if (coordenadaYActual <= filaCarril) coordenadaYActual.floor() else coordenadaYActual.ceil()
                    if (filaAlternativa != filaCarril and self.esPosicionTransitable(game.at(columnaAdelante, filaAlternativa))) {
                        const nuevaCoordenadaY = self.acercarAlCarril(coordenadaYActual, filaAlternativa)
                        self.actualizarPosicionInterna(coordenadaXActual, nuevaCoordenadaY)
                        self.verificarCambioDeCelda(celdaPrevia)
                    }
                }
            } else if (direccion.desplazamientoVertical() != 0) {
                const columnaCarril = coordenadaXActual.round()
                const nuevaCoordenadaY = self.redondearCuarto(coordenadaYActual + direccion.desplazamientoVertical() * tamanioSubpaso)
                const filaAdelante = if (direccion.desplazamientoVertical() > 0) nuevaCoordenadaY.ceil() else nuevaCoordenadaY.floor()
                const celdaDestino = game.at(columnaCarril, filaAdelante)

                if (self.puedeAvanzarACelda(celdaPrevia, celdaDestino)) {
                    const nuevaCoordenadaX = self.acercarAlCarril(coordenadaXActual, columnaCarril)
                    self.actualizarPosicionInterna(nuevaCoordenadaX, nuevaCoordenadaY)
                    self.verificarCambioDeCelda(celdaPrevia)
                } else if (coordenadaXActual != columnaCarril) {
                    const columnaAlternativa = if (coordenadaXActual <= columnaCarril) coordenadaXActual.floor() else coordenadaXActual.ceil()
                    if (columnaAlternativa != columnaCarril and self.esPosicionTransitable(game.at(columnaAlternativa, filaAdelante))) {
                        const nuevaCoordenadaX = self.acercarAlCarril(coordenadaXActual, columnaAlternativa)
                        self.actualizarPosicionInterna(nuevaCoordenadaX, coordenadaYActual)
                        self.verificarCambioDeCelda(celdaPrevia)
                    }
                }
            }
        }
    }

    method puedeAvanzarACelda(celdaPrevia, celdaDestino) {
        if (celdaDestino == celdaPrevia or (tieneCeldaValidada and celdaDestino == ultimaCeldaValidada)) {
            return true
        }
        if (self.esPosicionTransitable(celdaDestino)) {
            tieneCeldaValidada = true
            ultimaCeldaValidada = celdaDestino
            return true
        }
        return false
    }

    method verificarCambioDeCelda(celdaPrevia) {
        const nuevaCelda = self.celdaActual()
        if (nuevaCelda != celdaPrevia) {
            self.verificarInteractuarConSuelo(nuevaCelda)
        }
    }

    method redondearCuarto(valor) = (valor * 4).round() / 4

    method acercarAlCarril(valorActual, valorObjetivo) {
        if ((valorActual - valorObjetivo).abs() <= tamanioSubpaso) {
            return valorObjetivo
        }
        if (valorActual < valorObjetivo) {
            return self.redondearCuarto(valorActual + tamanioSubpaso)
        }
        return self.redondearCuarto(valorActual - tamanioSubpaso)
    }

    method alternarPasoSuave() {
        contadorSubpasos = contadorSubpasos + 1
        if (contadorSubpasos % 2 == 1) {
            paso = (paso % totalPasos) + 1
            return true
        }
        return false
    }

    method esPosicionTransitable(unaPosicion) {
        return arena.esPosicionDentroDeArena(unaPosicion) and
               not arena.esBordeExteriorVolcanico(unaPosicion) and
               not arena.esPosicionEnLava(unaPosicion) and
               not arena.esMuroIndestructibleFijo(unaPosicion) and
               game.getObjectsIn(unaPosicion).all({ elemento => elemento.permitePaso() })
    }

    method verificarInteractuarConSuelo(unaPosicion) {
        game.getObjectsIn(unaPosicion).forEach({ elemento =>
            if (elemento != self) elemento.interactuarCon(self)
        })
    }

    method plantarBomba() {
        const celdaBomba = self.celdaActual()
        if (estaVivo and not partida.juegoPausado() and not partida.partidaTerminada() and bombasActuales < maxBombas and not game.getObjectsIn(celdaBomba).any({ elemento => elemento != self and not elemento.permitePaso() })) {
            bombasActuales = bombasActuales + 1
            tieneCeldaValidada = false
            ultimaCeldaValidada = null
            const bomba = new Bomba(posicion = celdaBomba, duenio = self, alcance = alcanceFuego)
            bomba.plantar()
        }
    }

    method reintegrarBomba() {
        bombasActuales = 0.max(bombasActuales - 1)
    }

    method bombasDisponibles() = 0.max(maxBombas - bombasActuales)
    method nivelVelocidad() = 1 + ((140 - velocidadMs) / 25).round()

    method aumentarAlcance() { alcanceFuego = alcanceFuego + 1 }
    method aumentarMaxBombas() { maxBombas = maxBombas + 1 }
    method aumentarVelocidad() {
        velocidadMs = 70.max(velocidadMs - 25)
        if (tickMovimientoActivo) {
            game.removeTickEvent(self.identificadorTickMovimiento())
            tickMovimientoActivo = false
            self.asegurarTickMovimiento()
        }
    }
}

class MapeoTeclas {
    var property jugador
    var property teclaArriba
    var property teclaAbajo
    var property teclaIzquierda
    var property teclaDerecha
    var property teclaBomba
    
    method configurar() {
        self.configurarDireccion(teclaArriba, arriba)
        self.configurarDireccion(teclaAbajo, abajo)
        self.configurarDireccion(teclaIzquierda, izquierda)
        self.configurarDireccion(teclaDerecha, derecha)
        teclaBomba.onPressDo({ jugador.plantarBomba() })
    }

    method configurarDireccion(tecla, direccion) {
        tecla.onPressDo({ jugador.iniciarMovimiento(direccion) })
        tecla.onReleaseDo({ jugador.detenerMovimiento(direccion) })
    }
}
