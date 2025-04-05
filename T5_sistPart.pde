import processing.sound.*;

// Variables globales
AudioManager audioManager;
ElementoPrincipal elementoPrincipal;
ArrayList<ElementoBase> todosElementos;
ColorPalette colorPalette;
ShapeManager shapeManager;
DebugManager debugManager;
boolean debugMode = false;

int numHijosDerivados = 3;
int nivelMaximoProfundidad = 8; // Cuántas generaciones de hijos permitir

// Variables para control de cámara
float rotX = 0;
float rotY = 0;
float camZ = 0;
boolean rotateCam = false;

void setup() {
  size(700, 1200, P3D);
  
  // Inicializar paleta de colores
  colorPalette = new ColorPalette();
  
  // Inicializar gestor de formas
  shapeManager = new ShapeManager();
  
  // Inicializar audio manager
  audioManager = new AudioManager(this, "musica/nombre.mp3");
  
  // Crear elemento principal
  elementoPrincipal = new ElementoPrincipal(
    new PVector(width/2, height/2, 0),
    colorPalette.getRandomColor(),
    shapeManager.getCurrentShape()
  );
  
  // Lista para todos los elementos
  todosElementos = new ArrayList<ElementoBase>();
  todosElementos.add(elementoPrincipal);
  
  // Crear estructura inicial de elementos seguidores
  crearHijos(elementoPrincipal, 0);
  
  // Debug manager
  debugManager = new DebugManager();
  
  // Configurar iluminación
  lights();
}

void draw() {
  background(colorPalette.getBgColor());
  
  // Configuración de la cámara y luces para espacio 3D
  setupCamera();
  
  // Actualizar análisis de audio
  audioManager.update();
  
  // Verificar y reaccionar a cambios en audio
  if (audioManager.hayGrave()) {
    elementoPrincipal.cambiarDireccion();
  }
  
  if (audioManager.hayAgudo()) {
    elementoPrincipal.cambiarColor(colorPalette.getRandomColor());
  }
  
  // Actualizar y mostrar todos los elementos
  for (ElementoBase elemento : todosElementos) {
    elemento.actualizar();
    elemento.mostrar();
  }
  
  // Mostrar debug si está activado
  if (debugMode) {
    debugManager.mostrar(elementoPrincipal, todosElementos.size(), audioManager);
  }
}

// Configurar la cámara para mejor visualización 3D
void setupCamera() {
  // Centrar en la pantalla
  translate(width/2, height/2, camZ);
  
  // Rotación de la cámara
  rotateX(rotX);
  rotateY(rotY);
  
  // Devolver al origen para que los objetos se dibujen correctamente
  translate(-width/2, -height/2, -camZ);
  
  // Añadir luces
  //ambientLight(60, 60, 60);
  //directionalLight(255, 255, 255, 1, 1, -1);
  pointLight(200, 200, 200, width/2, height/2, 200);
}

void keyPressed() {
  if (key == 'd' || key == 'D') {
    debugMode = !debugMode;
  } 
  else if (key == 'r' || key == 'R') {
    // Activar/desactivar rotación automática
    rotateCam = !rotateCam;
  }
  else if (keyCode == UP) {
    rotX -= 0.1;
  }
  else if (keyCode == DOWN) {
    rotX += 0.1;
  }
  else if (keyCode == LEFT) {
    rotY -= 0.1;
  }
  else if (keyCode == RIGHT) {
    rotY += 0.1;
  }
}

void mouseDragged() {
  // Permitir rotación con el mouse
  rotY += (mouseX - pmouseX) * 0.01;
  rotX += (mouseY - pmouseY) * 0.01;
}

void mouseWheel(MouseEvent event) {
  // Zoom con la rueda del mouse
  camZ += event.getCount() * 30;
}

// Crear estructura de hijos recursivamente
void crearHijos(ElementoBase padre, int nivelProfundidad) {
  // Detener recursión si alcanza la profundidad máxima
  if (nivelProfundidad >= nivelMaximoProfundidad) return;
  
  // Calcular dirección base para distribuir hijos uniformemente en el espacio
  float anguloBase = TWO_PI / numHijosDerivados;
  
  for (int i = 0; i < numHijosDerivados; i++) {
    // Calcular ángulo para este hijo específico
    float angulo = anguloBase * i;
    
    // Crear hijo con posición inicial del padre
    ElementoSeguidor hijo = new ElementoSeguidor(
      padre.posicion.copy(),
      padre.colorActual,
      shapeManager.getCurrentShape(),
      padre
    );
    
    // Añadir a la lista
    todosElementos.add(hijo);
    
    // Recursivamente crear hijos para este nuevo elemento
    crearHijos(hijo, nivelProfundidad + 1);
  }
}