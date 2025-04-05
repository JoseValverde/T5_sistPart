class ShapeManager {
  PShape currentShape;
  int shapeType = 0; // 0: polígono, 1: obj, 2: primitiva
  
  ShapeManager() {
    // Iniciar con un polígono 3D simple
    createDefaultShape();
  }
  
  void createDefaultShape() {
    // Crear un polígono 3D simple (icosaedro)
    currentShape = createIcosahedron(20);
  }
  
  void loadOBJ(String objPath) {
    try {
      currentShape = loadShape(objPath);
      shapeType = 1;
    } catch (Exception e) {
      println("Error cargando OBJ: " + e.getMessage());
      createDefaultShape();
    }
  }
  
  void setPrimitive(int type) {
    // type: 0=sphere, 1=box, 2=torus
    if (type == 0) {
      currentShape = createShape(SPHERE, 20);
    } else if (type == 1) {
      currentShape = createShape(BOX, 30, 30, 30);
    } else {
      // Crear un torus personalizado
      currentShape = createTorus(20, 10);
    }
    shapeType = 2;
  }
  
  PShape getCurrentShape() {
    return currentShape;
  }
  
  // Método para crear un icosaedro (polígono 3D de 20 caras)
  PShape createIcosahedron(float radius) {
    PShape shape = createShape();
    
    // Constante phi (proporción áurea)
    float phi = (1 + sqrt(5)) / 2;
    
    // Vértices de un icosaedro
    float[][] vertices = {
      {-1, phi, 0}, {1, phi, 0}, {-1, -phi, 0}, {1, -phi, 0},
      {0, -1, phi}, {0, 1, phi}, {0, -1, -phi}, {0, 1, -phi},
      {phi, 0, -1}, {phi, 0, 1}, {-phi, 0, -1}, {-phi, 0, 1}
    };
    
    // Caras del icosaedro
    int[][] faces = {
      {0, 11, 5}, {0, 5, 1}, {0, 1, 7}, {0, 7, 10}, {0, 10, 11},
      {1, 5, 9}, {5, 11, 4}, {11, 10, 2}, {10, 7, 6}, {7, 1, 8},
      {3, 9, 4}, {3, 4, 2}, {3, 2, 6}, {3, 6, 8}, {3, 8, 9},
      {4, 9, 5}, {2, 4, 11}, {6, 2, 10}, {8, 6, 7}, {9, 8, 1}
    };
    
    shape.beginShape(TRIANGLES);
    
    // Normalizar los vértices
    for (int i = 0; i < faces.length; i++) {
      for (int j = 0; j < 3; j++) {
        float[] v = vertices[faces[i][j]];
        float length = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
        float nx = v[0]/length * radius;
        float ny = v[1]/length * radius;
        float nz = v[2]/length * radius;
        shape.vertex(nx, ny, nz);
      }
    }
    
    shape.endShape();
    return shape;
  }
  
  // Método para crear un torus
  PShape createTorus(float outerRadius, float innerRadius) {
    PShape shape = createShape();
    shape.beginShape(TRIANGLE_STRIP);
    
    int detail = 30;
    for (int i = 0; i <= detail; i++) {
      float angle = TWO_PI * i / detail;
      for (int j = 0; j <= detail; j++) {
        float angleB = TWO_PI * j / detail;
        float x = (outerRadius + innerRadius * cos(angleB)) * cos(angle);
        float y = (outerRadius + innerRadius * cos(angleB)) * sin(angle);
        float z = innerRadius * sin(angleB);
        shape.vertex(x, y, z);
        
        float nextAngle = TWO_PI * (i + 1) / detail;
        float nx = (outerRadius + innerRadius * cos(angleB)) * cos(nextAngle);
        float ny = (outerRadius + innerRadius * cos(angleB)) * sin(nextAngle);
        shape.vertex(nx, ny, z);
      }
    }
    
    shape.endShape();
    return shape;
  }
}
