import wollok.game.*

// Registro persistente de victorias por número de jugador
object registroVictorias {
    var victoriasJugador1 = 0
    var victoriasJugador2 = 0
    var victoriasJugador3 = 0
    var victoriasJugador4 = 0

    method victoriasDe(numeroJugador) {
        if (numeroJugador == 1) return victoriasJugador1
        if (numeroJugador == 2) return victoriasJugador2
        if (numeroJugador == 3) return victoriasJugador3
        if (numeroJugador == 4) return victoriasJugador4
        return 0
    }

    method registrarVictoria(numeroJugador) {
        if (numeroJugador == 1) victoriasJugador1 = victoriasJugador1 + 1
        if (numeroJugador == 2) victoriasJugador2 = victoriasJugador2 + 1
        if (numeroJugador == 3) victoriasJugador3 = victoriasJugador3 + 1
        if (numeroJugador == 4) victoriasJugador4 = victoriasJugador4 + 1
    }

    method reiniciar() {
        victoriasJugador1 = 0
        victoriasJugador2 = 0
        victoriasJugador3 = 0
        victoriasJugador4 = 0
    }
}
