class ColorPalette {
  color primary100 = #FF7F50;
  color primary200 = #dd6236;
  color primary300 = #8f1e00;
  color accent100 = #8B4513;
  color accent200 = #ffd299;
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
