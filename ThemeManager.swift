import UIKit

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max"
        case .dark:   return "moon"
        }
    }

    var title: String {
        switch self {
        case .system: return "Системная"
        case .light:  return "Светлая"
        case .dark:   return "Тёмная"
        }
    }
}

final class ThemeManager {
    static let shared = ThemeManager()
    private init() {}

    private let key = "app.theme.selection"

    var current: AppTheme {
        get {
            if let raw = UserDefaults.standard.string(forKey: key), let t = AppTheme(rawValue: raw) {
                return t
            }
            return .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }

    func apply(to window: UIWindow?) {
        guard let window = window else { return }
        switch current {
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        }
        window.subviews.forEach { $0.setNeedsLayout(); $0.setNeedsDisplay() }
    }
}
