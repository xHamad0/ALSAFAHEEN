import SwiftUI

/// شاشة اللعب الرئيسية بتصميم لوحة المسابقات (ترويسة برتقالية-حمراء + لوحة 6 فئات + شريط نتائج سفلي)
public struct GamePlayView: View {
    @StateObject public var viewModel: GamePlayViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showExitConfirmation: Bool = false
    
    public init(session: GameSession) {
        _viewModel = StateObject(wrappedValue: GamePlayViewModel(session: session))
    }
    
    public var body: some View {
        ZStack {
            // الخلفية الفاتحة المريحة للعين المطابقة للتصميم
            Color(hex: "#F3F4F6")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. الترويسة العلوية المتدرجة (أحمر قرمزي -> برتقالي)
                topHeaderBar
                
                // 2. المنطقة الوسطى (اللوحة أو السؤال أو كشف الإجابة)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        switch viewModel.session.phase {
                        case .boardSelection:
                            SixCategoryBoardView(viewModel: viewModel)
                                .padding(.top, 6)
                            
                        case .questionAnswering:
                            if let question = viewModel.session.currentQuestion,
                               let diff = viewModel.session.activeDifficulty {
                                // مؤقت السؤال الدائري
                                questionTimerBadge
                                    .padding(.top, 4)
                                
                                QuestionCardView(
                                    question: question,
                                    difficulty: diff,
                                    isDoublePoints: viewModel.session.isDoublePointsActive,
                                    eliminatedOptions: viewModel.session.eliminatedOptions,
                                    selectedOptionIndex: viewModel.selectedOptionIndex,
                                    answerInput: $viewModel.directAnswerInput,
                                    onSelectOption: { index in
                                        viewModel.submitMultipleChoiceAnswer(selectedIndex: index)
                                    },
                                    onSubmitDirectOrBlank: {
                                        viewModel.submitDirectOrBlankAnswer()
                                    },
                                    onManualVerify: { isCorrect in
                                        viewModel.verifyManualAnswer(isCorrect: isCorrect)
                                    }
                                )
                                
                                // زر تخطي السؤال
                                Button(action: {
                                    viewModel.skipQuestion()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "forward.fill")
                                        Text("تخطي السؤال")
                                    }
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "#4B5563"))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                                }
                            }
                            
                        case .answerRevealed:
                            AnswerRevealView(viewModel: viewModel)
                                .padding(.top, 8)
                            
                        case .tieBreakerPending:
                            tieBreakerCard
                                .padding(.top, 12)
                            
                        case .matchFinished:
                            FinalResultsView(session: viewModel.session) {
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                
                // 3. الشريط السفلي لنتائج الفريقين ووسائل المساعدة (يظهر دائماً أثناء المباراة)
                if viewModel.session.phase != .matchFinished {
                    bottomTeamsFooter
                }
            }
            
            // شاشة الإيقاف المؤقت
            if viewModel.session.isPaused {
                pauseOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $viewModel.showScoreEditSheet) {
            ScoreEditSheetView(viewModel: viewModel)
        }
        .alert(isPresented: $viewModel.noQuestionsAvailableAlert) {
            Alert(
                title: Text("تنبيه"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("حسناً")) {
                    viewModel.session.phase = .boardSelection
                }
            )
        }
        .confirmationDialog("إنهاء أو تعليق المباراة", isPresented: $showExitConfirmation, titleVisibility: .visible) {
            Button("إنهاء وحفظ النتيجة النهائية", role: .destructive) {
                viewModel.finishMatch()
            }
            Button("الخروج واستكمال المباراة لاحقاً") {
                dismiss()
            }
            Button("إلغاء", role: .cancel) {}
        }
    }
    
    // MARK: - 1. الترويسة العلوية (مطابقة للتصميم المرجعي)
    private var topHeaderBar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                // الجانب الأيمن (RTL): شارة الدور القابلة للتبديل
                Button(action: {
                    viewModel.switchTurn()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 10, weight: .bold))
                        Text("دور فريق: \(viewModel.session.currentTeam.name)")
                            .font(.system(size: 11, weight: .bold))
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.16))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.55), lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                
                Spacer()
                
                // العنوان في المنتصف
                Text("السفاحين")
                    .font(.system(size: 19, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                
                Spacer()
                
                // الجانب الأيسر (RTL): أزرار التحكم (الرجوع للوحة / إيقاف / خروج)
                HStack(spacing: 10) {
                    if viewModel.session.phase == .questionAnswering {
                        Button(action: { viewModel.returnToBoard() }) {
                            HStack(spacing: 3) {
                                Image(systemName: "square.grid.2x2.fill")
                                Text("اللوحة")
                            }
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.18))
                            .cornerRadius(8)
                        }
                    }
                    
                    Button(action: { viewModel.togglePauseGame() }) {
                        Image(systemName: viewModel.session.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { showExitConfirmation = true }) {
                        HStack(spacing: 3) {
                            Text("خروج")
                                .font(.system(size: 11, weight: .bold))
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "#C8232C"), Color(hex: "#E84A27"), Color(hex: "#F58220")],
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea(edges: .top)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - مؤقت السؤال الدائري
    private var questionTimerBadge: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 4)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.remainingSeconds) / CGFloat(max(viewModel.session.timeLimitSeconds, 1)))
                    .stroke(viewModel.remainingSeconds <= 5 ? Color(hex: "#DC2626") : Color(hex: "#EA580C"), lineWidth: 4)
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: viewModel.remainingSeconds)
                
                Text("\(viewModel.remainingSeconds)")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(viewModel.remainingSeconds <= 5 ? Color(hex: "#DC2626") : Color(hex: "#1F2937"))
            }
            
            Text("ثانية متبقية")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#4B5563"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - 3. الشريط السفلي المضغوط للفرق والنتائج ووسائل المساعدة (صف أفقي واحد لا يغطي اللوحة)
    private var bottomTeamsFooter: some View {
        HStack(spacing: 8) {
            // الفريق الأول (يمين في RTL)
            teamFooterPanel(
                team: viewModel.session.team1,
                teamIndex: 0,
                isActive: viewModel.session.currentTurnTeamIndex == 0
            )
            
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(width: 1, height: 28)
            
            // الفريق الثاني (يسار في RTL)
            teamFooterPanel(
                team: viewModel.session.team2,
                teamIndex: 1,
                isActive: viewModel.session.currentTurnTeamIndex == 1
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Color.white
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 1),
            alignment: .top
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
    }
    
    private func teamFooterPanel(team: Team, teamIndex: Int, isActive: Bool) -> some View {
        HStack(spacing: 6) {
            // كبسولة اسم الفريق (مضغوطة)
            Button(action: {
                viewModel.setTurn(to: teamIndex)
            }) {
                HStack(spacing: 4) {
                    if isActive {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 5, height: 5)
                    }
                    Text(team.name)
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .frame(minWidth: 58, maxWidth: 110)
                .frame(height: 26)
                .background(isActive ? Color(hex: "#B91C1C") : Color(hex: "#DC2626").opacity(0.82))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isActive ? Color(hex: "#F59E0B") : Color.clear, lineWidth: 1.5)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            
            // شريط تعديل النقاط (- | النتيجة | +)
            HStack(spacing: 4) {
                Button(action: {
                    viewModel.adjustScore(for: teamIndex, delta: -100)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "#B91C1C"))
                }
                
                Button(action: {
                    viewModel.openScoreEditor(for: teamIndex)
                }) {
                    Text("\(team.score)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "#1F2937"))
                        .frame(minWidth: 32)
                }
                
                Button(action: {
                    viewModel.adjustScore(for: teamIndex, delta: 100)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "#B91C1C"))
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(hex: "#F3F4F6"))
            .clipShape(Capsule())
            
            Spacer(minLength: 2)
            
            // وسائل المساعدة أفقياً بجانب النقاط
            HStack(spacing: 4) {
                ForEach(LifelineType.allCases) { item in
                    let count = team.lifelinesRemaining[item.rawValue] ?? 0
                    let isUsable = isActive && count > 0 && viewModel.canUseLifeline(item)
                    
                    Button(action: {
                        if isUsable {
                            viewModel.useLifeline(item)
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isUsable ? Color(hex: "#FEF3C7") : Color(hex: "#F9FAFB"))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(isUsable ? Color(hex: "#EA580C") : Color(hex: "#D1D5DB"), lineWidth: 1)
                                )
                            
                            Image(systemName: item.iconName)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(isUsable ? Color(hex: "#B91C1C") : Color(hex: "#6B7280"))
                        }
                    }
                    .disabled(!isUsable)
                    .opacity(count > 0 ? 1.0 : 0.3)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Tie Breaker Card
    private var tieBreakerCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "scalemass.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.goldPrimary)
            
            Text("تعادل ملحمي بين الفريقين!")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack(spacing: 12) {
                Button("جولة حسم جديدة ⚔️") {
                    viewModel.startTieBreakerRound()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppTheme.goldGradient)
                .cornerRadius(14)
                
                Button("إنهاء بالتعادل") {
                    viewModel.session.phase = .matchFinished
                }
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppTheme.bgCardElevated)
                .cornerRadius(14)
            }
        }
        .padding(18)
        .premiumCard()
    }
    
    // MARK: - Pause Overlay
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#F58220"))
                
                Text("المباراة متوقفة مؤقتاً")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                VStack(spacing: 12) {
                    Button("استئناف اللعب") {
                        viewModel.togglePauseGame()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 46)
                    .background(
                        LinearGradient(colors: [Color(hex: "#DC2626"), Color(hex: "#F97316")], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                    
                    Button("إنهاء الآن") {
                        viewModel.finishMatch()
                    }
                    .font(.caption)
                    .foregroundColor(AppTheme.error)
                }
            }
            .padding(24)
            .premiumCard()
        }
    }
}
