import UIKit

/// خدمة التغذية اللمسية التفاعلية (Haptics)
public final class HapticService {
    public static let shared = HapticService()
    
    private var isEnabled: Bool = true
    
    private init() {}
    
    public func setEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
    }
    
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    public func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
