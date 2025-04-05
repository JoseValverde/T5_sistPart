class ElementoPrincipal extends ElementoBase {
  
  // Rangos para cambio de dirección
  float minCambioDireccion = -3.0;
  float maxCambioDireccion = 3.0;
  
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
    
    // Rebote en los bordes
    if (posicion.x < 0 || posicion.x > width) velocidad.x *= -1;
    if (posicion.y < 0 || posicion.y > height) velocidad.y *= -1;
    if (posicion.z < -500 || posicion.z > 500) velocidad.z *= -1;
    
    // Reiniciar aceleración
    aceleracion.mult(0);
  }
}
