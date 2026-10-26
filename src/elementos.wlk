import wollok.game.*
import src.jugador.*
import src.direcciones.*

class ElementoTablero {
    var property posicion
    
    method image()
    method permitePaso() = false
    
    method caerAlVacio() {
        game.removeVisual(self)
    }
    
    method sumergirEnLava() {
        game.removeVisual(self)
    }
    
    method serAlcanzadoPorFuego()

    method interactuarCon(jugador) {}
}

class BloqueIndestructible inherits ElementoTablero {
    override method image() = "pilar_metal.png" //TODO : Generar este sprite con alguna IA 
    
    override method serAlcanzadoPorFuego() {
        // Muro fijo: absorbe la onda expansiva sin romperse
    }
    
    override method sumergirEnLava() {
        // Resiste la lava
    }
}

class CajaDestructible inherits ElementoTablero {
    override method image() = "caja_madera.png" //TODO : Generar este sprite con alguna IA 
    
    override method serAlcanzadoPorFuego() {
        self.soltarPowerUp()
        game.removeVisual(self)
    }
    
    method soltarPowerUp() {
        // 30% de probabilidad de dropear un Power-Up al azar
        const azar = (1 .. 10).anyOne()
        if (azar == 1) game.addVisual(new PatinVelocidad(posicion = self.posicion()))
        if (azar == 2) game.addVisual(new BombaExtra(posicion = self.posicion()))
        if (azar == 3) game.addVisual(new FuegoExtra(posicion = self.posicion()))
    }
}


class PowerUp inherits ElementoTablero {
    override method permitePaso() = true
    
    
    method interactuarCon(unJugador) {
        self.aplicarEfecto(unJugador)
        game.removeVisual(self)
    }
    
    method aplicarEfecto(unJugador)
    
    override method serAlcanzadoPorFuego() {
        game.removeVisual(self)
    }
}

class PatinVelocidad inherits PowerUp {
    override method image() = "powerup_velocidad.png" //TODO : Generar este sprite con alguna IA 
    
    override method aplicarEfecto(unJugador) {
        // No se define que hacer todavia
    }
}

class BombaExtra inherits PowerUp {
    override method image() = "powerup_bomba.png" //TODO : Generar este sprite con alguna IA 
    
    override method aplicarEfecto(unJugador) {
        unJugador.bombasDisponibles(unJugador.bombasDisponibles() + 1)
    }
}

class FuegoExtra inherits PowerUp {
    override method image() = "powerup_fuego.png" //TODO : Generar este sprite con alguna IA 
    
    override method aplicarEfecto(unJugador) {
        unJugador.alcanceFuego(unJugador.alcanceFuego() + 1)
    }
}


class Explosion {
    var property posicion
    var property duracionMs = 600
    
    method image() = "fuego.png" //TODO : Generar este sprite con alguna IA 
    method permitePaso() = true
    method serAlcanzadoPorFuego() {}

    method propagar(alcance) {
        self.crearLlamaVisualEn(self.posicion())
        self.impactarEn(self.posicion())
        
        direcciones.todas().forEach({ direccion => 
            self.expandirHacia(self.posicion(), direccion, alcance) 
        })
    }

    method expandirHacia(posActual, direccion, pasosRestantes) {
        if (pasosRestantes > 0) {
            // El objeto direccion sabe como calcular su avance
            const siguientePos = direccion.siguiente(posActual)
            
            if (self.esPosicionValida(siguientePos)) {
                self.crearLlamaVisualEn(siguientePos)
                const chocoConSolido = self.impactarEn(siguientePos)
                
                if (not chocoConSolido) {
                    self.expandirHacia(siguientePos, direccion, pasosRestantes - 1)
                }
            }
        }
    }

    method impactarEn(pos) {
        const objetos = game.getObjectsIn(pos)
        objetos.forEach({ obj => obj.serAlcanzadoPorFuego() })
        return objetos.any({ obj => not obj.permitePaso() })
    }

    method crearLlamaVisualEn(pos) {
        const llama = new Explosion(posicion = pos)
        game.addVisual(llama)
        game.schedule(duracionMs, { game.removeVisual(llama) })
    }

    method esPosicionValida(pos) {
        return pos.x().between(0, game.width() - 1) and pos.y().between(0, game.height() - 1)
    }
}

class Bomba inherits ElementoTablero { 
    var property duenio
    var property alcance
    var property activa = true
    
    override method image() = "bomba.png" //TODO : Generar este sprite con alguna IA 
    
    method iniciarCuentaRegresiva() {
        game.schedule(2500, { self.detonar() })
    }
    
    method detonar() {
        if (activa) {
            activa = false
            game.removeVisual(self)
            duenio.recuperarBomba()
            
            const explosion = new Explosion(posicion = self.posicion())
            explosion.propagar(alcance)
        }
    }
    
    override method serAlcanzadoPorFuego() {
        self.detonar() // Reacción en cadena
    }
    
    override method caerAlVacio() {
        activa = false
        duenio.recuperarBomba()
        game.removeVisual(self)
    }
    
    override method sumergirEnLava() {
        self.detonar()
    }
}