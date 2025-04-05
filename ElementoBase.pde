abstract class ElementoBase {
  PVector posicion;
  PVector velocidad;
  PVector aceleracion;
  color colorActual;
  PShape forma;
  
  // Limitadores de movimiento
  float maxVelocidad = 20.0;
  float maxAceleracion = 1.5;
  
  // Factor de suavizado para movimientos (ease)
  float factorEase = 0.1;
  
  // Variables para control de cambios de dirección en cascada
  boolean cambiarDireccionPendiente = false;
  int tiempoUltimoCambio = 0;
  
  ElementoBase(PVector posicion, color colorInicial, PShape forma) {
    this.posicion = posicion;
    this.colorActual = colorInicial;
    this.forma = forma;
    this.velocidad = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
    this.aceleracion = new PVector(0, 0, 0);
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
    
    // Añadir rotación suave para que las formas sean más dinámicas
    rotateY(frameCount * 0.01);
    rotateX(frameCount * 0.005);
    
    // Material para luz
    shininess(5.0);
    specular(200, 200, 200);
    
    // Aplicar color al objeto
    forma.setFill(colorActual);
    
    // Configurar el color y grosor de las aristas
    forma.setStroke(color(0,0));  // Color negro y transparente para las aristas
    
    // Dibujar la forma
    shape(forma);
    popMatrix();
  }
}
