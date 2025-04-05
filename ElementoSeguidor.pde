class ElementoSeguidor extends ElementoBase {
  ElementoBase padre;
  float delay;
  PVector offset;
  
  ElementoSeguidor(PVector posicion, color colorInicial, PShape forma, ElementoBase padre) {
    super(posicion, colorInicial, forma);
    this.padre = padre;
    
    // Valor de retraso aleatorio para seguimiento
    this.delay = random(0.02, 0.1);
    
    // Pequeña variación en la posición
    this.offset = new PVector(
      random(-20, 20),
      random(-20, 20),
      random(-20, 20)
    );
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
