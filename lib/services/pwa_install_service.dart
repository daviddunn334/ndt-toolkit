import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_download.dart';

/// Service to handle PWA installation prompts and checks
class PWAInstallService {
  /// Check if the app can be installed (is web, mobile, and not already installed)
  static bool canShowInstallButton() {
    if (!kIsWeb) return false;
    
    // Check if already dismissed
    final dismissed = getLocalStorageValue('mobile_install_dismissed');
    if (dismissed == 'true') return false;
    
    // Check if already installed (running in standalone mode)
    final isStandalone = matchMediaQuery('(display-mode: standalone)');
    if (isStandalone) return false;
    
    // Check if on mobile
    return isMobile();
  }

  /// Check if on mobile device
  static bool isMobile() {
    if (!kIsWeb) return false;
    final userAgent = getBrowserUserAgent().toLowerCase();
    return userAgent.contains('mobile') || 
           userAgent.contains('android') || 
           userAgent.contains('iphone') || 
           userAgent.contains('ipad');
  }

  /// Mark install prompt as dismissed
  static void dismissInstall() {
    if (!kIsWeb) return;
    setLocalStorageValue('mobile_install_dismissed', 'true');
  }

  /// Mark app as installed
  static void markInstalled() {
    if (!kIsWeb) return;
    setLocalStorageValue('pwa_installed', 'true');
  }
}
