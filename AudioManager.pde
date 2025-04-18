class AudioManager {
  SoundFile soundFile;
  FFT fft;
  AudioIn input;
  
  int bandas = 512;
  float[] spectrum;
  
  float nivelGraves;
  float nivelMedios;
  float nivelAgudos;
  
  float umbralGraves = 0.003;
  float umbralAgudos = 0.2;
  
  // Factores de sensibilidad independientes
  float factorSensibilidadGraves = 15.0;
  float factorSensibilidadMedios = 100.0;
  float factorSensibilidadAgudos = 300.0;
  
  boolean modoArchivoAudio = true;
  
  // Cache de resultados para mejorar rendimiento
  private float[] nivelCache = new float[3];
  private int frameUltimaActualizacion = -1;
  
  AudioManager(PApplet parent, String archivoAudio) {
    // Inicializar FFT
    fft = new FFT(parent, bandas);
    spectrum = new float[bandas];
    
    // Determinar si usar archivo de audio o entrada de micrófono
    if (archivoAudio != null && !archivoAudio.isEmpty()) {
      try {
        soundFile = new SoundFile(parent, archivoAudio);
        soundFile.loop();
        fft.input(soundFile);
        modoArchivoAudio = true;
      } catch (Exception e) {
        println("Error cargando archivo de audio: " + e.getMessage());
        inicializarMicrofono(parent);
      }
    } else {
      inicializarMicrofono(parent);
    }
  }
  
  private void inicializarMicrofono(PApplet parent) {
    // Usar entrada de micrófono si no hay archivo
    input = new AudioIn(parent, 0);
    input.start();
    fft.input(input);
    modoArchivoAudio = false;
  }
  
  void update() {
    // Análisis FFT
    fft.analyze(spectrum);
    
    // Calcular niveles por rangos de frecuencia con sensibilidades independientes
    nivelGraves = calcularNivelEnRango(0, bandas/6) * factorSensibilidadGraves;
    nivelMedios = calcularNivelEnRango(bandas/6, bandas/2) * factorSensibilidadMedios;
    nivelAgudos = calcularNivelEnRango(bandas/2, bandas-1) * factorSensibilidadAgudos;
  }
  
  float calcularNivelEnRango(int inicio, int fin) {
    float sum = 0;
    for (int i = inicio; i < fin; i++) {
      sum += spectrum[i];
    }
    return sum / (fin - inicio);
  }
  
  boolean hayGrave() {
    return nivelGraves > umbralGraves;
  }
  
  boolean hayAgudo() {
    return nivelAgudos > umbralAgudos;
  }
  
  float getNivelGraves() {
    actualizarCacheSiNecesario();
    return nivelCache[0];
  }
  
  float getNivelMedios() {
    actualizarCacheSiNecesario();
    return nivelCache[1];
  }
  
  float getNivelAgudos() {
    actualizarCacheSiNecesario();
    return nivelCache[2];
  }
  
  // Método para actualizar el cache solo cuando es necesario
  private void actualizarCacheSiNecesario() {
    if (frameUltimaActualizacion != frameCount) {
      nivelCache[0] = nivelGraves;
      nivelCache[1] = nivelMedios;
      nivelCache[2] = nivelAgudos;
      frameUltimaActualizacion = frameCount;
    }
  }
  
  // Métodos para ajustar la sensibilidad de graves
  void aumentarSensibilidadGraves() {
    factorSensibilidadGraves += 0.2;
    println("Sensibilidad Graves: " + factorSensibilidadGraves);
  }
  
  void disminuirSensibilidadGraves() {
    factorSensibilidadGraves = max(0.2, factorSensibilidadGraves - 0.2);
    println("Sensibilidad Graves: " + factorSensibilidadGraves);
  }
  
  // Métodos para ajustar la sensibilidad de medios
  void aumentarSensibilidadMedios() {
    factorSensibilidadMedios += 0.2;
    println("Sensibilidad Medios: " + factorSensibilidadMedios);
  }
  
  void disminuirSensibilidadMedios() {
    factorSensibilidadMedios = max(0.2, factorSensibilidadMedios - 0.2);
    println("Sensibilidad Medios: " + factorSensibilidadMedios);
  }
  
  // Métodos para ajustar la sensibilidad de agudos
  void aumentarSensibilidadAgudos() {
    factorSensibilidadAgudos += 0.2;
    println("Sensibilidad Agudos: " + factorSensibilidadAgudos);
  }
  
  void disminuirSensibilidadAgudos() {
    factorSensibilidadAgudos = max(0.2, factorSensibilidadAgudos - 0.2);
    println("Sensibilidad Agudos: " + factorSensibilidadAgudos);
  }
  
  // Métodos getter para las sensibilidades
  float getSensibilidadGraves() {
    return factorSensibilidadGraves;
  }
  
  float getSensibilidadMedios() {
    return factorSensibilidadMedios;
  }
  
  float getSensibilidadAgudos() {
    return factorSensibilidadAgudos;
  }
  
  // Métodos obsoletos, mantenidos para compatibilidad
  void aumentarSensibilidad() {
    aumentarSensibilidadGraves();
    aumentarSensibilidadMedios();
    aumentarSensibilidadAgudos();
  }
  
  void disminuirSensibilidad() {
    disminuirSensibilidadGraves();
    disminuirSensibilidadMedios();
    disminuirSensibilidadAgudos();
  }
  
  float getSensibilidad() {
    // Promedio de las tres sensibilidades
    return (factorSensibilidadGraves + factorSensibilidadMedios + factorSensibilidadAgudos) / 3.0;
  }
  
  // Método unificado para ajustar sensibilidad
  void ajustarSensibilidad(int tipo, boolean aumentar) {
    float ajuste = aumentar ? 0.2f : -0.2f;
    
    switch(tipo) {
      case 0: // Graves
        factorSensibilidadGraves = max(0.2, factorSensibilidadGraves + ajuste);
        println("Sensibilidad Graves: " + factorSensibilidadGraves);
        break;
      case 1: // Medios
        factorSensibilidadMedios = max(0.2, factorSensibilidadMedios + ajuste);
        println("Sensibilidad Medios: " + factorSensibilidadMedios);
        break;
      case 2: // Agudos
        factorSensibilidadAgudos = max(0.2, factorSensibilidadAgudos + ajuste);
        println("Sensibilidad Agudos: " + factorSensibilidadAgudos);
        break;
    }
  }
}
