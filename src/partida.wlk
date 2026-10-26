import wollok.game.*
import superficie.*
import elementos.*
import jugador.*
import arena.*

object partida {
    const property jugadores =  []
    const property unaArena = arena
    const property unGestorLava = gestorLava

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

        unaArena.iniciarColapsoAnillo()
        unGestorLava.iniciarCicloMarea(8000)

    }

    method generarObstaculos() {
        (1 .. game.width() - 2).forEach { x =>
            (1 .. game.height() - 2).forEach { y =>
                // Pilares fijos indestructibles
                if (x.even() and y.even()) {
                    game.addVisual(new BloqueIndestructible(posicion = game.at(x, y)))
                } else if ((x + y) % 3 == 0) {
                    // Cajas destructibles de madera
                    game.addVisual(new CajaDestructible(posicion = game.at(x, y)))
                }
            }
        }
    }
    method configurarJugadores() {
      // TODO: Acá metemos la config de cada jugador
      // ej. teclas para moverse y tirar bombas, sprites asignados 
      jugadores.clear()
      self.crearJugador("frodo",self.spawnP1(),self.mapeoWASD())
      self.crearJugador("orco",self.spawnP2(),self.mapeoFlechas())
    }
    
    method crearJugador(unColor, unaPosicion, unMapeoTeclas) {
        const nuevoJugador = new Jugador(posicion = unaPosicion, color = unColor)
        nuevoJugador.asignarControles(unMapeoTeclas)
        jugadores.add(nuevoJugador)
        game.addVisual(nuevoJugador)
    }

    // Posiciones iniciales, fijarse si se puede mejorar mas adelante
    method spawnP1() = game.at(1, game.height() - 2)
    method spawnP2() = game.at(game.width() - 2, 1)

    method mapeoWASD() = new MapeoTeclas(
        jugador = null,
        teclaArriba = keyboard.w(),
        teclaAbajo = keyboard.s(),
        teclaIzquierda = keyboard.a(),
        teclaDerecha = keyboard.d(),
        teclaBomba = keyboard.space()
    )

    method mapeoFlechas() = new MapeoTeclas(
        jugador = null,
        teclaArriba = keyboard.up(),
        teclaAbajo = keyboard.down(),
        teclaIzquierda = keyboard.left(),
        teclaDerecha = keyboard.right(),
        teclaBomba = keyboard.enter()
    )

    method verificarSupervivientes() {
        const vivos = jugadores.filter({jugador => jugador.estaVivo()})
        if (vivos.size() <= 1){
            self.terminarPartida(vivos.head())
        }
    }
    method terminarPartida(ganador) {
        game.removeTickEvent("colapsoPerimetro")
        unGestorLava.detener()
        
        if (ganador != null) {
            game.say(ganador, "¡Victoria en la Tierra Media!")
        }
        
        game.schedule(3000, { game.stop() })
    }
}