import wollok.game.*

object partida {
    const property jugadores =  []
    const property unaArena = arena
    const property gestorLava = unGestorLava

    method iniciar() {
        game.clear()
        game.width(15)
        game.height(13)
        game.cellSize(50)
        game.title("El Señor de las Bombas")
        game.boardGround("../assets/fondo_abismo.png") 

        unaArena.inicializar(game.width(), game.height())
        self.generarObstaculos()
        self.configurarJugadores()

    }

    method generarObstaculos() {
      // TODO: Ver como generar obstaculos de forma aleatoria
    }
    method configurarJugadores() {
      // TODO: Acá metemos la config de cada jugador
      // ej. teclas para moverse y tirar bombas, sprites asignados 
    }
    method verificarSupervivientes() {
        const vivos = jugadores.filter({jugador => jugador.estaVivo()})
        if (vivos.size() <= 1){
            self.terminarPartida(vivos.head())
        }
    }
    method terminarPartida(ganador) {
        game.removeTickEvent("colapsoPerimetro")
        gestorLava.detener()
        
        if (ganador != null) {
            game.say(ganador, "¡Victoria en la Tierra Media!")
        }
        
        game.schedule(3000, { game.stop() })
    }
}