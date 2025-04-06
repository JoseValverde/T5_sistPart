abstract class ElementoBase {
  PVector posicion;
  PVector velocidad;
  PVector aceleracion;
  color colorActual;
  PShape forma;
  
  // Limitadores de movimiento
  float maxVelocidad = 20.0;
  float maxAceleracion = 0.05;
  
  // Factor de suavizado para movimientos (ease)
  float factorEase = 0.1;
  
  // Variables para control de cambios de dirección en cascada
  boolean cambiarDireccionPendiente = false;
  int tiempoUltimoCambio = 0;
  
  // Variables para rotación estable
  float rotationSpeed;
  float rotationOffset;
  
  ElementoBase(PVector posicion, color colorInicial, PShape forma) {
    this.posicion = posicion;
    this.colorActual = colorInicial;
    this.forma = forma;
    this.velocidad = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
    this.aceleracion = new PVector(0, 0, 0);
    
    // Inicializar valores de rotación estables
    this.rotationSpeed = random(0.005, 0.02);
    this.rotationOffset = random(TWO_PI);
  }
  
  void aplicarFuerza(PVector fuerza) {
    aceleracion.add(fuerza);
    aceleracion.limit(maxAceleracion);
  }
  
  void cambiarColor(color nuevoColor) {
    colorActual = nuevoColor;
  }
  
  // Método para señalizar un cambio de dirección pendiente
  void señalizarCambioDireccion() {
    cambiarDireccionPendiente = true;
  }
  
  abstract void actualizar();
  
  void mostrar() {
    pushMatrix();
    translate(posicion.x, posicion.y, posicion.z);
    
    // Rotación más eficiente con valores precalculados
    float rotY = sin(frameCount * rotationSpeed + rotationOffset);
    float rotX = cos(frameCount * rotationSpeed * 0.7);
    rotateY(rotY);
    rotateX(rotX);
    
    // Material más eficiente
    shininess(5.0);
    
    // Aplicar color - sin stroke para mejor rendimiento
    forma.setFill(colorActual);
    forma.setStroke(false);
    
    shape(forma);
    popMatrix();
  }
}
