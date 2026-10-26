class Direccion {
    method siguiente(posicion)
}

object arriba inherits Direccion {
    override method siguiente(posicion) = posicion.up(1)
}

object abajo inherits Direccion {
    override method siguiente(posicion) = posicion.down(1)
}

object izquierda inherits Direccion {
    override method siguiente(posicion) = posicion.left(1)
}

object derecha inherits Direccion {
    override method siguiente(posicion) = posicion.right(1)
}

// Objeto contenedor para iterar, no se si es exagerado :D
object direcciones {
    method todas() = [arriba, abajo, izquierda, derecha]
}