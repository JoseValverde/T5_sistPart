class ElementoSeguidor extends ElementoBase {
  ElementoBase padre;
  float delay;
  // Dirección base del offset (unitaria) para evitar normalizaciones por frame
  PVector direccionOffset;
  float factorDistancia;
  int nivelJerarquico;
  
  ElementoSeguidor(PVector posicion, color colorInicial, PShape forma, ElementoBase padre) {
    super(posicion, colorInicial, forma);
    this.padre = padre;
    
    // Corregido: rango invertido (antes era random(0.1, 0.03))
    float delayBase = random(0.03, 0.1);
    
    // Acumulación de delay basado en el nivel jerárquico - corregido
    if (padre instanceof ElementoSeguidor) {
      // Acumular el delay del padre + un pequeño delay propio
      this.delay = ((ElementoSeguidor)padre).delay * 0.8 + delayBase * 0.2;
      this.nivelJerarquico = ((ElementoSeguidor)padre).nivelJerarquico + 1;
    } else {
      this.delay = delayBase;
      this.nivelJerarquico = 0;
    }
    
    this.factorDistancia = random(100, 200);
    
    // Guardar una dirección unitaria reutilizable
    this.direccionOffset = PVector.random3D();
  }
  
  void actualizar() {
    // Obtener niveles de audio para modulación
    float nivelAudio = 1.0;
    
    // Determinar qué nivel de audio usar según posición en la jerarquía
    if (padre instanceof ElementoPrincipal) {
      nivelAudio = 1.0 + audioManager.getNivelGraves() * 2.0;
    } else {
      switch (nivelJerarquico % 3) {
        case 0: nivelAudio = 1.0 + audioManager.getNivelGraves() * 2.0; break;
        case 1: nivelAudio = 1.0 + audioManager.getNivelMedios() * 2.0; break;
        case 2: nivelAudio = 1.0 + audioManager.getNivelAgudos() * 2.0; break;
      }
    }
    
    // Evitar alocaciones temporales por frame
    float distanciaModulada = factorDistancia * nivelAudio;
    float objetivoX = padre.posicion.x + direccionOffset.x * distanciaModulada;
    float objetivoY = padre.posicion.y + direccionOffset.y * distanciaModulada;
    float objetivoZ = padre.posicion.z + direccionOffset.z * distanciaModulada;
    
    posicion.x = lerp(posicion.x, objetivoX, delay);
    posicion.y = lerp(posicion.y, objetivoY, delay);
    posicion.z = lerp(posicion.z, objetivoZ, delay);
    colorActual = lerpColor(colorActual, padre.colorActual, delay);
  }
  
  // Método para calcular nivel jerárquico - más eficiente
  int getNivel() {
    return nivelJerarquico;
  }
}
