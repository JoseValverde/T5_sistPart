class ElementoSeguidor extends ElementoBase {
  ElementoBase padre;
  float delay;
  PVector offset;
  
  // Factor para controlar la distancia entre elementos
  float factorDistancia;
  
  ElementoSeguidor(PVector posicion, color colorInicial, PShape forma, ElementoBase padre) {
    super(posicion, colorInicial, forma);
    this.padre = padre;
    
    // Reducir significativamente el valor de delay para hacer el efecto más notable
    // Con valores más bajos, el lerp hace transiciones más lentas
    float delayBase = random(0.1, 0.03); // Valores anteriores: 0.2, 0.5
    
    // Acumulación de delay basado en el nivel jerárquico
    if (padre instanceof ElementoSeguidor) {
      // Si el padre es un ElementoSeguidor, acumular su delay con un factor menor
      // para que siga siendo apreciable pero no demasiado extremo
      this.delay = delayBase ;
    } else {
      // Si el padre es el elemento principal, solo usar el delay base
      this.delay = delayBase;
    }
    
    // Factor de distancia aleatorio pero mayor
    this.factorDistancia = random(100, 200);
    
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
    // Con un delay más bajo, la interpolación es más lenta, creando más retraso visual
    posicion.lerp(objetivo, delay);
    
    // Actualización suave de color
    colorActual = lerpColor(colorActual, padre.colorActual, delay);
  }
}
