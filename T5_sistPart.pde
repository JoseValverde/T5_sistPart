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
int nivelMaximoProfundidad = 2; // Cuántas generaciones de hijos permitir

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
}

void draw() {
  background(colorPalette.getBgColor());
  
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

void keyPressed() {
  if (key == 'd' || key == 'D') {
    debugMode = !debugMode;
  }
}

// Crear estructura de hijos recursivamente
void crearHijos(ElementoBase padre, int nivelProfundidad) {
  // Detener recursión si alcanza la profundidad máxima
  if (nivelProfundidad >= nivelMaximoProfundidad) return;
  
  for (int i = 0; i < numHijosDerivados; i++) {
    ElementoSeguidor hijo = new ElementoSeguidor(
      padre.posicion.copy(),
      padre.colorActual,  // Corregido: 'color' -> 'colorActual'
      shapeManager.getCurrentShape(),
      padre
    );
    todosElementos.add(hijo);
    
    // Recursivamente crear hijos para este nuevo elemento
    crearHijos(hijo, nivelProfundidad + 1);
  }
}