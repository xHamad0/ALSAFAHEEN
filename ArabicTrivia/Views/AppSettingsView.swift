import SwiftUI

/// شاشة الإعدادات وتضم بنك الأسئلة والإحصائيات وسجل المباريات وإعدادات الصوت
public struct AppSettingsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @StateObject private var tracker = UsedQuestionsTracker.shared
    @StateObject private var bankService = QuestionBankService.shared
    @State private var showResetDialog: Bool = false
    @State private var showResetSuccessAlert: Bool = false
    
    public var body: some View {
        ZStack {
            Color(hex: "#F3F4F6")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 18) {
                    // قسم بنك الأسئلة والإحصائيات والسجل (حسب طلب المستخدم)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("إدارة البنك والسجلات")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(Color(hex: "#B91C1C"))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            NavigationLink(destination: QuestionBankManagementView()) {
                                settingsNavCard(
                                    title: "بنك الأسئلة",
                                    subtitle: "\(bankService.totalQuestionsCount) سؤال • تصدير واستيراد",
                                    icon: "books.vertical.fill",
                                    color: Color(hex: "#EA580C")
                                )
                            }
                            
                            NavigationLink(destination: StatisticsView()) {
                                settingsNavCard(
                                    title: "الإحصائيات",
                                    subtitle: "أرقام الأداء والفرق",
                                    icon: "chart.bar.xaxis",
                                    color: Color(hex: "#0284C7")
                                )
                            }
                            
                            NavigationLink(destination: MatchHistoryView()) {
                                settingsNavCard(
                                    title: "سجل المباريات",
                                    subtitle: "\(dataManager.statistics.totalMatchesPlayed) مباراة مسجلة",
                                    icon: "clock.arrow.circlepath",
                                    color: Color(hex: "#7C3AED")
                                )
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // إعدادات الصوت والتأثيرات
                    VStack(alignment: .leading, spacing: 14) {
                        Text("الصوت والمؤثرات")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(Color(hex: "#EA580C"))
                        
                        Toggle("تفعيل المؤثرات الصوتية", isOn: $dataManager.isSoundEnabled)
                            .tint(Color(hex: "#EA580C"))
                            .foregroundColor(Color(hex: "#1F2937"))
                            .onChange(of: dataManager.isSoundEnabled) { val in
                                AudioService.shared.updateSettings(isMuted: !val, volume: dataManager.soundVolume)
                                dataManager.saveSettings()
                            }
                        
                        if dataManager.isSoundEnabled {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("مستوى الصوت")
                                        .font(.subheadline)
                                        .foregroundColor(Color(hex: "#4B5563"))
                                    Spacer()
                                    Text("\(Int(dataManager.soundVolume * 100))%")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#EA580C"))
                                }
                                
                                Slider(value: $dataManager.soundVolume, in: 0.1...1.0, step: 0.05)
                                    .tint(Color(hex: "#EA580C"))
                                    .onChange(of: dataManager.soundVolume) { val in
                                        AudioService.shared.updateSettings(isMuted: !dataManager.isSoundEnabled, volume: val)
                                        dataManager.saveSettings()
                                    }
                            }
                        }
                        
                        Divider()
                        
                        Toggle("الاهتزاز والتغذية اللمسية (Haptics)", isOn: $dataManager.isHapticsEnabled)
                            .tint(Color(hex: "#EA580C"))
                            .foregroundColor(Color(hex: "#1F2937"))
                            .onChange(of: dataManager.isHapticsEnabled) { val in
                                HapticService.shared.setEnabled(val)
                                dataManager.saveSettings()
                            }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // إدارة سجل منع التكرار
                    VStack(alignment: .leading, spacing: 12) {
                        Text("سجل منع تكرار الأسئلة")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(Color(hex: "#B91C1C"))
                        
                        Text("يحفظ التطبيق الأسئلة المستخدمة في المباريات السابقة محلياً لمنع تكرارها. عدد الأسئلة المستهلكة حالياً: \(tracker.totalUsedCount) سؤال.")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#4B5563"))
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
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color(hex: "#DC2626"))
                            .cornerRadius(14)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // معلومات التطبيق
                    Text("لعبة السفاحين للمسابقات الجماعية • الإصدار 1.0.0 • يعمل دون إنترنت")
                        .font(.caption2)
                        .foregroundColor(Color(hex: "#6B7280"))
                        .padding(.bottom, 10)
                }
                .padding(16)
            }
        }
        .navigationTitle("الإعدادات وبنك الأسئلة")
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
    
    private func settingsNavCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.black)
                .foregroundColor(Color(hex: "#1F2937"))
            
            Text(subtitle)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: "#6B7280"))
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#F9FAFB"))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
}
