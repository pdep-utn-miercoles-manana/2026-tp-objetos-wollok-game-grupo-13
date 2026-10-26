import wollok.game.*
import superficie.*
import elementos.*

object arena {
    const property celdas = new Dictionary()
    var property radioActual = 0
    
    method inicializar(ancho, alto) {
        celdas.clear()
        radioActual = 0
        
        (0 .. ancho - 1).forEach { x =>
            (0 .. alto - 1).forEach { y =>
                const pos = game.at(x, y)
                const baldosa = new BaldosaNormal(position = pos)
                celdas.put(pos, baldosa)
                game.addVisual(baldosa)
            }
        }
    }
    
    method reemplazarBaldosa(posicion, nuevaBaldosa) {
        const vieja = celdas.get(posicion)
        if (vieja != null) game.removeVisual(vieja)
        celdas.put(posicion, nuevaBaldosa)
        game.addVisual(nuevaBaldosa)
    }
    
    method iniciarColapsoAnillo() {
        game.onTick(12000, "colapsoPerimetro", { self.reducirPerimetro() })
    }
    
    method reducirPerimetro() {
        const baldosasBorde = self.obtenerBaldosasEnBorde()
        baldosasBorde.forEach({ baldosa => baldosa.bajar() })
        radioActual += 1
    }
    
    method obtenerBaldosasEnBorde() {
        const minX = radioActual
        const maxX = game.width() - 1 - radioActual
        const minY = radioActual
        const maxY = game.height() - 1 - radioActual
        
        if (minX > maxX or minY > maxY) return []
        
        return celdas.values().filter({ baldosa =>
            const pos = baldosa.position()
            (pos.x() == minX or pos.x() == maxX or pos.y() == minY or pos.y() == maxY) and
            pos.x().between(minX, maxX) and pos.y().between(minY, maxY)
        })
    }
}

object gestorLava {
    var property alturaLava = 0
    var property subiendo = true
    var property cotaMaxima = 3
    const celdasLavaActivas = []
    
    method iniciarCicloMarea(intervaloMs) {
        game.onTick(intervaloMs, "mareaLava", { self.avanzarMarea() })
    }
    
    method avanzarMarea() {
        if (subiendo) {
            self.inundarFila(alturaLava)
            alturaLava += 1
            if (alturaLava >= cotaMaxima) subiendo = false
        } else {
            alturaLava -= 1
            self.drenarFila(alturaLava)
            if (alturaLava <= 0) subiendo = true
        }
    }
    
    method inundarFila(y) {
        (0 .. game.width() - 1).forEach { x =>
            const pos = game.at(x, y)
            const lava = new CeldaLava(position = pos)
            celdasLavaActivas.add(lava)
            game.addVisual(lava)
            lava.sumergirEnLava()
        }
    }
    
    method drenarFila(y) {
        const aRemover = celdasLavaActivas.filter({ cl => cl.position().y() == y })
        aRemover.forEach { cl =>
            game.removeVisual(cl)
            celdasLavaActivas.remove(cl)
        }
    }
    
    method detener() {
        game.removeTickEvent("mareaLava")
    }
}