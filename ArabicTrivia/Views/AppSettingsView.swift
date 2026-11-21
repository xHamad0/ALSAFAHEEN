import SwiftUI

/// شاشة إعدادات التطبيق والصوت والتحكم
public struct AppSettingsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @StateObject private var tracker = UsedQuestionsTracker.shared
    @State private var showResetDialog: Bool = false
    @State private var showResetSuccessAlert: Bool = false
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // إعدادات الصوت والتأثيرات
                    VStack(alignment: .leading, spacing: 14) {
                        Text("الصوت والمؤثرات")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.goldPrimary)
                        
                        Toggle("تفعيل المؤثرات الصوتية", isOn: $dataManager.isSoundEnabled)
                            .tint(AppTheme.goldPrimary)
                            .onChange(of: dataManager.isSoundEnabled) { val in
                                AudioService.shared.updateSettings(isMuted: !val, volume: dataManager.soundVolume)
                                dataManager.saveSettings()
                            }
                        
                        if dataManager.isSoundEnabled {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("مستوى الصوت")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Text("\(Int(dataManager.soundVolume * 100))%")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.goldPrimary)
                                }
                                
                                Slider(value: $dataManager.soundVolume, in: 0.1...1.0, step: 0.05)
                                    .tint(AppTheme.goldPrimary)
                                    .onChange(of: dataManager.soundVolume) { val in
                                        AudioService.shared.updateSettings(isMuted: !dataManager.isSoundEnabled, volume: val)
                                        dataManager.saveSettings()
                                    }
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        Toggle("الاهتزاز والتغذية اللمسية (Haptics)", isOn: $dataManager.isHapticsEnabled)
                            .tint(AppTheme.goldPrimary)
                            .onChange(of: dataManager.isHapticsEnabled) { val in
                                HapticService.shared.setEnabled(val)
                                dataManager.saveSettings()
                            }
                    }
                    .padding(16)
                    .premiumCard()
                    
                    // إدارة سجل منع التكرار
                    VStack(alignment: .leading, spacing: 12) {
                        Text("سجل منع تكرار الأسئلة")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.goldPrimary)
                        
                        Text("يحفظ التطبيق الأسئلة المستخدمة في المباريات السابقة محلياً لمنع تكرارها. عدد الأسئلة المستهلكة حالياً: \(tracker.totalUsedCount) سؤال.")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                        
                        Button(action: {
                            showResetDialog = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                Text("إعادة ضبط سجل الأسئلة المستخدمة")
                                    .fontWeight(.bold)
                            }
                            .font(.subheadline)
                            .foregroundColor(AppTheme.error)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.error.opacity(0.15))
                            .cornerRadius(14)
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .premiumCard()
                    
                    // معلومات التطبيق
                    VStack(spacing: 8) {
                        Text("لعبة السَّــفَّاحِــين للمسابقات الجماعية")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("الإصدار 1.0.0 • بنية محلية دون إنترنت • صراع العقول")
                            .font(.caption2)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(16)
                }
                .padding(16)
            }
        }
        .navigationTitle("الإعدادات")
        .navigationBarTitleDisplayMode(.inline)
        .alert("إعادة ضبط الأسئلة", isPresented: $showResetDialog) {
            Button("تأكيد التصفير", role: .destructive) {
                tracker.resetHistory()
                showResetSuccessAlert = true
            }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("هل أنت متأكد من رغبتك في تصفير سجل الأسئلة؟ ستصبح جميع الأسئلة متاحة من جديد.")
        }
        .alert("تمت العملية بنجاح", isPresented: $showResetSuccessAlert) {
            Button("حسناً", role: .cancel) {}
        } message: {
            Text("تمت إعادة ضبط سجل الأسئلة المستخدمة بنجاح.")
        }
    }
}
