import wollok.game.*
import arena.*
import src.partida.*
import src.elementos.*
import src.audio.*

class Superficie {
    var property position
    method permitePaso() = true
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {
        game.removeVisual(self)
    }
    method image()
    method interactuarCon(unJugador) {}
}

class BaldosaNormal inherits Superficie {
    override method image() = "baldosa_suelo.png"
}

class BaldosaAbismo inherits Superficie {
    override method image() = capaAnilloLava.image()
    override method permitePaso() = false
    override method interactuarCon(unJugador) {
        unJugador.serAlcanzadoPorFuego()
    }
}

object capaAnilloLava inherits BaldosaAbismo(position = game.at(0, 0)) {
    var property visible = false
    var imagenActual = "lava_anillo_1_1.png"

    override method image() = imagenActual
    override method colapsarEnAbismo() {}

    method actualizarImagen() {
        const nivel = 1.max(gestorLava.nivelColapso())
        imagenActual = "lava_anillo_" + nivel + "_" + gestorGeiseres.frameActual() + ".png"
    }

    method mostrar() {
        self.actualizarImagen()
        if (not visible) {
            visible = true
            game.addVisual(self)
        }
    }

    method ocultar() {
        visible = false
        imagenActual = "lava_anillo_1_1.png"
    }
}

object estadoGeiserBajo {
    method prefijoImagen() = "geiser_bajo"
    method imagen() = self.prefijoImagen() + "_" + gestorGeiseres.frameActual() + ".png"
    method permitePaso() = true
    method estaAlto() = false
    method siguienteEstado() = estadoGeiserAdvertencia
    method interactuarCon(unJugador) {}
    method alActivarseEn(unaPosicion) {}
}

object estadoGeiserAdvertencia {
    method prefijoImagen() = "geiser_advertencia"
    method imagen() = self.prefijoImagen() + "_" + gestorGeiseres.frameActual() + ".png"
    method permitePaso() = true
    method estaAlto() = false
    method siguienteEstado() = estadoGeiserAlto
    method interactuarCon(unJugador) {}
    method alActivarseEn(unaPosicion) {}
}

object estadoGeiserAlto {
    method prefijoImagen() = "geiser_alto"
    method imagen() = self.prefijoImagen() + "_" + gestorGeiseres.frameActual() + ".png"
    method permitePaso() = false
    method estaAlto() = true
    method siguienteEstado() = estadoGeiserBajo
    method interactuarCon(unJugador) {
        unJugador.serAlcanzadoPorFuego()
    }
    method alActivarseEn(unaPosicion) {
        gestorAudio.reproducirErupcionGeiser()
        partida.jugadoresActivos().forEach({ jugador =>
            if (jugador.estaVivo() and jugador.celdaActual() == unaPosicion) {
                jugador.serAlcanzadoPorFuego()
            }
        })
        gestorBombas.detonarBombasEn(unaPosicion)
    }
}

class GeiserMagma inherits Superficie {
    var property estado = estadoGeiserBajo
    var imagenActual = "geiser_bajo_1.png"

    override method image() = imagenActual
    override method permitePaso() = estado.permitePaso()
    method estaAlto() = estado.estaAlto()

    method actualizarImagen() {
        imagenActual = estado.imagen()
    }

    override method interactuarCon(unJugador) {
        estado.interactuarCon(unJugador)
    }

    method cambiarEstado(nuevoEstado) {
        estado = nuevoEstado
        self.actualizarImagen()
        estado.alActivarseEn(self.position())
    }

    override method colapsarEnAbismo() {
        gestorGeiseres.removerGeiser(self)
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
    }
}
