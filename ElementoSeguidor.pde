class ElementoSeguidor extends ElementoBase {
  ElementoBase padre;
  float delay;
  // Dirección base del offset (unitaria) para evitar normalizaciones por frame
  PVector direccionOffset;
  float factorDistancia;
  int nivelJerarquico;
  int desplazamientoColor;
  
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
    this.desplazamientoColor = 1 + (padre.hijos.size() % max(1, colorPalette.colorArray.length - 1));
    
    // Guardar una dirección unitaria reutilizable
    this.direccionOffset = PVector.random3D();
  }
  
  void actualizar() {
    int stride = 1;
    
    if (((frameCount + nivelJerarquico) % stride) != 0) {
      colorActual = colorPalette.getColorPosterior(padre.colorActual, desplazamientoColor);
      return;
    }
    
    // Mantiene: audio maximo -> distancia maxima.
    // Pero permite acercarse sin necesitar audio minimo absoluto.
    float driveDistancia = constrain((audioDriveFrame - 0.35) / 0.65, 0, 1);
    driveDistancia = pow(driveDistancia, 1.4);
    float nivelAudio = lerp(0.18, 4.8, driveDistancia);
    
    // Evitar alocaciones temporales por frame
    float distanciaModulada = factorDistancia * nivelAudio;
    float objetivoX = padre.posicion.x + direccionOffset.x * distanciaModulada;
    float objetivoY = padre.posicion.y + direccionOffset.y * distanciaModulada;
    float objetivoZ = padre.posicion.z + direccionOffset.z * distanciaModulada;
    
    posicion.x = lerp(posicion.x, objetivoX, delay);
    posicion.y = lerp(posicion.y, objetivoY, delay);
    posicion.z = lerp(posicion.z, objetivoZ, delay);
    colorActual = colorPalette.getColorPosterior(padre.colorActual, desplazamientoColor);
  }
  
  // Método para calcular nivel jerárquico - más eficiente
  int getNivel() {
    return nivelJerarquico;
  }
  
  @Override
  void mostrar() {
    int drawStride = 1;
    
    if (((frameCount + nivelJerarquico) % drawStride) != 0) {
      return;
    }
    
    pushMatrix();
    translate(posicion.x, posicion.y, posicion.z);
    
    // En niveles altos evitamos trigonometría por elemento
    if (nivelJerarquico < 4) {
      float rotY = sin(frameCount * rotationSpeed + rotationOffset);
      float rotX = cos(frameCount * rotationSpeed * 0.7);
      rotateY(rotY);
      rotateX(rotX);
    }
    
    float escalaAudio = lerp(0.12, 1.5, audioDriveFrame);
    scale(escalaAudio);

    noStroke();
    fill(colorActual);
    shape(forma);
    popMatrix();
  }
}
