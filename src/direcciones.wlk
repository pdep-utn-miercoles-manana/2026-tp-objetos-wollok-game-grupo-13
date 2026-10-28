import wollok.game.*

// Posición que permite coordenadas no enteras para representar movimiento continuo o sub-pasos
class PosicionFluida inherits Position {
    override method round() = self
    override method createPosition(nuevaCoordenadaX, nuevaCoordenadaY) = new PosicionFluida(x = nuevaCoordenadaX, y = nuevaCoordenadaY)
    method celdaRedondeada() = game.at(x.round(), y.round())
}

// Representa una dirección de desplazamiento en la grilla y su nombre de vista asociado
class Direccion {
    method desplazamientoHorizontal() = 0
    method desplazamientoVertical() = 0
    method siguientePosicion(posicionActual) = posicionActual.createPosition(
        posicionActual.x() + self.desplazamientoHorizontal(),
        posicionActual.y() + self.desplazamientoVertical()
    )
    method nombreVista()

    // Métodos de compatibilidad histórica
    method dx() = self.desplazamientoHorizontal()
    method dy() = self.desplazamientoVertical()
    method siguiente(posicionActual) = self.siguientePosicion(posicionActual)
}

object arriba inherits Direccion {
    override method desplazamientoVertical() = 1
    override method nombreVista() = "arriba"
}

object abajo inherits Direccion {
    override method desplazamientoVertical() = -1
    override method nombreVista() = "abajo"
}

object izquierda inherits Direccion {
    override method desplazamientoHorizontal() = -1
    override method nombreVista() = "izquierda"
}

object derecha inherits Direccion {
    override method desplazamientoHorizontal() = 1
    override method nombreVista() = "derecha"
}

object direcciones {
    method todas() = [arriba, abajo, izquierda, derecha]
}
