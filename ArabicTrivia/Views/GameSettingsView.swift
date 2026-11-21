import SwiftUI

/// شاشة إعدادات المباراة وتأكيد لوحة الـ 6 فئات
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
                    // ملخص الفئات الـ 6 الثابتة المختارة
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(AppTheme.success)
                            Text("الفئات الـ 6 المعتمدة للجولة:")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Array(setupViewModel.selectedCategories)) { cat in
                                HStack(spacing: 6) {
                                    Image(systemName: cat.iconName)
                                        .foregroundColor(cat.themeColor)
                                        .font(.caption)
                                    Text(cat.titleArabic)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppTheme.textPrimary)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(8)
                                .background(AppTheme.bgSecondary)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(16)
                    .premiumCard()
                    
                    // بطاقة توضيح اللوحة (6 فئات × 10 أسئلة = 60 سؤالاً)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(AppTheme.goldPrimary)
                            Text("نظام لوحة الجولة:")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.goldPrimary)
                        }
                        
                        Text("• اللوحة تحتوي على الفئات الـ 6 الثابتة للجميع.\n• الترتيب من 100 إلى 500 نقطة.\n• كل خانة تحتوي على سؤالين (10 أسئلة لكل فئة = 60 سؤالاً).\n• الفريق صاحب الدور يختار السؤال المطلوب من اللوحة.")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
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
                                        .background(setupViewModel.timeLimitSeconds == t ? AnyView(AppTheme.goldGradient) : AnyView(AppTheme.bgSecondary))
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
                    
                    // سرقة السؤال
                    VStack(spacing: 14) {
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
                    
                    // زر انطلاق المباراة
                    Button(action: {
                        createdSession = setupViewModel.createGameSession()
                        navigateToGamePlay = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text("انطلاق حلبة السفاحين ⚔️")
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
