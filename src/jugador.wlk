import src.partida.*
import wollok.game.*
import src.elementos.*

class Jugador {
    var property color
    var property bombasDisponibles = 1
    var property alcanceFuego = 1
    var property vidas = 1
    var property estaVivo = true
    var property posicion

    method image() = "jugador_" + color + ".png"

    method mover(nuevaPosicion) {
      if(estaVivo && self.puedeMoverseA(nuevaPosicion)){
        posicion = nuevaPosicion

        // TODO: Acá podriamos meter la mecanica de cuando agarra un
        // powerup al moverse a esta nueva posicion
      }
    }

    method puedeMoverseA(destino) {
      const dentroDeTablero = destino.x().between(0, game.width() - 1) && destino.y().between(0, game.height() - 1)
      return dentroDeTablero
    }

    method plantarBomba() {
        if (estaVivo and bombasDisponibles > 0) {
            bombasDisponibles -= 1
            const bomba = new Bomba(position = self.position(), duenio = self, alcance = self.alcanceFuego())
            game.addVisual(bomba)
            bomba.iniciarCuentaRegresiva()
        }
    }

    method recuperarBomba() {
      bombasDisponibles += 1
    }

    method morir() {
      estaVivo = false
      game.removeVisual(self)
      partida.verificarSupervivientes()
    }

    method serAlcanzadoPorFuego() {
        self.morir()
    }
    
    method caerAlVacio() {
        self.morir()
    }
    
    method sumergirEnLava() {
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
        teclaArriba.onPressDo { jugador.mover(jugador.position().up(1)) }
        teclaAbajo.onPressDo { jugador.mover(jugador.position().down(1)) }
        teclaIzquierda.onPressDo { jugador.mover(jugador.position().left(1)) }
        teclaDerecha.onPressDo { jugador.mover(jugador.position().right(1)) }
        teclaBomba.onPressDo { jugador.plantarBomba() }
    }
}