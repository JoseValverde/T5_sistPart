class ElementoPrincipal extends ElementoBase {
  
  // Rangos para cambio de dirección - aumentados significativamente
  float minCambioDireccion = -18.0;  // Antes era -3.0
  float maxCambioDireccion = 18.0;   // Antes era 3.0
  
  // Margen de seguridad para los bordes
  float margenSeguridad = 50;
  
  ElementoPrincipal(PVector posicion, color colorInicial, PShape forma) {
    super(posicion, colorInicial, forma);
    
    // Sobrescribir los limitadores heredados con valores más altos
    this.maxVelocidad = 40.0;       // Mayor que el valor predeterminado (20.0)
    this.maxAceleracion = 2.5;      // Mayor que el valor predeterminado (1.5)
    
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
    for (ElementoBase elemento : todosElementos) {
      if (elemento instanceof ElementoSeguidor) {
        ElementoSeguidor hijo = (ElementoSeguidor)elemento;
        if (hijo.padre == this) {
          hijo.señalizarCambioDireccion();
        }
      }
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
