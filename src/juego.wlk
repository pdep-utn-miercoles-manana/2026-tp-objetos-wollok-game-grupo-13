import wollok.game.*

object juego {
method iniciar(){
    game.width(20)
    game.height(14)

    game.addVisualCharacter(bomberman)
    
    game.onCollideDo(bomberman,{ algo => algo.teAgarro() })

    game.schedule(2000, {game.removeTickEvent("aparece bicho")})
    game.schedule(2000, {game.removeTickEvent("aparece roca")})

    keyboard.space().onPressDo({
        bomberman.poneBomba()
    })

    self.generarBichos()
    self.generarRocas()
}

    method generarBichos () {
    game.onTick(500, "aparece bicho", { self.generarBicho() })
    }

    method generarRocas () {
        game.onTick(500,"aparece roca", {self.generarRoca()})
    }

    method generarRoca() {
        const pos = self.posicionAleatoria()
        const roca = new Roca (position = pos)
        game.addVisual(roca)
    }

    method generarBicho() {
        const pos = self.posicionAleatoria()
        const bicho = new Bicho (position = pos)
        game.addVisual(bicho)
    }

    method posicionAleatoria() = game.at(
        0.randomUpTo(game.width()),
        0.randomUpTo(game.height())
    )

    method perder(){
        game.clear()
        game.addVisual(bomberman)
        game.say(bomberman, "Perdi")
    }
}

object bomberman {
    var position = game.center()
    var vidas = 3
    
    method esAtravesable() = true

    method position() = position
    
    method position(nuevaPosicion) {
        if (self.puedeMoverseA(nuevaPosicion)) {
            position = nuevaPosicion
        }
    }

    method puedeMoverseA(posicion) {
        return game.getObjectsIn(posicion).all({ objeto => objeto.esAtravesable() })
    }

    method image () = "assets/bomberman.png"

    method perderVida() {
        vidas -= 1
        game.say(self, self.vida().toString())
        if (vidas == 0){
            juego.perder()
        }
    }

    method poneBomba() {
        const bomba = new Bomba(position = self.position())
        bomba.explotar()
        game.addVisual(bomba)
    }

    method quemarse() {
        self.perderVida()
    }
    method vida() = vidas

    method aumentar() {}


}

class Bomba {
    method esAtravesable() = false
    const position
    method image() = "assets/bomba.png"
    method position() = position

    method explotar () {
        game.onTick(3000, "bomba", {self.explota()})
    }

    method explota() {
        game.removeTickEvent("bomba")
        game.removeVisual(self)
        self.expandir()
    }

    method expandir() {
        const posicionesFuego = [
            self.position(),           
            self.position().up(1),   
            self.position().down(1),   
            self.position().left(1),  
            self.position().right(1)   
        ]

        posicionesFuego.forEach({ pos => self.crearFuegoEn(pos) })
    }

    method crearFuegoEn(pos) {
        const fuego = new Fuego (position = pos)
        game.addVisual(fuego)
        game.onCollideDo(fuego, { elemento => elemento.quemarse() })
        game.colliders(fuego).forEach({ elemento => elemento.quemarse() })
        
        game.onTick(1000, "fuego_" + fuego.toString(), { fuego.extingir() })
    }

    method quemarse(){
        self.explota()
    }
    method teAgarro(){
    }
}

class Fuego {
    const position
    method esAtravesable() = true
    method image() = "assets/explocionCentro1.png"
    method position() = position

    method extingir () {
        game.removeTickEvent("fuego_" + self.toString())
        game.removeVisual(self)
    }

    method quemarse() {}
    method teAgarro(){}

}
class Bicho {
    method esAtravesable() = true
    var position = null
    method image() = "assets/ballom.png"

    method teAgarro() {
        bomberman.perderVida()
    }

    method aparecer () {
        position = juego.posicionAleatoria()
        game.addVisual(self)
        self.moverseAleatoriamente()
    }

    method moverseAleatoriamente() {
    }

    method puedeMoverseA(posicion) {
        return game.getObjectsIn(posicion).all({ objeto => objeto.esAtravesable() })
    }


    method perderVida() {
        game.removeVisual(self)
        game.removeTickEvent("movimiento_" + self.toString())
    }

    method quemarse() {
        self.perderVida()
    }

    method position() = position

}
class Roca {
    const position = null
    method esAtravesable() = false

    method image() = "assets/ladrilloPiedra.png"

    method teAgarro() {

    }

    method generarRocas() {
    }

    method quemarse() {

    }
    method position() = position

}


