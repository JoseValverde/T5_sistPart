class ElementoPrincipal extends ElementoBase {
  
  // Rangos para cambio de dirección
  float minCambioDireccion = -3.0;
  float maxCambioDireccion = 3.0;
  
  // Margen de seguridad para los bordes
  float margenSeguridad = 50;
  
  ElementoPrincipal(PVector posicion, color colorInicial, PShape forma) {
    super(posicion, colorInicial, forma);
    // Iniciar con velocidad aleatoria
    velocidad = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
  }
  
  void cambiarDireccion() {
    // Cambiar dirección aleatoriamente al detectar un grave
    PVector nuevaDireccion = new PVector(
      random(minCambioDireccion, maxCambioDireccion),
      random(minCambioDireccion, maxCambioDireccion),
      random(minCambioDireccion, maxCambioDireccion)
    );
    
    // Aplicar cambio con suavizado (ease)
    velocidad.lerp(nuevaDireccion, factorEase);
    velocidad.limit(maxVelocidad);
  }
  
  void actualizar() {
    // Actualizar velocidad
    velocidad.add(aceleracion);
    velocidad.limit(maxVelocidad);
    
    // Actualizar posición
    posicion.add(velocidad);
    
    // Rebote en los bordes con margen de seguridad
    if (posicion.x < margenSeguridad || posicion.x > width - margenSeguridad) {
      velocidad.x *= -1;
      // Corregir posición para que esté dentro de los límites
      posicion.x = constrain(posicion.x, margenSeguridad, width - margenSeguridad);
    }
    
    if (posicion.y < margenSeguridad || posicion.y > height - margenSeguridad) {
      velocidad.y *= -1;
      // Corregir posición para que esté dentro de los límites
      posicion.y = constrain(posicion.y, margenSeguridad, height - margenSeguridad);
    }
    
    if (posicion.z < -500 + margenSeguridad || posicion.z > 500 - margenSeguridad) {
      velocidad.z *= -1;
      // Corregir posición para que esté dentro de los límites
      posicion.z = constrain(posicion.z, -500 + margenSeguridad, 500 - margenSeguridad);
    }
    
    // Reiniciar aceleración
    aceleracion.mult(0);
  }
}
