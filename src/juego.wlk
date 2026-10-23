import wollok.game.*

object juego {
method iniciar(){
    game.width(20)
    game.height(14)

    //Hace que se mueva con las teclas
    game.addVisualCharacter(bomberman)
    
    game.onCollideDo(bomberman,{ algo => algo.teAgarro() })

    game.schedule(2000, {game.removeTickEvent("aparece bicho")})

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
        game.schedule(500, {self.generarRoca()})
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

    method terminar(){
        game.clear()
        game.addVisual(bomberman)
        game.say(bomberman, "Perdi")
    }
}

object bomberman {
    var property position = game.center()
    var vidas = 3

    method image () = "assets/bomberman.png"

    method perderVida() {
        game.say(self, self.vida().toString())
        vidas -= 1
        if (vidas < 0){
            juego.terminar()
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
    var position
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
    var position
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
        position = game.at(
            position.x() + 1,
            position.y() - 1
        )
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

    method image() = "assets/ladrilloPiedra.png"

    method teAgarro() {

    }

    method generarRocas() {
    }

    method quemarse() {

    }
    method position() = position

}


