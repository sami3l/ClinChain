class Config {
  /// If true, repositories use in-memory mock implementations (the app is runnable locally).
  /// When you have a real backend, set `useMock = false` and update `baseUrl`.
  final bool useMock;

  /// Base URL for real backend (used when useMock == false)
  final String baseUrl;

  Config({required this.useMock, required this.baseUrl});

  /// Default configuration for production backend
  factory Config.production() {
    return Config(
      useMock: false,
      baseUrl: 'http://192.168.11.102:8888', // Votre adresse IP WiFi
    );
  }

  /// Default configuration for development with mock data
  factory Config.development() {
    return Config(
      useMock: true,
      baseUrl: 'http://localhost:8888',
    );
  }
}
