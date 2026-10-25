import wollok.game.*
import jugador.*

class Explosion {
    var property posicion
    var property duracionMs = 600
    
    method image() = "fuego.png" //TODO : Generar este sprite con alguna IA 
    method propagar() {
      //TODO: La idea es que se propague linealmente hasta a una dist
      // variable(dependiendo de powerUps) o  hasta que choque contra un objeto fijo
      // o la pared final 
    }
}

class Bomba {
    var property posicion 
    var property duenio
    var property alcance
    var property activa = true
    
    method image() = "bomba.png" //TODO : Generar este sprite con alguna IA 
    
    method iniciarCuentaRegresiva() {
        game.schedule(2500, { self.detonar() })
    }
    
    method detonar() {
        if (activa) {
            activa = false
            game.removeVisual(self)
            duenio.recuperarBomba()
            
            const exp = new Explosion(posicion = self.posicion())
            exp.propagar(alcance)
        }
    }
    
    method serAlcanzadoPorFuego() {
        self.detonar() // Reacción en cadena
    }
    
    method caerAlVacio() {
        activa = false
        duenio.recuperarBomba()
        game.removeVisual(self)
    }
    
    method sumergirEnLava() {
        self.detonar()
    }
}