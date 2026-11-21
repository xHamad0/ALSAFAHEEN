import SwiftUI

/// شاشة اللعب الرئيسية المتكاملة
public struct GamePlayView: View {
    @StateObject public var viewModel: GamePlayViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showExitConfirmation: Bool = false
    
    public init(session: GameSession) {
        _viewModel = StateObject(wrappedValue: GamePlayViewModel(session: session))
    }
    
    public var body: some View {
        ZStack {
            // الخلفية الفاخرة
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                // ترويسة المباراة: زر الإيقاف/الخروج + الجولة + مؤقت الوقت
                headerBar
                
                // لوحة نتائج الفريقين المتنافسين
                teamsScoreBoard
                
                // محتوى الجولة حسب المرحلة الحالية
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch viewModel.session.phase {
                        case .categorySelection:
                            categorySelectionSection
                            
                        case .pointsSelection:
                            if let cat = viewModel.session.activeCategory {
                                PointsPickerCard(category: cat) { diff in
                                    viewModel.selectPoints(diff)
                                }
                            }
                            
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
        .alert(isPresented: $viewModel.noQuestionsAvailableAlert) {
            Alert(
                title: Text("تنبيه بنك الأسئلة"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("حسناً")) {
                    viewModel.session.phase = .categorySelection
                }
            )
        }
        .confirmationDialog("هل تود إنهاء المباراة مبكراً؟", isPresented: $showExitConfirmation, titleVisibility: .visible) {
            Button("إنهاء وحفظ النتيجة الحالية", role: .destructive) {
                viewModel.finishMatch()
            }
            Button("الخروج واستكمال المباراة لاحقاً") {
                dismiss()
            }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("يمكنك حفظ النتيجة الحالية أو استكمال المباراة في أي وقت لاحق من الشاشة الرئيسية.")
        }
    }
    
    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            // زر الخروج / الإنهاء
            Button(action: {
                showExitConfirmation = true
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.textMuted)
            }
            
            Spacer()
            
            // رقم الجولة
            HStack(spacing: 6) {
                Image(systemName: "flag.checkered")
                    .foregroundColor(AppTheme.goldPrimary)
                Text("الجولة \(viewModel.session.currentRound) من \(viewModel.session.totalRounds)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(AppTheme.bgCardElevated)
            .cornerRadius(20)
            
            Spacer()
            
            // زر الإيقاف المؤقت
            Button(action: {
                viewModel.togglePauseGame()
            }) {
                Image(systemName: viewModel.session.isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.goldPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }
    
    // MARK: - Score Board & Turn Indicator
    private var teamsScoreBoard: some View {
        HStack(spacing: 12) {
            // الفريق الأول
            teamScoreCard(
                team: viewModel.session.team1,
                isActive: viewModel.session.currentTurnTeamIndex == 0
            )
            
            // المؤقت في المنتصف
            if viewModel.session.phase == .questionAnswering {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.remainingSeconds) / CGFloat(max(viewModel.session.timeLimitSeconds, 1)))
                        .stroke(viewModel.remainingSeconds <= 5 ? AppTheme.error : AppTheme.goldPrimary, lineWidth: 4)
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: viewModel.remainingSeconds)
                    
                    Text("\(viewModel.remainingSeconds)")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(viewModel.remainingSeconds <= 5 ? AppTheme.error : AppTheme.textPrimary)
                }
            } else {
                Text("VS")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundColor(AppTheme.goldPrimary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.bgSecondary)
                    .clipShape(Circle())
            }
            
            // الفريق الثاني
            teamScoreCard(
                team: viewModel.session.team2,
                isActive: viewModel.session.currentTurnTeamIndex == 1
            )
        }
        .padding(.horizontal, 16)
    }
    
    private func teamScoreCard(team: Team, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: team.colorHex))
                .frame(width: 14, height: 14)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: isActive ? 2 : 0)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(.subheadline)
                    .fontWeight(isActive ? .black : .semibold)
                    .foregroundColor(isActive ? .white : AppTheme.textSecondary)
                    .lineLimit(1)
                
                Text("\(team.score) نقطة")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundColor(isActive ? AppTheme.goldPrimary : AppTheme.textPrimary)
            }
            
            Spacer()
            
            if isActive {
                Text("دوره")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.goldPrimary)
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isActive ? AppTheme.bgCardElevated : AppTheme.bgCard.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isActive ? Color(hex: team.colorHex) : Color.white.opacity(0.05), lineWidth: isActive ? 2 : 1)
                )
        )
    }
    
    // MARK: - Category Selection Section
    private var categorySelectionSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("دور: \(viewModel.session.currentTeam.name)")
                    .font(.headline)
                    .foregroundColor(Color(hex: viewModel.session.currentTeam.colorHex))
                
                Text("اختر تصنيف السؤال لهذه الجولة")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.session.selectedCategories) { cat in
                    Button(action: {
                        viewModel.selectCategory(cat)
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: cat.iconName)
                                .font(.title3)
                                .foregroundColor(cat.themeColor)
                                .frame(width: 36, height: 36)
                                .background(cat.themeColor.opacity(0.15))
                                .clipShape(Circle())
                            
                            Text(cat.titleArabic)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(AppTheme.bgCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .padding(16)
        .premiumCard()
    }
    
    // MARK: - Tie Breaker Card
    private var tieBreakerCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "scalemass.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.goldPrimary)
            
            Text("المباراة انتهت بالتعادل!")
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("تعادلت نقاط الفريقين بنتيجة \(viewModel.session.team1.score) نقطة. هل ترغب في بدء جولة حسم سريعة لتحديد الفائز؟")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 14) {
                Button(action: {
                    viewModel.startTieBreakerRound()
                }) {
                    Text("بدء جولة الحسم ⚔️")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.goldGradient)
                        .cornerRadius(16)
                }
                
                Button(action: {
                    viewModel.session.phase = .matchFinished
                }) {
                    Text("اكتفاء بالتعادل")
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.bgCardElevated)
                        .cornerRadius(16)
                }
            }
        }
        .padding(24)
        .premiumCard()
    }
    
    // MARK: - Pause Overlay
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(AppTheme.goldPrimary)
                
                Text("المباراة متوقفة مؤقتاً")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                VStack(spacing: 14) {
                    Button(action: {
                        viewModel.togglePauseGame()
                    }) {
                        Text("استئناف المباراة")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(width: 220, height: 50)
                            .background(AppTheme.goldGradient)
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        viewModel.finishMatch()
                    }) {
                        Text("إنهاء المباراة الآن")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.error)
                            .frame(width: 220, height: 46)
                            .background(AppTheme.bgCardElevated)
                            .cornerRadius(14)
                    }
                }
            }
            .padding(30)
            .premiumCard()
            .frame(maxWidth: 320)
        }
    }
}
