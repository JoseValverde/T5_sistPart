import processing.sound.*;

// Variables globales
AudioManager audioManager;
ElementoPrincipal elementoPrincipal;
ArrayList<ElementoBase> todosElementos;
ColorPalette colorPalette;
ShapeManager shapeManager;
DebugManager debugManager;
boolean debugMode = false;

int numHijosDerivados =2;
int nivelMaximoProfundidad = 6; // Cuántas generaciones de hijos permitir

// Variables para control de cámara
float rotX = 0;
float rotY = 0;
float camZ = 0;
boolean rotateCam = false;

void setup() {
  size(700, 1000, P3D);
  
  // Inicializar paleta de colores
  colorPalette = new ColorPalette();
  
  // Inicializar gestor de formas
  shapeManager = new ShapeManager();
  
  // Inicializar audio manager
  audioManager = new AudioManager(this, "musica/nombre.mp3");
  
  // Crear elemento principal
  elementoPrincipal = new ElementoPrincipal(
    new PVector(width/2, height/2, 0),
    colorPalette.getElementoPrincipalColor(),  // Usar específicamente accent200
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
  
  // Inicializar valores de cámara
  rotX = 0;
  rotY = 0;
  camZ = 0;
  rotateCam = true;  // Activar rotación automática por defecto
}

void draw() {
  background(colorPalette.getBgColor());
  
  // INICIO DEL ENTORNO 3D
  pushMatrix();
  
  // Configuración de la cámara y luces para espacio 3D
  setupCamera();
  
  // Actualizar análisis de audio
  audioManager.update();
  
  // Verificar y reaccionar a cambios en audio
  if (audioManager.hayGrave()) {
    // Iniciar el cambio de dirección en cascada
    elementoPrincipal.señalizarCambioDireccion();
  }
  
  if (audioManager.hayAgudo()) {
    elementoPrincipal.cambiarColor(colorPalette.getRandomColor());
  }
  
  // Actualizar y mostrar todos los elementos
  for (ElementoBase elemento : todosElementos) {
    elemento.actualizar();
    elemento.mostrar();
  }
  
  // FIN DEL ENTORNO 3D
  popMatrix();
  
  // INICIO DEL ENTORNO 2D PARA DEBUG
  hint(DISABLE_DEPTH_TEST);  // Asegurar que el debug esté al frente
  camera();  // Resetear la cámara a 2D
  noLights();  // Desactivar luces para dibujo 2D
  
  // Mostrar debug si está activado
  if (debugMode) {
    debugManager.mostrar(elementoPrincipal, todosElementos.size(), audioManager);
  }
  
  hint(ENABLE_DEPTH_TEST);  // Restaurar comportamiento normal para el siguiente frame
}

// Configurar la cámara para seguir y enfocar al elemento principal
void setupCamera() {
  // Variables para controlar órbita de cámara
  float distanciaOrbital = 1500 - camZ;  // Distancia de la cámara al objetivo
  float xCam, yCam, zCam;
  
  // Si la rotación automática está activada, incrementar el ángulo
  if (rotateCam) {
    rotY += 0.005;  // Velocidad de rotación automática
  }
  
  // Calcular posición de la cámara en órbita
  xCam = elementoPrincipal.posicion.x + sin(rotY) * cos(rotX) * distanciaOrbital;
  yCam = elementoPrincipal.posicion.y + sin(rotX) * distanciaOrbital;
  zCam = elementoPrincipal.posicion.z + cos(rotY) * cos(rotX) * distanciaOrbital;
  
  // Configurar la cámara para mirar hacia el elemento principal
  camera(
    xCam, yCam, zCam,                               // Posición de la cámara
    elementoPrincipal.posicion.x,                   // Posición del objetivo (X)
    elementoPrincipal.posicion.y,                   // Posición del objetivo (Y)
    elementoPrincipal.posicion.z,                   // Posición del objetivo (Z)
    0, 1, 0                                         // Vector "arriba"
  );
  
  // Añadir luces
  ambientLight(60, 60, 60);
  directionalLight(100, 100, 100, 1, 1, -1);
  
  // Luz que sigue al elemento principal
  pointLight(80, 80, 80, 
    elementoPrincipal.posicion.x,
    elementoPrincipal.posicion.y, 
    elementoPrincipal.posicion.z
  );
}

void keyPressed() {
  if (key == 'd' || key == 'D') {
    debugMode = !debugMode;
  } 
  else if (key == 'r' || key == 'R') {
    rotateCam = !rotateCam;
  }
  // Simplificación de control de sensibilidad
  else if (key >= '1' && key <= '6') {
    int tipo = (key - '1') / 2;  // 0=graves, 1=medios, 2=agudos
    boolean aumentar = (key - '1') % 2 == 1; // Impar=aumentar
    audioManager.ajustarSensibilidad(tipo, aumentar);
  }
  // Control de formas - unificado
  else if (key == 'z' || key == 'Z' || key == '[') {
    int nuevoLados = max(3, shapeManager.numLados - 1);
    shapeManager.setNumLados(nuevoLados);
    actualizarTodasLasFormas();
  }
  else if (key == 'x' || key == 'X' || key == ']') {
    int nuevoLados = min(20, shapeManager.numLados + 1);
    shapeManager.setNumLados(nuevoLados);
    actualizarTodasLasFormas();
  }
  // Controles generales (mantener compatibilidad)
  else if (key == '+' || key == '=') {
    // Aumentar todas las sensibilidades
    audioManager.aumentarSensibilidad();
  }
  else if (key == '-' || key == '_') {
    // Disminuir todas las sensibilidades
    audioManager.disminuirSensibilidad();
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

// Crear estructura de hijos recursivamente - optimizado
void crearHijos(ElementoBase padre, int nivelProfundidad) {
  // Detener recursión si alcanza la profundidad máxima
  if (nivelProfundidad >= nivelMaximoProfundidad) return;
  
  // Obtener forma actual una sola vez
  PShape formaActual = shapeManager.getCurrentShape();
  
  for (int i = 0; i < numHijosDerivados; i++) {
    // Crear hijo con posición inicial del padre
    ElementoSeguidor hijo = new ElementoSeguidor(
      padre.posicion.copy(),
      padre.colorActual,
      formaActual, // Reutilizar la misma forma
      padre
    );
    
    todosElementos.add(hijo);
    crearHijos(hijo, nivelProfundidad + 1);
  }
}

// Método para actualizar la forma de todos los elementos
void actualizarTodasLasFormas() {
  PShape nuevaForma = shapeManager.getCurrentShape();
  
  for (ElementoBase elemento : todosElementos) {
    elemento.forma = nuevaForma;
  }
}