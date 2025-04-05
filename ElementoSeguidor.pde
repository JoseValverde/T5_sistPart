class ElementoSeguidor extends ElementoBase {
  ElementoBase padre;
  float delay;
  PVector offset;
  
  // Factor para controlar la distancia entre elementos
  float factorDistancia;
  
  ElementoSeguidor(PVector posicion, color colorInicial, PShape forma, ElementoBase padre) {
    super(posicion, colorInicial, forma);
    this.padre = padre;
    
    // Valor de retraso aleatorio para seguimiento
    this.delay = random(0.02, 0.08); // Reducido ligeramente para respuesta más lenta
    
    // Factor de distancia aleatorio pero mayor
    this.factorDistancia = random(40, 80);
    
    // Generar un vector de dirección aleatoria normalizado
    PVector direccionAleatoria = new PVector(
      random(-1, 1),
      random(-1, 1),
      random(-1, 1)
    );
    direccionAleatoria.normalize();
    
    // Aplicar el factor de distancia para crear más separación
    this.offset = PVector.mult(direccionAleatoria, factorDistancia);
  }
  
  void actualizar() {
    // Obtener la posición objetivo (padre + offset)
    PVector objetivo = PVector.add(padre.posicion, offset);
    
    // Seguir al padre con delay (ease)
    posicion.lerp(objetivo, delay);
    
    // Actualización suave de color
    colorActual = lerpColor(colorActual, padre.colorActual, delay);
  }
}
