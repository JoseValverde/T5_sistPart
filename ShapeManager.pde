class ShapeManager {
  PShape currentShape;
  int shapeType = 0; // 0: polígono, 1: obj, 2: primitiva
  int numLados = 20;  // Cambiado de 6 a 20 para usar icosaedro como predeterminado
  private PShape[] shapeCache;
  
  ShapeManager() {
    // Inicializar cache
    shapeCache = new PShape[21]; // Cache para 3-20 lados + formas especiales
    createDefaultShape();
  }
  
  void createDefaultShape() {
    // Usar el número de lados configurado
    switch(numLados) {
      case 4:
        currentShape = createTetrahedron(20);
        break;
      case 8:
        currentShape = createOctahedron(20);
        break;
      case 20:
        currentShape = createIcosahedron(20);
        break;
      default:
        // Crear un prisma con el número de lados especificado
        currentShape = createPrisma(20, numLados);
    }
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
    // Usar cache si ya existe
    int cacheIndex = (numLados >= 3 && numLados <= 20) ? numLados : 0;
    
    if (shapeCache[cacheIndex] == null) {
      PShape newShape;
      
      switch(numLados) {
        case 4: newShape = createTetrahedron(20); break;
        case 8: newShape = createOctahedron(20); break;
        case 20: newShape = createIcosahedron(20); break;
        default: newShape = createPrisma(20, numLados); break;
      }
      
      shapeCache[cacheIndex] = newShape;
    }
    
    return shapeCache[cacheIndex];
  }
  
  // Método para cambiar el número de lados
  void setNumLados(int lados) {
    this.numLados = lados;
    currentShape = getCurrentShape();
  }
  
  // Crear un prisma con número variable de lados (base poligonal)
  PShape createPrisma(float size, int lados) {
    PShape shape = createShape(GROUP);
    
    // Crear las bases del prisma (polígonos)
    for (int base = 0; base < 2; base++) {
      PShape poligono = createShape();
      poligono.beginShape();
      if (base == 0) {
        poligono.fill(255);  // Base superior
      } else {
        poligono.fill(200);  // Base inferior
      }
      
      float h = (base == 0) ? size/2 : -size/2;  // Altura
      
      // Crear vértices del polígono base
      for (int i = 0; i < lados; i++) {
        float angulo = TWO_PI * i / lados;
        float x = sin(angulo) * size/2;
        float z = cos(angulo) * size/2;
        poligono.vertex(x, h, z);
      }
      poligono.endShape(CLOSE);
      shape.addChild(poligono);
    }
    
    // Crear los lados del prisma (rectángulos)
    for (int i = 0; i < lados; i++) {
      PShape lado = createShape();
      lado.beginShape(QUADS);
      lado.fill(220);
      
      float angulo1 = TWO_PI * i / lados;
      float angulo2 = TWO_PI * ((i+1) % lados) / lados;
      
      float x1 = sin(angulo1) * size/2;
      float z1 = cos(angulo1) * size/2;
      
      float x2 = sin(angulo2) * size/2;
      float z2 = cos(angulo2) * size/2;
      
      lado.vertex(x1, size/2, z1);  // Superior 1
      lado.vertex(x2, size/2, z2);  // Superior 2
      lado.vertex(x2, -size/2, z2); // Inferior 2
      lado.vertex(x1, -size/2, z1); // Inferior 1
      
      lado.endShape();
      shape.addChild(lado);
    }
    
    return shape;
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
  
  // Crear un tetraedro (4 caras triangulares)
  PShape createTetrahedron(float radius) {
    PShape shape = createShape();
    shape.beginShape(TRIANGLES);
    
    // Vértices del tetraedro regular
    float a = radius * 2;  // Factor de escala para el tamaño deseado
    
    // Cuatro vértices del tetraedro
    PVector v1 = new PVector(0, 0, a);
    PVector v2 = new PVector(0, 2*a/sqrt(6), -a/3);
    PVector v3 = new PVector(-a/sqrt(3), -a/sqrt(6), -a/3);
    PVector v4 = new PVector(a/sqrt(3), -a/sqrt(6), -a/3);
    
    // Normalizar para que todas las aristas sean iguales
    v1.normalize().mult(radius);
    v2.normalize().mult(radius);
    v3.normalize().mult(radius);
    v4.normalize().mult(radius);
    
    // Cara 1
    shape.vertex(v1.x, v1.y, v1.z);
    shape.vertex(v3.x, v3.y, v3.z);
    shape.vertex(v2.x, v2.y, v2.z);
    
    // Cara 2
    shape.vertex(v1.x, v1.y, v1.z);
    shape.vertex(v2.x, v2.y, v2.z);
    shape.vertex(v4.x, v4.y, v4.z);
    
    // Cara 3
    shape.vertex(v1.x, v1.y, v1.z);
    shape.vertex(v4.x, v4.y, v4.z);
    shape.vertex(v3.x, v3.y, v3.z);
    
    // Cara 4
    shape.vertex(v2.x, v2.y, v2.z);
    shape.vertex(v3.x, v3.y, v3.z);
    shape.vertex(v4.x, v4.y, v4.z);
    
    shape.endShape();
    return shape;
  }
  
  // Crear un octaedro (8 caras triangulares)
  PShape createOctahedron(float radius) {
    PShape shape = createShape();
    shape.beginShape(TRIANGLES);
    
    // Seis vértices del octaedro
    PVector v1 = new PVector(radius, 0, 0);  // +x
    PVector v2 = new PVector(-radius, 0, 0); // -x
    PVector v3 = new PVector(0, radius, 0);  // +y
    PVector v4 = new PVector(0, -radius, 0); // -y
    PVector v5 = new PVector(0, 0, radius);  // +z
    PVector v6 = new PVector(0, 0, -radius); // -z
    
    // 8 caras triangulares
    // Cara superior frontal
    shape.vertex(v3.x, v3.y, v3.z);
    shape.vertex(v1.x, v1.y, v1.z);
    shape.vertex(v5.x, v5.y, v5.z);
    
    // Cara superior trasera
    shape.vertex(v3.x, v3.y, v3.z);
    shape.vertex(v5.x, v5.y, v5.z);
    shape.vertex(v2.x, v2.y, v2.z);
    
    // Cara superior izquierda
    shape.vertex(v3.x, v3.y, v3.z);
    shape.vertex(v2.x, v2.y, v2.z);
    shape.vertex(v6.x, v6.y, v6.z);
    
    // Cara superior derecha
    shape.vertex(v3.x, v3.y, v3.z);
    shape.vertex(v6.x, v6.y, v6.z);
    shape.vertex(v1.x, v1.y, v1.z);
    
    // Cara inferior frontal
    shape.vertex(v4.x, v4.y, v4.z);
    shape.vertex(v5.x, v5.y, v5.z);
    shape.vertex(v1.x, v1.y, v1.z);
    
    // Cara inferior trasera
    shape.vertex(v4.x, v4.y, v4.z);
    shape.vertex(v2.x, v2.y, v2.z);
    shape.vertex(v5.x, v5.y, v5.z);
    
    // Cara inferior izquierda
    shape.vertex(v4.x, v4.y, v4.z);
    shape.vertex(v6.x, v6.y, v6.z);
    shape.vertex(v2.x, v2.y, v2.z);
    
    // Cara inferior derecha
    shape.vertex(v4.x, v4.y, v4.z);
    shape.vertex(v1.x, v1.y, v1.z);
    shape.vertex(v6.x, v6.y, v6.z);
    
    shape.endShape();
    return shape;
  }
}
