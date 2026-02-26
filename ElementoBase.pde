abstract class ElementoBase {
  PVector posicion;
  PVector velocidad;
  PVector aceleracion;
  color colorActual;
  PShape forma;
  ArrayList<ElementoBase> hijos;
  
  // Limitadores de movimiento
  float maxVelocidad = 20.0;
  float maxAceleracion = 0.05;
  
  // Factor de suavizado para movimientos (ease)
  float factorEase = 0.1;
  
  // Variables para control de cambios de dirección en cascada
  boolean cambiarDireccionPendiente = false;
  int tiempoUltimoCambio = 0;
  
  // Variables para control de cambios de color en cascada
  boolean cambiarColorPendiente = false;
  color colorPendiente;
  
  // Variables para rotación estable
  float rotationSpeed;
  float rotationOffset;
  
  ElementoBase(PVector posicion, color colorInicial, PShape forma) {
    this.posicion = posicion;
    this.colorActual = colorInicial;
    this.colorPendiente = colorInicial;
    this.forma = forma;
    if (this.forma != null) {
      this.forma.disableStyle();
    }
    this.hijos = new ArrayList<ElementoBase>();
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
  
  // Método para señalizar un cambio de color pendiente
  void señalizarCambioColor(color nuevoColor) {
    colorPendiente = nuevoColor;
    cambiarColorPendiente = true;
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
    
    float escalaAudio = lerp(0.12, 1.5, audioDriveFrame);
    scale(escalaAudio);
    
    // Material más eficiente
    shininess(5.0);
    
    noStroke();
    fill(colorActual);
    shape(forma);
    popMatrix();
  }
}
