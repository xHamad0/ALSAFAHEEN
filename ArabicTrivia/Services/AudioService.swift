import Foundation
import AudioToolbox
import AVFoundation

/// خدمة المؤثرات الصوتية للألعاب
public final class AudioService {
    public static let shared = AudioService()
    
    private var isMuted: Bool = false
    private var volume: Float = 0.8
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    public func updateSettings(isMuted: Bool, volume: Float) {
        self.isMuted = isMuted
        self.volume = volume
    }
    
    /// صوت الإجابة الصحيحة
    public func playCorrectSound() {
        guard !isMuted else { return }
        // استخدام نغمة النظام الصوتية للإنجاز المبهج (ID: 1025 أو 1001)
        AudioServicesPlaySystemSound(1025)
    }
    
    /// صوت الإجابة الخاطئة
    public func playWrongSound() {
        guard !isMuted else { return }
        // نغمة التنبيه للخطأ (ID: 1053 أو 1073)
        AudioServicesPlaySystemSound(1053)
    }
    
    /// صوت دقات المؤقت عند اقتراب النهاية
    public func playTimerTickSound() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1103)
    }
    
    /// صوت انتهاء الوقت
    public func playTimeOutSound() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1052)
    }
    
    /// صوت الاحتفال بالفوز في نهاية المباراة
    public func playVictorySound() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1028)
    }
    
    /// صوت تفعيل وسيلة المساعدة
    public func playLifelineSound() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1054)
    }
}
