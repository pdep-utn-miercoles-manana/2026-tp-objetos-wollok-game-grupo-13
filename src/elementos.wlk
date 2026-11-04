import wollok.game.*
import src.jugador.*
import src.direcciones.*
import src.superficie.*
import src.partida.*
import src.arena.*
import src.audio.*

class BloqueIndestructible inherits Superficie {
    var imagenActual = "muro_indestructible_1.png"

    override method image() = imagenActual
    override method permitePaso() = false
    override method colapsarEnAbismo() {}

    method actualizarFrame(unNumeroFrame) {
        imagenActual = "muro_indestructible_" + unNumeroFrame + ".png"
    }
}

class CajaDestructible inherits Superficie {
    override method image() = "caja_madera.png"
    override method permitePaso() = false
    
    override method serAlcanzadoPorFuego() {
        self.soltarPowerUpOpcional()
        game.removeVisual(self)
    }

    override method colapsarEnAbismo() {
        self.serAlcanzadoPorFuego()
    }

    method soltarPowerUpOpcional() {
        const probabilidadAzar = 1.randomUpTo(10).round()
        if (probabilidadAzar == 1) game.addVisual(new FuegoExtra(position = self.position()))
        if (probabilidadAzar == 2) game.addVisual(new BombaExtra(position = self.position()))
        if (probabilidadAzar == 3) game.addVisual(new PatinVelocidad(position = self.position()))
    }
}

object gestorBombas {
    const property bombasActivas = []
    const property explosionesActivas = []
    var relojActivo = false
    const intervaloMilisegundos = 150

    method iniciar() {
        self.detener()
        self.asegurarRelojActivo()
    }

    method asegurarRelojActivo() {
        if (not relojActivo) {
            relojActivo = true
            game.onTick(intervaloMilisegundos, "RELOJ_BOMBAS", { self.avanzarTick() })
        }
    }

    method detener() {
        bombasActivas.forEach({ bomba =>
            if (game.hasVisual(bomba)) game.removeVisual(bomba)
        })
        bombasActivas.clear()
        explosionesActivas.forEach({ explosion =>
            explosion.extinguir()
        })
        explosionesActivas.clear()
        if (relojActivo) {
            relojActivo = false
            game.removeTickEvent("RELOJ_BOMBAS")
        }
    }

    method registrarBomba(unaBomba) {
        self.asegurarRelojActivo()
        bombasActivas.add(unaBomba)
    }

    method removerBomba(unaBomba) {
        bombasActivas.remove(unaBomba)
    }

    method registrarExplosion(unaExplosion) {
        self.asegurarRelojActivo()
        explosionesActivas.add(unaExplosion)
    }

    method removerExplosion(unaExplosion) {
        explosionesActivas.remove(unaExplosion)
    }

    method detonarBombasEn(unaPosicion) {
        if (not bombasActivas.isEmpty()) {
            const copiaBombas = []
            copiaBombas.addAll(bombasActivas)
            copiaBombas.forEach({ bomba =>
                if (bomba.posicion() == unaPosicion) {
                    bomba.detonar()
                }
            })
        }
    }

    method avanzarTick() {
        if (not partida.juegoPausado() and not partida.partidaTerminada()) {
            if (not bombasActivas.isEmpty()) {
                const copiaBombas = []
                copiaBombas.addAll(bombasActivas)
                copiaBombas.forEach({ bomba => bomba.avanzarTiempo(intervaloMilisegundos) })
            }
            if (not explosionesActivas.isEmpty()) {
                const copiaExplosiones = []
                copiaExplosiones.addAll(explosionesActivas)
                copiaExplosiones.forEach({ explosion => explosion.avanzarTiempo(intervaloMilisegundos) })
            }
        }
    }
}

class Bomba inherits Superficie {
    var property duenio
    var property alcance
    var property duracionMilisegundos = 3000
    var tiempoRestanteMilisegundos = duracionMilisegundos
    var activa = false
    var frameActual = 1
    var imagenActual = "bomba_1.png"

    method posicion() = position
    method posicion(unaPosicion) { position = unaPosicion }
    method duracionMs() = duracionMilisegundos
    method duracionMs(unValor) { duracionMilisegundos = unValor }

    override method image() = imagenActual
    override method permitePaso() = false
    override method interactuarCon(unJugador) {}
    override method serAlcanzadoPorFuego() { self.detonar() }
    override method colapsarEnAbismo() { self.detonar() }

    method plantar() {
        tiempoRestanteMilisegundos = duracionMilisegundos
        frameActual = 1
        imagenActual = "bomba_1.png"
        activa = true
        game.addVisual(self)
        gestorBombas.registrarBomba(self)
    }

    method avanzarTiempo(deltaMilisegundos) {
        if (activa and not partida.partidaTerminada()) {
            frameActual = (frameActual % 5) + 1
            imagenActual = "bomba_" + frameActual + ".png"
            tiempoRestanteMilisegundos = 0.max(tiempoRestanteMilisegundos - deltaMilisegundos)
            if (tiempoRestanteMilisegundos == 0) {
                self.detonar()
            }
        }
    }

    method detonar() {
        if (activa) {
            activa = false
            gestorBombas.removerBomba(self)
            game.removeVisual(self)
            duenio.reintegrarBomba()
            gestorAudio.reproducirExplosion()
            const explosion = new Explosion(posicion = self.posicion())
            explosion.propagar(alcance)
        }
    }
}

class Explosion {
    var property posicion
    var property duracionMilisegundos = 450
    var tiempoRestanteMilisegundos = duracionMilisegundos
    const llamasActivas = []

    method duracionMs() = duracionMilisegundos
    method duracionMs(unValor) { duracionMilisegundos = unValor }

    method position() = posicion
    method image() = "fuego_centro.png"
    method permitePaso() = true
    method serAlcanzadoPorFuego() {}
    method colapsarEnAbismo() {}
    method interactuarCon(unJugador) {
        unJugador.serAlcanzadoPorFuego()
    }

    method propagar(alcance) {
        llamasActivas.clear()
        tiempoRestanteMilisegundos = duracionMilisegundos
        self.impactarYCrearLlamaEn(self.posicion())
        
        direcciones.todas().forEach({ direccion => 
            self.expandirHacia(self.posicion(), direccion, alcance) 
        })

        gestorBombas.registrarExplosion(self)
    }

    method avanzarTiempo(deltaMilisegundos) {
        tiempoRestanteMilisegundos = 0.max(tiempoRestanteMilisegundos - deltaMilisegundos)
        if (tiempoRestanteMilisegundos == 0) {
            self.extinguir()
        }
    }

    method extinguir() {
        gestorBombas.removerExplosion(self)
        llamasActivas.forEach({ llama =>
            game.removeVisual(llama)
        })
        llamasActivas.clear()
    }

    method expandirHacia(posicionActual, direccion, pasosRestantes) {
        if (pasosRestantes > 0 and not partida.partidaTerminada()) {
            const siguientePosicion = direccion.siguientePosicion(posicionActual)
            if (self.esPosicionValida(siguientePosicion)) {
                const impactoContraSolido = self.impactarYCrearLlamaEn(siguientePosicion)
                if (not impactoContraSolido and not partida.partidaTerminada()) {
                    self.expandirHacia(siguientePosicion, direccion, pasosRestantes - 1)
                }
            }
        }
    }

    method impactarYCrearLlamaEn(unaPosicion) {
        if (partida.partidaTerminada()) {
            return true
        }
        const objetosEnCelda = game.getObjectsIn(unaPosicion)
        const conteniaSolido = objetosEnCelda.any({ unObjeto => not unObjeto.permitePaso() })

        const llama = new Explosion(posicion = unaPosicion)
        llamasActivas.add(llama)
        game.addVisual(llama)

        objetosEnCelda.forEach({ unObjeto => 
            if (unObjeto != llama) unObjeto.serAlcanzadoPorFuego() 
        })

        return conteniaSolido
    }

    method esPosicionValida(unaPosicion) {
        return arena.esPosicionDentroDeArena(unaPosicion) and
               not arena.esBordeExteriorVolcanico(unaPosicion) and
               not arena.esPosicionEnLava(unaPosicion) and
               not arena.esMuroIndestructibleFijo(unaPosicion)
    }
}

// Power-ups base con Template Method
class PowerUp inherits Superficie {
    override method permitePaso() = true
    override method interactuarCon(unJugador) {
        self.aplicarEfecto(unJugador)
        gestorAudio.reproducirPowerUp()
        game.removeVisual(self)
    }
    override method serAlcanzadoPorFuego() {
        game.removeVisual(self)
    }
    override method colapsarEnAbismo() {
        self.serAlcanzadoPorFuego()
    }
    method aplicarEfecto(unJugador) {}
}

class FuegoExtra inherits PowerUp {
    override method image() = "powerup_fuego.png"
    override method aplicarEfecto(unJugador) { unJugador.aumentarAlcance() }
}

class BombaExtra inherits PowerUp {
    override method image() = "powerup_bomba.png"
    override method aplicarEfecto(unJugador) { unJugador.aumentarMaxBombas() }
}

class PatinVelocidad inherits PowerUp {
    override method image() = "powerup_velocidad.png"
    override method aplicarEfecto(unJugador) { unJugador.aumentarVelocidad() }
}
