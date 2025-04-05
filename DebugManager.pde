class DebugManager {
  
  void mostrar(ElementoPrincipal ep, int elementosTotal, AudioManager audio) {
    pushStyle();
    
    // Fondo semitransparente para sección debug
    fill(0, 150);
    rectMode(CORNER);
    rect(10, 10, 300, 200);
    
    // Texto debug
    fill(255);
    textAlign(LEFT);
    textSize(14);
    
    // Datos del elemento principal
    text("DATOS ELEMENTO PRINCIPAL (EP):", 20, 30);
    text(String.format("Posición: X=%5.1f, Y=%5.1f, Z=%5.1f", 
      ep.posicion.x, ep.posicion.y, ep.posicion.z), 20, 50);
      
    // Color en RGB
    int r = (ep.colorActual >> 16) & 0xFF;
    int g = (ep.colorActual >> 8) & 0xFF;
    int b = ep.colorActual & 0xFF;
    text(String.format("Color: R=%d, G=%d, B=%d", r, g, b), 20, 70);
    
    // Número total de elementos
    text("Número de elementos: " + elementosTotal, 20, 90);
    
    // Información de audio
    text("AUDIO:", 20, 120);
    
    // Barras de niveles
    mostrarBarraAudio("Graves", audio.getNivelGraves(), 20, 140, 255, 0, 0);
    mostrarBarraAudio("Medios", audio.getNivelMedios(), 20, 160, 0, 255, 0);
    mostrarBarraAudio("Agudos", audio.getNivelAgudos(), 20, 180, 0, 0, 255);
    
    popStyle();
  }
  
  void mostrarBarraAudio(String etiqueta, float valor, float x, float y, int r, int g, int b) {
    // Normalizar valor entre 0 y 1
    valor = constrain(valor, 0, 1);
    
    // Dibujar etiqueta
    fill(255);
    text(etiqueta + ": " + nf(valor, 1, 2), x, y);
    
    // Dibujar barra de progreso
    stroke(255);
    noFill();
    rect(x + 100, y - 12, 150, 15);
    
    fill(r, g, b);
    noStroke();
    rect(x + 100, y - 12, 150 * valor, 15);
  }
}
