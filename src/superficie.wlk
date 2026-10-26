import wollok.game.*
import arena.*

class Baldosa {
    var property position
    
    method image()
    method permitePaso() = true
    method bajar()
    // Las baldosas del piso ignoran las llamas y a los jugadores que pasan sobre ellas
    method serAlcanzadoPorFuego() {}
    method interactuarCon(jugador) {}
}

class BaldosaNormal inherits Baldosa {
    override method image() = "baldosa_metal.png" //TODO : Generar este sprite con alguna IA 
    
    override method bajar() {
        // Se reemplaza por inestable durante el ciclo de colapso
        const inestable = new BaldosaInestable(position = self.position())
        arena.reemplazarBaldosa(self.position(), inestable)
        inestable.iniciarCuentaRegresiva()
    }
}

class BaldosaInestable inherits Baldosa {
    var property tiempoRestante = 2000
    
    override method image() = "baldosa_inestable.png" //TODO : Generar este sprite con alguna IA 
    
    method iniciarCuentaRegresiva() {
        game.schedule(tiempoRestante, { self.desmoronar() })
    }
    
    method desmoronar() {
        self.bajar()
    }
    
    override method bajar() {
        // Destruye o hace caer a cualquier elemento ubicado encima
        game.getObjectsIn(self.position()).forEach({ obj => obj.caerAlVacio() })
        
        // Se transforma definitivamente en el hueco del abismo
        const abismo = new BaldosaAbismo(position = self.position())
        arena.reemplazarBaldosa(self.position(), abismo)
    }
}

class BaldosaAbismo inherits Baldosa {
    override method image() = "baldosa_vacio.png" //TODO : Generar este sprite con alguna IA 
    override method permitePaso() = false
    
    override method bajar() {
        // Ya tocó fondo en el vacío
    }
}

class PistonElevador inherits Baldosa {
    var property elevado = false
    
    override method image() = if (elevado) "piston_arriba.png" else "piston_abajo.png" //TODO : Generar este sprite con alguna IA 
    override method permitePaso() = !elevado
    
    method elevar() {
        elevado = true
    }
    
    override method bajar() {
        elevado = false
    }
}

class CeldaLava {
    var property position
    
    method image() = "fuego.png" //TODO : Generar este sprite con alguna IA 
    method permitePaso() = true
    
    method sumergirEnLava() {
        game.getObjectsIn(self.position()).forEach({ obj => obj.sumergirEnLava() })
    }
}
