class ElementoPrincipal extends ElementoBase {
  
  // Rangos para cambio de dirección - más controlados
  float minCambioDireccion = -20.0;  // Reducido de -18.0
  float maxCambioDireccion = 20.0;   // Reducido de 18.0
  
  // Margen de seguridad aumentado para mejorar visibilidad
  float margenSeguridad = 150;
  
  // Límites de movimiento más estrictos
  float limiteZ = 300;  // Reducido para mantener visibilidad
  
  ElementoPrincipal(PVector posicion, color colorInicial, PShape forma) {
    super(posicion, colorInicial, forma);
    
    // Limites de velocidad más controlados
    this.maxVelocidad = 30.0;       // Reducido de 40.0
    this.maxAceleracion = 2.0;      // Reducido de 2.5
    
    // Iniciar con velocidad aleatoria más alta
    velocidad = new PVector(
      random(-2, 2),
      random(-2, 2),
      random(-2, 2)
    );
  }
  
  void cambiarDireccion() {
    // Cambio de dirección más pronunciado al detectar un grave
    PVector nuevaDireccion = new PVector(
      random(minCambioDireccion, maxCambioDireccion),
      random(minCambioDireccion, maxCambioDireccion),
      random(minCambioDireccion, maxCambioDireccion)
    );
    
    // Aplicar cambio con suavizado (ease)
    velocidad.lerp(nuevaDireccion, factorEase);
    velocidad.limit(maxVelocidad);
    
    // Registrar el tiempo del cambio
    tiempoUltimoCambio = millis();
    cambiarDireccionPendiente = false;
    
    // Señalizar a todos los hijos directos para cambiar su dirección
    propagarCambioDireccion();
  }
  
  // Método para propagar el cambio a los hijos directos
  void propagarCambioDireccion() {
    for (ElementoBase hijo : hijos) {
      hijo.señalizarCambioDireccion();
    }
  }
  
  @Override
  void cambiarColor(color nuevoColor) {
    super.cambiarColor(nuevoColor);
    propagarCambioColor();
  }
  
  // Método para propagar el cambio de color a hijos directos
  void propagarCambioColor() {
    for (ElementoBase hijo : hijos) {
      hijo.señalizarCambioColor(colorActual);
    }
  }
  
  void actualizar() {
    // Verificar si hay un cambio de dirección pendiente
    if (cambiarDireccionPendiente) {
      cambiarDireccion();
    }
    
    // Actualizar velocidad
    velocidad.add(aceleracion);
    velocidad.limit(maxVelocidad);
    
    // Actualizar posición
    posicion.add(velocidad);
    
    // Límites adaptados considerando posición de cámara y rotación
    // Reducir área de movimiento para compensar efectos de rotación
    float areaEfectivaX = width * 0.7;
    float areaEfectivaY = height * 0.7;
    
    float centroX = width/2;
    float centroY = height/2;
    
    // Rebote en los bordes con margen de seguridad
    if (posicion.x < centroX - areaEfectivaX/2 + margenSeguridad || 
        posicion.x > centroX + areaEfectivaX/2 - margenSeguridad) {
      velocidad.x *= -1;
      // Corregir posición para que esté dentro de los límites
      posicion.x = constrain(posicion.x, 
                           centroX - areaEfectivaX/2 + margenSeguridad, 
                           centroX + areaEfectivaX/2 - margenSeguridad);
    }
    
    if (posicion.y < centroY - areaEfectivaY/2 + margenSeguridad || 
        posicion.y > centroY + areaEfectivaY/2 - margenSeguridad) {
      velocidad.y *= -1;
      // Corregir posición para que esté dentro de los límites
      posicion.y = constrain(posicion.y, 
                           centroY - areaEfectivaY/2 + margenSeguridad, 
                           centroY + areaEfectivaY/2 - margenSeguridad);
    }
    
    // Limitar movimiento en Z para asegurar visibilidad
    if (posicion.z < -limiteZ + margenSeguridad || posicion.z > limiteZ - margenSeguridad) {
      velocidad.z *= -1;
      // Corregir posición para que esté dentro de los límites
      posicion.z = constrain(posicion.z, 
                           -limiteZ + margenSeguridad, 
                           limiteZ - margenSeguridad);
    }
    
    // Reiniciar aceleración
    aceleracion.mult(0);
  }
}
