class ColorPalette {
  color primary100 = #50B2C0;
  color primary200 = #FEEFDD;
  color primary300 = #FAAA8D;
  color accent100 = #FF4000;
  color accent200 = #50B2C0;
  color text100 = #000000;
  color text200 = #2c2c2c;
  color bg100 = #F7EEDD;
  color bg200 = #ede4d3;
  color bg300 = #c4bcab;
  
  color[] colorArray;
  
  ColorPalette() {
    // Inicializar array de colores (excluyendo colores de fondo y texto)
    colorArray = new color[] {
      primary100, primary200, primary300,
      accent100, accent200
    };
  }
  
  color getRandomColor() {
    int index = floor(random(colorArray.length));
    return colorArray[index];
  }
  
  color getColorPosterior(color colorBase, int pasos) {
    int idxBase = 0;
    boolean encontrado = false;
    
    for (int i = 0; i < colorArray.length; i++) {
      if (colorArray[i] == colorBase) {
        idxBase = i;
        encontrado = true;
        break;
      }
    }
    
    if (!encontrado) {
      idxBase = 0;
    }
    
    int offset = max(1, pasos);
    int idxNuevo = (idxBase + offset) % colorArray.length;
    return colorArray[idxNuevo];
  }
  
  // Método específico para obtener el color accent200 para el elemento principal
  color getElementoPrincipalColor() {
    return accent200;
  }
  
  color getBgColor() {
    return text100 ; // Corregido: antes devolvía text100
  }
  
  color getTextColor() {
    return text100;
  }
}
