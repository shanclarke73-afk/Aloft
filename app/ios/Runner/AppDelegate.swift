import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    keepRecordsOutOfBackups()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Keeps the database and progress photos (everything in Application Support) out of iCloud
  /// Backup and computer backups: App Store guideline 5.1.3 says apps "may not store personal
  /// health information in iCloud". Set on every launch, since the flag can be lost if the
  /// folder is ever recreated. Backup files the person saves themselves live in Documents and
  /// are theirs to keep or delete.
  private func keepRecordsOutOfBackups() {
    let files = FileManager.default
    guard var folder = files.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
    try? files.createDirectory(at: folder, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? folder.setResourceValues(values)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
