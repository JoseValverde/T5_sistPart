class AudioManager {
  SoundFile soundFile;
  FFT fft;
  AudioIn input;
  
  int bandas = 512;
  float[] spectrum;
  
  float nivelGraves;
  float nivelMedios;
  float nivelAgudos;
  
  float umbralGraves = 0.3;
  float umbralAgudos = 0.2;
  
  // Factores de sensibilidad independientes
  float factorSensibilidadGraves = 25.0;
  float factorSensibilidadMedios = 100.0;
  float factorSensibilidadAgudos = 300.0;
  
  boolean modoArchivoAudio = true;
  
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
    return nivelGraves;
  }
  
  float getNivelMedios() {
    return nivelMedios;
  }
  
  float getNivelAgudos() {
    return nivelAgudos;
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
}
