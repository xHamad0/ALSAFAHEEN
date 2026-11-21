import SwiftUI

/// شاشة إعدادات المباراة النهائية قبل الانطلاق
public struct GameSettingsView: View {
    @ObservedObject var setupViewModel: SetupGameViewModel
    @State private var navigateToGamePlay: Bool = false
    @State private var createdSession: GameSession? = nil
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // عدد الجولات
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "flag.checkered")
                                .foregroundColor(AppTheme.goldPrimary)
                            Text("عدد الجولات:")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        HStack(spacing: 10) {
                            ForEach(setupViewModel.roundOptions, id: \.self) { r in
                                Button(action: {
                                    setupViewModel.totalRounds = r
                                }) {
                                    Text("\(r)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(setupViewModel.totalRounds == r ? .black : AppTheme.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(setupViewModel.totalRounds == r ? AppTheme.goldGradient : LinearGradient(colors: [AppTheme.bgSecondary], startPoint: .top, endPoint: .bottom))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(setupViewModel.totalRounds == r ? AppTheme.goldPrimary : Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    .padding(16)
                    .premiumCard()
                    
                    // مدة الإجابة لكل سؤال
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(AppTheme.goldPrimary)
                            Text("مدة الإجابة للسؤال (بالثواني):")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(setupViewModel.timeOptions, id: \.self) { t in
                                Button(action: {
                                    setupViewModel.timeLimitSeconds = t
                                }) {
                                    Text("\(t) ث")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(setupViewModel.timeLimitSeconds == t ? .black : AppTheme.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(setupViewModel.timeLimitSeconds == t ? AppTheme.goldGradient : LinearGradient(colors: [AppTheme.bgSecondary], startPoint: .top, endPoint: .bottom))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(setupViewModel.timeLimitSeconds == t ? AppTheme.goldPrimary : Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    .padding(16)
                    .premiumCard()
                    
                    // نظام النقاط والصعوبة التفاعلي الجديد (100 - 500)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(AppTheme.goldPrimary)
                            Text("نظام النقاط المعتمد:")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.goldPrimary)
                        }
                        
                        Text("في كل جولة، يختار الفريق قيمة السؤال من اللوحة (100 | 200 | 300 | 400 | 500) حسب مستوى التحدي المطلوب.")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .premiumCard()
                    
                    // خيارات إضافية
                    VStack(spacing: 14) {
                        Toggle(isOn: $setupViewModel.isRandomCategoryDistribution) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("توزيع عشوائي للتصنيفات")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("يختار التطبيق تصنيف السؤال عشوائياً لكل فريق")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .tint(AppTheme.goldPrimary)
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        Toggle(isOn: $setupViewModel.allowStealQuestion) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("سرقة السؤال بعد الخطأ")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("إتاحة الفرصة للمنافس للإجابة وسرقة النقاط عند خطأ الفريق")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .tint(AppTheme.goldPrimary)
                    }
                    .padding(16)
                    .premiumCard()
                    
                    // زر بدء التحدي والمباراة
                    Button(action: {
                        createdSession = setupViewModel.createGameSession()
                        navigateToGamePlay = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text("انطلاق المباراة الآن ⚔️")
                                .fontWeight(.black)
                        }
                        .font(.title3)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.goldGradient)
                        .cornerRadius(18)
                        .shadow(color: AppTheme.goldPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 10)
                    .navigationDestination(isPresented: $navigateToGamePlay) {
                        if let session = createdSession {
                            GamePlayView(session: session)
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("إعدادات المباراة")
        .navigationBarTitleDisplayMode(.inline)
    }
}
