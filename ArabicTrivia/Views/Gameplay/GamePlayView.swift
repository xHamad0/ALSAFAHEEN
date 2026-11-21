import SwiftUI

/// شاشة اللعب الرئيسية المتكاملة مع لوحة الفئات الـ 6 وتعديل النتيجة وتبديل الدور
public struct GamePlayView: View {
    @StateObject public var viewModel: GamePlayViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showExitConfirmation: Bool = false
    
    public init(session: GameSession) {
        _viewModel = StateObject(wrappedValue: GamePlayViewModel(session: session))
    }
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // ترويسة المباراة: زر الخروج + عداد الخانات + زر الإيقاف المؤقت
                headerBar
                
                // لوحة نتائج الفريقين (قابلة للنقر لتعديل النتيجة)
                teamsScoreBoard
                
                // شريط تحديد وتبديل الدور اليدوي (Requirement 3: اقدر اعدل الدور عند مين)
                turnControlBanner
                
                // محتوى الجولة حسب المرحلة الحالية
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch viewModel.session.phase {
                        case .boardSelection:
                            // لوحة الفئات الـ 6 الثابتة (Requirement 4)
                            SixCategoryBoardView(viewModel: viewModel)
                            
                        case .questionAnswering:
                            if let question = viewModel.session.currentQuestion,
                               let diff = viewModel.session.activeDifficulty {
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
                                
                                // شريط وسائل المساعدة
                                LifelinesBarView(
                                    team: viewModel.session.currentTeam,
                                    canUse: { viewModel.canUseLifeline($0) },
                                    onUse: { viewModel.useLifeline($0) }
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
                                    .foregroundColor(AppTheme.textMuted)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            
                        case .answerRevealed:
                            AnswerRevealView(viewModel: viewModel)
                            
                        case .tieBreakerPending:
                            tieBreakerCard
                            
                        case .matchFinished:
                            FinalResultsView(session: viewModel.session) {
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
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
    
    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            Button(action: { showExitConfirmation = true }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.textMuted)
            }
            
            Spacer()
            
            Text("السَّــفَّاحِــين")
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(AppTheme.goldGradient)
            
            Spacer()
            
            Button(action: { viewModel.togglePauseGame() }) {
                Image(systemName: viewModel.session.isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.goldPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
    
    // MARK: - Score Board (مع دعم التعديل اليدوي بالضغط على البطاقة)
    private var teamsScoreBoard: some View {
        HStack(spacing: 10) {
            // كرت الفريق الأول (قابل للنقر لتعديل النتيجة)
            teamScoreCard(
                team: viewModel.session.team1,
                isActive: viewModel.session.currentTurnTeamIndex == 0,
                teamIndex: 0
            )
            
            // المؤقت في المنتصف أثناء الإجابة
            if viewModel.session.phase == .questionAnswering {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.remainingSeconds) / CGFloat(max(viewModel.session.timeLimitSeconds, 1)))
                        .stroke(viewModel.remainingSeconds <= 5 ? AppTheme.error : AppTheme.goldPrimary, lineWidth: 4)
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: viewModel.remainingSeconds)
                    
                    Text("\(viewModel.remainingSeconds)")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(viewModel.remainingSeconds <= 5 ? AppTheme.error : AppTheme.textPrimary)
                }
            } else {
                Text("VS")
                    .font(.caption2)
                    .fontWeight(.black)
                    .foregroundColor(AppTheme.goldPrimary)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.bgSecondary)
                    .clipShape(Circle())
            }
            
            // كرت الفريق الثاني (قابل للنقر لتعديل النتيجة)
            teamScoreCard(
                team: viewModel.session.team2,
                isActive: viewModel.session.currentTurnTeamIndex == 1,
                teamIndex: 1
            )
        }
        .padding(.horizontal, 14)
    }
    
    private func teamScoreCard(team: Team, isActive: Bool, teamIndex: Int) -> some View {
        Button(action: {
            viewModel.openScoreEditor(for: teamIndex)
        }) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: team.colorHex))
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(team.name)
                            .font(.system(size: 13, weight: isActive ? .black : .bold))
                            .foregroundColor(isActive ? .white : AppTheme.textSecondary)
                            .lineLimit(1)
                        
                        // أيقونة التعديل
                        Image(systemName: "pencil")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    
                    Text("\(team.score) ن")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(isActive ? AppTheme.goldPrimary : AppTheme.textPrimary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isActive ? AppTheme.bgCardElevated : AppTheme.bgCard.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isActive ? Color(hex: team.colorHex) : Color.white.opacity(0.08), lineWidth: isActive ? 2 : 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Turn Control Banner (Requirement 3: اقدر اعدل الدور عند مين)
    private var turnControlBanner: some View {
        Button(action: {
            viewModel.switchTurn()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.arrow.triangle.turn.up.right.diamond.fill")
                    .foregroundColor(AppTheme.goldPrimary)
                    .font(.caption)
                
                Text("الدور الحالي:")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(viewModel.session.currentTeam.name)
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundColor(Color(hex: viewModel.session.currentTeam.colorHex))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("تبديل الدور")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppTheme.goldGradient)
                .cornerRadius(8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.bgCardElevated)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.goldPrimary.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 14)
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
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.goldPrimary)
                
                Text("المباراة متوقفة مؤقتاً")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                VStack(spacing: 12) {
                    Button("استئناف اللعب") {
                        viewModel.togglePauseGame()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(width: 200, height: 46)
                    .background(AppTheme.goldGradient)
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
