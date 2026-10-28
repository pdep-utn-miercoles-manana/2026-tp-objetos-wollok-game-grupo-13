import wollok.game.*
import superficie.*
import elementos.*

object arena {
    const ancho = 15
    const alto = 13
    const property bloquesIndestructibles = []

    method ancho() = ancho
    method alto() = alto

    method celdas() {
        const todasLasCeldas = []
        (0 .. ancho - 1).forEach({ coordenadaX =>
            (0 .. alto - 1).forEach({ coordenadaY =>
                todasLasCeldas.add(game.at(coordenadaX, coordenadaY))
            })
        })
        return todasLasCeldas
    }

    method inicializarSuperficies() {
        // El suelo base ("baldosa_suelo.png") se dibuja nativamente mediante game.ground(),
        // evitando agregar 195 objetos visuales redundantes que sobrecargan el bucle de renderizado.
    }

    method inicializarObstaculos() {
        bloquesIndestructibles.clear()
        (1 .. ancho - 2).forEach({ coordenadaX =>
            (1 .. alto - 2).forEach({ coordenadaY =>
                const celda = game.at(coordenadaX, coordenadaY)
                if (coordenadaX.even() and coordenadaY.even()) {
                    const bloque = new BloqueIndestructible(position = celda)
                    bloquesIndestructibles.add(bloque)
                    game.addVisual(bloque)
                } else if (not self.esZonaSeguraSpawn(coordenadaX, coordenadaY) and not gestorGeiseres.esPosicionDeGeiser(celda)) {
                    // Distribución dinámica / procedural de cajas destructibles (~45% de densidad al azar)
                    const probabilidadCaja = 1.randomUpTo(100).round()
                    if (probabilidadCaja <= 45) {
                        game.addVisual(new CajaDestructible(position = celda))
                    }
                }
            })
        })
    }

    method esZonaSeguraSpawn(coordenadaX, coordenadaY) {
        return self.esZonaSeguraEsquina(coordenadaX, coordenadaY, 1, 1, 1, 1) or
               self.esZonaSeguraEsquina(coordenadaX, coordenadaY, ancho - 2, alto - 2, -1, -1) or
               self.esZonaSeguraEsquina(coordenadaX, coordenadaY, 1, alto - 2, 1, -1) or
               self.esZonaSeguraEsquina(coordenadaX, coordenadaY, ancho - 2, 1, -1, 1)
    }

    // Garantiza 5 celdas libres en forma de 'L' en cada esquina:
    // La casilla de spawn (dx=0, dy=0), los dos casilleros adyacentes inmediatos (dx=1, dy=0) y (dx=0, dy=1),
    // y los dos pasillos de escape extendidos (dx=2, dy=0) y (dx=0, dy=2).
    // Esto asegura que al plantar una bomba para romper cualquier caja frontal, el jugador
    // siempre tiene espacio libre y cobertura detrás del pilar indestructible para refugiarse sin morir.
    method esZonaSeguraEsquina(coordenadaX, coordenadaY, esquinaCoordenadaX, esquinaCoordenadaY, direccionHorizontal, direccionVertical) {
        const esMismoSpawn = (coordenadaX == esquinaCoordenadaX and coordenadaY == esquinaCoordenadaY)
        const esAdyacenteHorizontal = (coordenadaX == esquinaCoordenadaX + direccionHorizontal and coordenadaY == esquinaCoordenadaY)
        const esAdyacenteVertical = (coordenadaX == esquinaCoordenadaX and coordenadaY == esquinaCoordenadaY + direccionVertical)
        const esEscapeHorizontal = (coordenadaX == esquinaCoordenadaX + 2 * direccionHorizontal and coordenadaY == esquinaCoordenadaY)
        const esEscapeVertical = (coordenadaX == esquinaCoordenadaX and coordenadaY == esquinaCoordenadaY + 2 * direccionVertical)
        return esMismoSpawn or esAdyacenteHorizontal or esAdyacenteVertical or esEscapeHorizontal or esEscapeVertical
    }

    method esPosicionDentroDeArena(unaPosicion) {
        return unaPosicion.x().between(0, ancho - 1) and unaPosicion.y().between(0, alto - 1)
    }

    method esBordeExteriorVolcanico(unaPosicion) {
        const coordenadaXRedondeada = unaPosicion.x().round()
        const coordenadaYRedondeada = unaPosicion.y().round()
        return coordenadaXRedondeada <= 0 or coordenadaXRedondeada >= ancho - 1 or
               coordenadaYRedondeada <= 0 or coordenadaYRedondeada >= alto - 1
    }

    method esMuroIndestructibleFijo(unaPosicion) {
        return unaPosicion.x().between(1, ancho - 2) and unaPosicion.y().between(1, alto - 2) and unaPosicion.x().even() and unaPosicion.y().even()
    }

    method esPosicionEnLava(unaPosicion) {
        const nivel = gestorLava.nivelColapso()
        const coordenadaXRedondeada = unaPosicion.x().round()
        const coordenadaYRedondeada = unaPosicion.y().round()
        return nivel > 0 and self.esPosicionDentroDeArena(unaPosicion) and (
            coordenadaXRedondeada <= nivel or coordenadaXRedondeada >= ancho - 1 - nivel or
            coordenadaYRedondeada <= nivel or coordenadaYRedondeada >= alto - 1 - nivel
        )
    }

    method casillasEnAnillo(nivel) {
        const minimaCoordenadaX = nivel - 1
        const maximaCoordenadaX = ancho - nivel
        const minimaCoordenadaY = nivel - 1
        const maximaCoordenadaY = alto - nivel
        
        const posiciones = []
        
        (minimaCoordenadaX .. maximaCoordenadaX).forEach({ coordenadaX =>
            posiciones.add(game.at(coordenadaX, minimaCoordenadaY))
            posiciones.add(game.at(coordenadaX, maximaCoordenadaY))
        })
        (minimaCoordenadaY + 1 .. maximaCoordenadaY - 1).forEach({ coordenadaY =>
            posiciones.add(game.at(minimaCoordenadaX, coordenadaY))
            posiciones.add(game.at(maximaCoordenadaX, coordenadaY))
        })
        
        return posiciones
    }

    method colapsarAnilloActual() {
        capaAnilloLava.mostrar()
        game.allVisuals().forEach({ unObjetoVisual =>
            if (self.esPosicionEnLava(unObjetoVisual.position())) {
                unObjetoVisual.colapsarEnAbismo()
            }
        })
    }

    method convertirEnAbismo(unaPosicion) {
        capaAnilloLava.mostrar()
        game.getObjectsIn(unaPosicion).forEach({ unObjeto =>
            unObjeto.colapsarEnAbismo()
        })
    }
}

object gestorGeiseres {
    const property geiseres = []
    var property estadoActual = estadoGeiserBajo
    var property frameActual = 1
    const totalFrames = 5
    var ticksEnEstadoActual = 0
    const ticksPorEstado = 14
    var property pausado = false
    var cicloActivo = false

    method posicionesIniciales() = [
        game.at(7, 6),
        game.at(7, 9),
        game.at(7, 3),
        game.at(3, 6),
        game.at(11, 6)
    ]

    method esPosicionDeGeiser(unaPosicion) = self.posicionesIniciales().contains(unaPosicion)

    method iniciar() {
        self.detener()
        geiseres.clear()
        estadoActual = estadoGeiserBajo
        frameActual = 1
        ticksEnEstadoActual = 0
        pausado = false
        self.posicionesIniciales().forEach({ posicionGeiser =>
            const geiser = new GeiserMagma(position = posicionGeiser, estado = estadoActual)
            geiser.actualizarImagen()
            geiseres.add(geiser)
            game.addVisual(geiser)
        })
        cicloActivo = true
        game.onTick(180, "CICLO_GEISERES", { self.avanzarTickAnimacion() })
    }

    method detener() {
        pausado = false
        if (cicloActivo) {
            cicloActivo = false
            game.removeTickEvent("CICLO_GEISERES")
        }
    }

    method avanzarTickAnimacion() {
        if (not pausado) {
            frameActual = (frameActual % totalFrames) + 1
            geiseres.forEach({ geiser => geiser.actualizarImagen() })
            arena.bloquesIndestructibles().forEach({ bloque => bloque.actualizarFrame(frameActual) })
            if (capaAnilloLava.visible()) {
                capaAnilloLava.actualizarImagen()
            }
            if (not geiseres.isEmpty()) {
                ticksEnEstadoActual = ticksEnEstadoActual + 1
                if (ticksEnEstadoActual >= ticksPorEstado) {
                    self.avanzarCiclo()
                }
            }
        }
    }

    method avanzarCiclo() {
        if (not pausado and not geiseres.isEmpty()) {
            frameActual = 1
            ticksEnEstadoActual = 0
            estadoActual = estadoActual.siguienteEstado()
            geiseres.forEach({ geiser => geiser.cambiarEstado(estadoActual) })
            if (capaAnilloLava.visible()) {
                capaAnilloLava.actualizarImagen()
            }
        }
    }

    method subirTodos() {
        frameActual = 1
        ticksEnEstadoActual = 0
        estadoActual = estadoGeiserAlto
        geiseres.forEach({ geiser => geiser.cambiarEstado(estadoGeiserAlto) })
    }

    method bajarTodos() {
        frameActual = 1
        ticksEnEstadoActual = 0
        estadoActual = estadoGeiserBajo
        geiseres.forEach({ geiser => geiser.cambiarEstado(estadoGeiserBajo) })
    }

    method removerGeiser(unGeiser) {
        geiseres.remove(unGeiser)
    }
}

object gestorLava {
    var property nivelColapso = 0
    const maxNiveles = 3
    const intervaloSegundos = 20
    var property segundosParaColapso = intervaloSegundos
    var colapsoEnCurso = false
    var relojActivo = false
    var property pausado = false

    method maxNiveles() = maxNiveles
    method colapsoEnCurso() = colapsoEnCurso

    method iniciar() {
        self.detener()
        nivelColapso = 0
        segundosParaColapso = intervaloSegundos
        pausado = false
        capaAnilloLava.ocultar()
        relojActivo = true
        game.onTick(1000, "RELOJ_LAVA", { self.avanzarSegundo() })
    }

    method detener() {
        pausado = false
        colapsoEnCurso = false
        if (relojActivo) {
            relojActivo = false
            game.removeTickEvent("RELOJ_LAVA")
        }
    }

    method avanzarSegundo() {
        if (relojActivo and not pausado and nivelColapso < maxNiveles) {
            segundosParaColapso = 0.max(segundosParaColapso - 1)
            if (segundosParaColapso == 0) {
                self.colapsarSiguienteAnillo()
            }
        }
    }

    method colapsarSiguienteAnillo() {
        if (nivelColapso < maxNiveles) {
            nivelColapso = nivelColapso + 1
            segundosParaColapso = intervaloSegundos
            arena.colapsarAnilloActual()
            if (nivelColapso >= maxNiveles and relojActivo) {
                segundosParaColapso = 0
                relojActivo = false
                game.removeTickEvent("RELOJ_LAVA")
            }
        }
    }

    method procesarPasoColapso() {}

    method textoRelojLava() {
        if (colapsoEnCurso) {
            return "¡MAGMA AVANZANDO!\nCerrando anillo " + nivelColapso
        }
        if (nivelColapso >= maxNiveles) {
            return "LAVA AL MAXIMO\nZona final activa"
        }
        return "PROX. ANILLO DE LAVA\nEn " + segundosParaColapso + " seg"
    }

    method colorRelojLava() {
        if (colapsoEnCurso or (nivelColapso < maxNiveles and segundosParaColapso <= 5)) {
            return "FF4444"
        }
        if (nivelColapso >= maxNiveles) {
            return "FF9933"
        }
        return "FFD700"
    }
}
