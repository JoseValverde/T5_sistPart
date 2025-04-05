class ElementoSeguidor extends ElementoBase {
  ElementoBase padre;
  float delay;
  PVector offset;
  
  // Factor para controlar la distancia entre elementos
  float factorDistancia;
  
  // Retraso para el cambio de dirección basado en la jerarquía
  int retrasoCambioDireccion;
  
  ElementoSeguidor(PVector posicion, color colorInicial, PShape forma, ElementoBase padre) {
    super(posicion, colorInicial, forma);
    this.padre = padre;
    
    // Valor de retraso base para este elemento
    float delayBase = random(0.2, 0.5);
    
    // Acumulación de delay basado en el nivel jerárquico
    if (padre instanceof ElementoSeguidor) {
      // Si el padre es un ElementoSeguidor, acumular su delay
      this.delay = delayBase + ((ElementoSeguidor)padre).delay;
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
    
    // Calcular retraso para cambio de dirección
    if (padre instanceof ElementoSeguidor) {
      // Acumular retraso basado en el padre
      this.retrasoCambioDireccion = 500 + ((ElementoSeguidor)padre).retrasoCambioDireccion;
    } else {
      // Retraso base para hijos directos del elemento principal
      this.retrasoCambioDireccion = 500;
    }
  }
  
  void cambiarDireccion() {
    // Similar al elemento principal pero con variaciones menos pronunciadas
    PVector nuevaDireccion = new PVector(
      random(-2.0, 2.0),
      random(-2.0, 2.0),
      random(-2.0, 2.0)
    );
    
    // Aplicar cambio con suavizado
    velocidad.lerp(nuevaDireccion, factorEase);
    velocidad.limit(maxVelocidad);
    
    // Registrar tiempo y limpiar bandera
    tiempoUltimoCambio = millis();
    cambiarDireccionPendiente = false;
    
    // Propagar a los hijos de este elemento
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
    // Verificar si hay un cambio de dirección pendiente y si pasó el tiempo de retraso
    if (cambiarDireccionPendiente && ((padre.tiempoUltimoCambio + retrasoCambioDireccion) < millis())) {
      cambiarDireccion();
    }
    
    // Obtener la posición objetivo (padre + offset)
    PVector objetivo = PVector.add(padre.posicion, offset);
    
    // Seguir al padre con delay (ease)
    posicion.lerp(objetivo, delay);
    
    // Actualización suave de color
    colorActual = lerpColor(colorActual, padre.colorActual, delay);
  }
}
