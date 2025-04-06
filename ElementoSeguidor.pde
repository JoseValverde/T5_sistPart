class ElementoSeguidor extends ElementoBase {
  ElementoBase padre;
  float delay;
  PVector offset;
  float factorDistancia;
  
  ElementoSeguidor(PVector posicion, color colorInicial, PShape forma, ElementoBase padre) {
    super(posicion, colorInicial, forma);
    this.padre = padre;
    
    // Corregido: rango invertido (antes era random(0.1, 0.03))
    float delayBase = random(0.03, 0.1);
    
    // Acumulación de delay basado en el nivel jerárquico - corregido
    if (padre instanceof ElementoSeguidor) {
      // Acumular el delay del padre + un pequeño delay propio
      this.delay = ((ElementoSeguidor)padre).delay * 0.8 + delayBase * 0.2;
    } else {
      this.delay = delayBase;
    }
    
    this.factorDistancia = random(100, 200);
    
    // Optimizado: Vector dirección con valores más eficientes
    PVector direccionAleatoria = PVector.random3D(); // Más eficiente que crear y normalizar
    this.offset = PVector.mult(direccionAleatoria, factorDistancia);
  }
  
  void actualizar() {
    // Obtener niveles de audio para modulación
    float nivelAudio = 1.0;
    
    // Determinar qué nivel de audio usar según posición en la jerarquía
    if (padre instanceof ElementoPrincipal) {
      nivelAudio = 1.0 + audioManager.getNivelGraves() * 2.0;
    } else {
      // Determinar nivel en jerarquía de forma más eficiente
      ElementoSeguidor padreSeguidor = (ElementoSeguidor)padre;
      int nivel = padreSeguidor.getNivel() + 1;
      
      switch (nivel % 3) {
        case 0: nivelAudio = 1.0 + audioManager.getNivelGraves() * 2.0; break;
        case 1: nivelAudio = 1.0 + audioManager.getNivelMedios() * 2.0; break;
        case 2: nivelAudio = 1.0 + audioManager.getNivelAgudos() * 2.0; break;
      }
    }
    
    // Aplicar modulación a la distancia
    PVector offsetModulado = PVector.mult(offset.normalize(), factorDistancia * nivelAudio);
    PVector objetivo = PVector.add(padre.posicion, offsetModulado);
    
    // Seguir al padre con delay
    posicion.lerp(objetivo, delay);
    colorActual = lerpColor(colorActual, padre.colorActual, delay);
  }
  
  // Método para calcular nivel jerárquico - más eficiente
  int getNivel() {
    if (padre instanceof ElementoPrincipal) return 0;
    return ((ElementoSeguidor)padre).getNivel() + 1;
  }
}
