import SwiftUI

/// الشاشة الرئيسية بتصميم أفقي مطابق للصور المرفقة: إعداد الفريقين ووسائل المساعدة + اختيار 6 فئات + زر الإعدادات وبنك الأسئلة
public struct HomeView: View {
    @ObservedObject var dataManager = DataManager.shared
    @StateObject var bankService = QuestionBankService.shared
    @StateObject var setupViewModel = SetupGameViewModel()
    @StateObject private var tracker = UsedQuestionsTracker.shared
    
    @State private var searchText: String = ""
    @State private var navigateToGamePlay: Bool = false
    @State private var navigateToResumeMatch: Bool = false
    @State private var startedSession: GameSession? = nil
    @State private var infoCategory: QuestionCategory? = nil
    @FocusState private var isInputFocused: Bool
    
    private var filteredCategories: [QuestionCategory] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return QuestionCategory.allCases
        }
        return QuestionCategory.allCases.filter { $0.titleArabic.contains(query) }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // الترويسة العلوية (السفاحين + استكمال المباراة + الإعدادات)
                    topBar
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // 1. قسم اسم اللعبة + الفريقين + اختيار 3 وسائل مساعدة (مثل الصورة الأولى)
                            teamAndLifelinesSection
                            
                            // 2. شريط البحث واختيار الفئات العشوائية (مثل الصورة الثالثة)
                            categorySearchAndRandomBar
                            
                            // 3. شبكة التصنيفات داخل الحاوية الرمادية بعنوان برتقالي (مثل الصور 2 و 3)
                            categoriesGridContainer
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .padding(.bottom, 76)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onTapGesture {
                        isInputFocused = false
                    }
                }
                
                // زر بدء اللعب الثابت في الأسفل (يختفي أثناء الكتابة حتى لا يغطي على الكيبورد)
                if !isInputFocused {
                    VStack {
                        Spacer()
                        startGameBottomBar
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("تم") {
                        isInputFocused = false
                    }
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#EA580C"))
                }
            }
            .navigationDestination(isPresented: $navigateToGamePlay) {
                if let session = startedSession {
                    GamePlayView(session: session)
                }
            }
            .navigationDestination(isPresented: $navigateToResumeMatch) {
                if let session = dataManager.savedActiveSession {
                    GamePlayView(session: session)
                }
            }
            .alert(item: $infoCategory) { cat in
                let total = bankService.questionsByCategory[cat]?.count ?? 0
                let remaining = remainingQuestionsCount(for: cat)
                return Alert(
                    title: Text(cat.titleArabic),
                    message: Text("إجمالي الأسئلة في هذه الفئة: \(total) سؤال\nالأسئلة المتاحة غير الملعوبة: \(remaining) سؤال"),
                    dismissButton: .default(Text("حسناً"))
                )
            }
        }
    }
    
    // MARK: - الترويسة العلوية
    private var topBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                SaffahinLogoView(size: 32, isAnimated: false)
                Text("السفاحين")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
            }
            
            if let activeSession = dataManager.savedActiveSession {
                Button(action: {
                    navigateToResumeMatch = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.circle.fill")
                        Text("استكمال (\(activeSession.team1.name) × \(activeSession.team2.name))")
                            .lineLimit(1)
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1))
                }
            }
            
            Spacer()
            
            // زر الإعدادات (يحتوي على بنك الأسئلة والإحصائيات والسجل)
            NavigationLink(destination: AppSettingsView()) {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape.fill")
                    Text("الإعدادات وبنك الأسئلة")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.55), lineWidth: 1))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [Color(hex: "#C8232C"), Color(hex: "#E84A27"), Color(hex: "#F58220")],
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea(edges: .top)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - 1. قسم اسم اللعبة والفريقين واختيار 3 وسائل مساعدة
    private var teamAndLifelinesSection: some View {
        VStack(spacing: 16) {
            // حقل اسم اللعبة في المنتصف
            TextField("اسم اللعبة", text: $setupViewModel.gameName)
                .focused($isInputFocused)
                .submitLabel(.done)
                .onSubmit { isInputFocused = false }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "#1F2937"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .frame(width: 280, height: 42)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.25), lineWidth: 1)
                )
            
            // صف الفريق الأول والفريق الثاني جنباً إلى جنب (تصميم أفقي)
            HStack(alignment: .top, spacing: 20) {
                // الفريق الأول
                teamColumn(
                    title: "الفريق الأول",
                    name: $setupViewModel.team1Name,
                    teamIndex: 0,
                    selectedLifelines: setupViewModel.team1SelectedLifelines,
                    emptyWarning: "الرجاء إدخال اسم الفريق الأول"
                )
                
                // الفريق الثاني
                teamColumn(
                    title: "الفريق الثاني",
                    name: $setupViewModel.team2Name,
                    teamIndex: 1,
                    selectedLifelines: setupViewModel.team2SelectedLifelines,
                    emptyWarning: "الرجاء إدخال اسم الفريق الثاني"
                )
            }
        }
    }
    
    private func teamColumn(
        title: String,
        name: Binding<String>,
        teamIndex: Int,
        selectedLifelines: Set<LifelineType>,
        emptyWarning: String
    ) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .black))
                .foregroundColor(Color(hex: "#111827"))
            
            VStack(spacing: 4) {
                TextField("اسم الفريق", text: name)
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    .onSubmit { isInputFocused = false }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#1F2937"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(name.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty ? Color(hex: "#EF4444") : Color.black.opacity(0.25), lineWidth: 1)
                    )
                
                if name.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text(emptyWarning)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "#EF4444"))
                }
            }
            
            Text("\(title) : اختر 3 وسائل مساعدة")
                .font(.system(size: 13, weight: .black))
                .foregroundColor(Color(hex: "#1F2937"))
                .padding(.top, 2)
            
            // بطاقات وسائل المساعدة (التحديد بإطار أزرق مثل الصورة)
            HStack(spacing: 8) {
                ForEach(LifelineType.allCases) { item in
                    let isSelected = selectedLifelines.contains(item)
                    
                    Button(action: {
                        setupViewModel.toggleLifeline(item, forTeam: teamIndex)
                    }) {
                        VStack(spacing: 6) {
                            Text(item.titleArabic)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(isSelected ? Color(hex: "#111827") : Color(hex: "#9CA3AF"))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(height: 26)
                            
                            ZStack {
                                Circle()
                                    .stroke(isSelected ? lifelineColor(item) : lifelineColor(item).opacity(0.45), lineWidth: 2)
                                    .frame(width: 30, height: 30)
                                
                                Image(systemName: item.iconName)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(isSelected ? lifelineColor(item) : lifelineColor(item).opacity(0.5))
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity)
                        .background(isSelected ? Color(hex: "#E5E7EB") : Color(hex: "#F9FAFB"))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color(hex: "#38BDF8") : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func lifelineColor(_ item: LifelineType) -> Color {
        switch item {
        case .fiftyFifty: return Color(hex: "#3B82F6")
        case .doublePoints: return Color(hex: "#10B981")
        case .extraTime: return Color(hex: "#92400E")
        case .stealQuestion: return Color(hex: "#EF4444")
        }
    }
    
    // MARK: - 2. شريط البحث واختيار الفئات العشوائية
    private var categorySearchAndRandomBar: some View {
        HStack(spacing: 14) {
            // زر اختر فئات عشوائية البرتقالي
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    setupViewModel.selectRandomSixCategories()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.square.fill")
                        .font(.system(size: 16))
                    Text("اختر فئات عشوائية")
                        .font(.system(size: 14, weight: .black))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FB7134"), Color(hex: "#F97316")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#F97316").opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // حقل البحث باسم الفئة
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#F97316"))
                
                TextField("البحث باسم الفئة", text: $searchText)
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    .onSubmit { isInputFocused = false }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#1F2937"))
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 280)
            .frame(height: 44)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color(hex: "#F97316"), lineWidth: 1.5)
            )
            
            // عداد الفئات المختارة (6/6)
            HStack(spacing: 4) {
                Text("المختار:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#6B7280"))
                Text("\(setupViewModel.selectedCategories.count) / 6")
                    .font(.subheadline)
                    .fontWeight(.black)
                    .foregroundColor(setupViewModel.selectedCategories.count == 6 ? Color(hex: "#10B981") : Color(hex: "#EA580C"))
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color(hex: "#F3F4F6"))
            .clipShape(Capsule())
        }
    }
    
    // MARK: - 3. حاوية شبكة التصنيفات (4 أعمدة في الوضع الأفقي)
    private var categoriesGridContainer: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 14) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4), spacing: 16) {
                    ForEach(filteredCategories) { cat in
                        categoryGridCard(category: cat)
                    }
                }
                .padding(.top, 26)
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }
            .background(Color(hex: "#F3F4F6"))
            .cornerRadius(24)
            .padding(.top, 18)
            
            // العنوان البرتقالي البارز أعلى الحاوية مثل الصور 2 و 3
            Text("التصنيفات (اختر 6 فئات)")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .frame(height: 36)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FB7134"), Color(hex: "#F97316")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#F97316").opacity(0.25), radius: 4, x: 0, y: 2)
        }
    }
    
    private func categoryGridCard(category: QuestionCategory) -> some View {
        let isSelected = setupViewModel.selectedCategories.contains(category)
        let remaining = remainingQuestionsCount(for: category)
        
        return Button(action: {
            withAnimation(.spring(response: 0.25)) {
                setupViewModel.toggleCategory(category)
            }
        }) {
            ZStack(alignment: .top) {
                // البطاقة الأساسية
                VStack(spacing: 0) {
                    ZStack {
                        LinearGradient(
                            colors: [Color(hex: "#E0F2FE").opacity(0.65), Color.white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        Image(systemName: category.iconName)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(category.themeColor)
                            .padding(.top, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 92)
                    
                    // الشريط البرتقالي السفلي باسم الفئة
                    Text(category.titleArabic)
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#FB7134"), Color(hex: "#F97316")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color(hex: "#DC2626") : Color.black.opacity(0.08), lineWidth: isSelected ? 3 : 1)
                )
                .shadow(color: isSelected ? Color(hex: "#DC2626").opacity(0.25) : Color.black.opacity(0.06), radius: isSelected ? 6 : 3, x: 0, y: 2)
                
                // الشارات العلوية (باقي X سؤال + أيقونة i الزرقاء)
                HStack {
                    // شارة باقي X سؤال الحمراء
                    Text("باقي \(remaining) سؤال")
                        .font(.system(size: 9.5, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#EF4444"))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                    
                    // زر المعلومات الأزرق (i)
                    Button(action: {
                        infoCategory = category
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#0EA5E9"))
                            .background(Circle().fill(Color.white).padding(2))
                    }
                }
                .padding(.horizontal, 4)
                .offset(y: -6)
                
                // علامة صح عند التحديد
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#10B981"))
                        .background(Circle().fill(Color.white).padding(1))
                        .offset(y: 74)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - شريط البدء السفلي
    private var startGameBottomBar: some View {
        HStack {
            Spacer()
            Button(action: {
                startedSession = setupViewModel.createGameSession()
                navigateToGamePlay = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text(setupViewModel.isValidSetup ? "ابدأ التحدي الآن" : "أكمل أسماء الفريقين واختر 6 فئات (\(setupViewModel.selectedCategories.count)/6)")
                        .fontWeight(.black)
                }
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 36)
                .frame(height: 48)
                .background(
                    setupViewModel.isValidSetup ?
                    AnyView(LinearGradient(colors: [Color(hex: "#DC2626"), Color(hex: "#F97316")], startPoint: .leading, endPoint: .trailing)) :
                    AnyView(Color.gray.opacity(0.6))
                )
                .clipShape(Capsule())
                .shadow(color: setupViewModel.isValidSetup ? Color(hex: "#EA580C").opacity(0.4) : .clear, radius: 8, x: 0, y: 3)
            }
            .disabled(!setupViewModel.isValidSetup)
            Spacer()
        }
        .padding(.vertical, 10)
        .background(
            Color.white.opacity(0.95)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private func remainingQuestionsCount(for category: QuestionCategory) -> Int {
        let questions = bankService.questionsByCategory[category] ?? []
        return questions.filter { !tracker.isUsed(id: $0.id) }.count
    }
}
