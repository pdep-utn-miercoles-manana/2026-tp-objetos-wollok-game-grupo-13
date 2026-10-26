import src.partida.*
import wollok.game.*
import src.elementos.*
import src.direcciones.*

class Jugador inherits ElementoTablero {
    var property color
    var property bombasDisponibles = 1
    var property alcanceFuego = 1
    var property vidas = 1
    var property estaVivo = true

    override method image() = "jugador_" + color + ".png"

    method moverHacia(direccion) {
        self.mover(direccion.siguiente(self.posicion()))
    }

    method mover(nuevaPosicion) {
        if (estaVivo and self.puedeMoverseA(nuevaPosicion)) {
            posicion = nuevaPosicion
            
            // Polimorfismo con los elementos pisados (Power-Ups, etc.)
            game.getObjectsIn(nuevaPosicion).forEach({ unObjeto => 
                if (unObjeto != self) unObjeto.interactuarCon(self) 
            })
        }
    }

    method puedeMoverseA(destino) {
        const dentroDeTablero = destino.x().between(0, game.width() - 1) and destino.y().between(0, game.height() - 1)
        return dentroDeTablero and game.getObjectsIn(destino).all({ obj => obj.permitePaso() })
    }

    method plantarBomba() {
        if (estaVivo and bombasDisponibles > 0) {
            bombasDisponibles -= 1
            const bomba = new Bomba(posicion = self.posicion(), duenio = self, alcance = self.alcanceFuego())
            game.addVisual(bomba)
            bomba.iniciarCuentaRegresiva()
        }
    }

    method recuperarBomba() {
      bombasDisponibles += 1
    }

    method morir() {
        if (estaVivo) {
            estaVivo = false
            game.removeVisual(self)
            partida.verificarSupervivientes()
        }
    }

    override method serAlcanzadoPorFuego() {
        self.morir()
    }
    
    override method caerAlVacio() {
        self.morir()
    }
    
    override method sumergirEnLava() {
        self.morir()
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
        teclaArriba.onPressDo { jugador.moverHacia(arriba) }
        teclaAbajo.onPressDo { jugador.moverHacia(abajo) }
        teclaIzquierda.onPressDo { jugador.moverHacia(izquierda) }
        teclaDerecha.onPressDo { jugador.moverHacia(derecha) }
        teclaBomba.onPressDo { jugador.plantarBomba() }
    }
}