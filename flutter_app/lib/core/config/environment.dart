/// Environment configuration for different network scenarios
/// 
/// This allows the app to work in different environments:
/// - Local WiFi (same network as server)
/// - Mobile data / External network
/// - Cloud deployment
class Environment {
  // ============================================
  // CONFIGURATION - Change this based on your needs
  // ============================================
  
  /// Set to true when testing on same WiFi as server
  /// Set to false when testing from mobile data or external network
  static const bool useLocalNetwork = false;  // Changed for external access
  
  /// Your local network IP (when on same WiFi)
  static const String localIp = '192.168.18.199';
  
  /// Your public IP (when on mobile data or external network)
  /// Note: Requires port forwarding on router
  static const String publicIp = '154.57.197.59';
  
  /// Cloud deployment URL (if deployed to cloud)
  /// Example: 'https://your-app.railway.app'
  static const String? cloudUrl = null;
  
  /// Server port
  static const int port = 3000;
  
  // ============================================
  // AUTO-GENERATED URLs - Don't modify below
  // ============================================
  
  /// Get the appropriate base URL based on environment
  static String get baseUrl {
    if (cloudUrl != null) {
      return '$cloudUrl/api';
    }
    
    final ip = useLocalNetwork ? localIp : publicIp;
    return 'http://$ip:$port/api';
  }
  
  /// Get the appropriate socket URL based on environment
  static String get socketUrl {
    if (cloudUrl != null) {
      return cloudUrl!;
    }
    
    final ip = useLocalNetwork ? localIp : publicIp;
    return 'http://$ip:$port';
  }
  
  /// Get current environment name for debugging
  static String get environmentName {
    if (cloudUrl != null) return 'Cloud';
    if (useLocalNetwork) return 'Local WiFi';
    return 'External/Mobile Data';
  }
  
  /// Print current configuration (for debugging)
  static void printConfig() {
    print('🌐 Environment: $environmentName');
    print('📡 Base URL: $baseUrl');
    print('🔌 Socket URL: $socketUrl');
  }
}
