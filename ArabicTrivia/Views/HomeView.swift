import SwiftUI

/// الشاشة الرئيسية لتطبيق «سِـجَـال»
public struct HomeView: View {
    @ObservedObject var dataManager = DataManager.shared
    @StateObject var bankService = QuestionBankService.shared
    @StateObject var setupViewModel = SetupGameViewModel()
    
    @State private var navigateToResumeMatch: Bool = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // ترويسة التطبيق والهوية الأصلية
                        brandHeader
                        
                        // زر استكمال المباراة السابقة إن وجدت
                        if let activeSession = dataManager.savedActiveSession {
                            resumeMatchCard(session: activeSession)
                        }
                        
                        // الزر الأساسي: بدء مباراة جديدة
                        NavigationLink(destination: TeamSetupView(setupViewModel: setupViewModel)) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("بدء مباراة جديدة")
                                        .font(.title3)
                                        .fontWeight(.black)
                                    Text("تحدي بين فريقين على جهاز واحد")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                Spacer()
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(AppTheme.goldGradient)
                            .cornerRadius(20)
                            .shadow(color: AppTheme.goldGlow.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        
                        // شريط الإحصائيات السريع
                        quickStatsBar
                        
                        // أقسام التطبيق الرئيسية (بنك الأسئلة، الإحصائيات، السجل، الإعدادات)
                        mainFeaturesGrid
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToResumeMatch) {
                if let session = dataManager.savedActiveSession {
                    GamePlayView(session: session)
                }
            }
        }
    }
    
    // MARK: - Brand Header
    private var brandHeader: some View {
        VStack(spacing: 12) {
            SaffahinLogoView(size: 96, isAnimated: true)
            
            Text("السَّــفَّاحِــين")
                .font(.system(size: 38, weight: .black, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#FCA5A5"), Color(hex: "#EF4444"), Color(hex: "#D4AF37")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "#DC2626").opacity(0.4), radius: 8, x: 0, y: 3)
            
            Text("حلبة المسابقات والتحديات بين الفرق")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Resume Match Card
    private func resumeMatchCard(session: GameSession) -> some View {
        Button(action: {
            navigateToResumeMatch = true
        }) {
            HStack(spacing: 14) {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.title)
                    .foregroundColor(AppTheme.goldPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("استكمال المباراة الجارية")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("\(session.team1.name) (\(session.team1.score)) vs \(session.team2.name) (\(session.team2.score))")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Text("استئناف")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.goldPrimary)
                    .cornerRadius(12)
            }
            .padding(14)
            .background(AppTheme.bgCardElevated)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.goldPrimary.opacity(0.4), lineWidth: 1.5)
            )
        }
    }
    
    // MARK: - Quick Stats Bar
    private var quickStatsBar: some View {
        HStack(spacing: 12) {
            statBadge(title: "الأسئلة بالبنك", value: "\(bankService.totalQuestionsCount)", icon: "tray.full.fill", color: AppTheme.info)
            statBadge(title: "المباريات الملعوبة", value: "\(dataManager.statistics.totalMatchesPlayed)", icon: "gamecontroller.fill", color: AppTheme.goldPrimary)
            statBadge(title: "التصنيفات", value: "\(QuestionCategory.allCases.count)", icon: "square.grid.2x2.fill", color: AppTheme.success)
        }
    }
    
    private func statBadge(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(AppTheme.textPrimary)
                Text(title)
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.bgCard)
        .cornerRadius(14)
    }
    
    // MARK: - Main Features Grid
    private var mainFeaturesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            NavigationLink(destination: QuestionBankManagementView()) {
                featureCard(title: "بنك الأسئلة", subtitle: "إدارة واستيراد JSON", icon: "books.vertical.fill", color: Color(hex: "#10B981"))
            }
            
            NavigationLink(destination: StatisticsView()) {
                featureCard(title: "الإحصائيات", subtitle: "أرقام الأداء والفرق", icon: "chart.bar.xaxis", color: Color(hex: "#3B82F6"))
            }
            
            NavigationLink(destination: MatchHistoryView()) {
                featureCard(title: "سجل المباريات", subtitle: "تاريخ المواجهات السابقة", icon: "clock.arrow.circlepath", color: Color(hex: "#8B5CF6"))
            }
            
            NavigationLink(destination: AppSettingsView()) {
                featureCard(title: "الإعدادات", subtitle: "الصوت وإعادة الضبط", icon: "gearshape.fill", color: Color(hex: "#F59E0B"))
            }
        }
    }
    
    private func featureCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.bgCard)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
