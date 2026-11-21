import SwiftUI

/// شاشة إدارة بنك الأسئلة واستيراد وتحديث ملفات JSON
public struct QuestionBankManagementView: View {
    @StateObject private var viewModel = QuestionBankViewModel()
    @State private var jsonInputText: String = ""
    @State private var showResetDialog: Bool = false
    @State private var showImportSheet: Bool = false
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // كرت الإحصائيات الحقيقية للبنك
                    realQuestionStatsCard
                    
                    // شريط البحث في التصنيفات
                    searchBar
                    
                    // قائمة التصنيفات وتفاصيلها
                    categoriesGrid
                    
                    // أزرار العمليات (استيراد وإعادة تعيين)
                    actionButtons
                }
                .padding(16)
            }
        }
        .navigationTitle("بنك الأسئلة")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImportSheet) {
            importSheetContent
        }
        .alert("إعادة ضبط سجل الأسئلة المستخدمة", isPresented: $showResetDialog) {
            Button("تأكيد إعادة الضبط", role: .destructive) {
                viewModel.resetUsedHistory()
            }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("هل أنت متأكد من رغبتك في إعادة إتاحة جميع الأسئلة المستخدمة مسبقاً؟ سيتم تصفير سجل الاستخدام بالكامل.")
        }
        .alert("تمت العملية بنجاح", isPresented: $viewModel.showResetSuccessAlert) {
            Button("حسناً", role: .cancel) {}
        } message: {
            Text("تم تصفير سجل الأسئلة المستخدمة. جميع الأسئلة أصبحت متاحة الآن في المباريات الجديدة.")
        }
    }
    
    // MARK: - Honest Real Count Card
    private var realQuestionStatsCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("إجمالي بنك الأسئلة الفعلي")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("\(viewModel.bankService.totalQuestionsCount) سؤال حقيقي")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(AppTheme.goldPrimary)
                }
                
                Spacer()
                
                Image(systemName: "server.rack")
                    .font(.title)
                    .foregroundColor(AppTheme.goldPrimary)
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack(spacing: 14) {
                VStack(spacing: 2) {
                    Text("\(viewModel.bankService.totalAvailableCount)")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(AppTheme.success)
                    Text("أسئلة متبقية وجديدة")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 30)
                
                VStack(spacing: 2) {
                    Text("\(viewModel.tracker.totalUsedCount)")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(AppTheme.error)
                    Text("أسئلة استُهلكت في المباريات")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(18)
        .premiumCard()
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textMuted)
            
            TextField("ابحث عن تصنيف...", text: $viewModel.searchText)
                .foregroundColor(AppTheme.textPrimary)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textMuted)
                }
            }
        }
        .padding(12)
        .background(AppTheme.bgCardElevated)
        .cornerRadius(14)
    }
    
    // MARK: - Categories Grid
    private var categoriesGrid: some View {
        LazyVStack(spacing: 10) {
            ForEach(viewModel.filteredCategories) { cat in
                NavigationLink(destination: CategoryDetailView(category: cat)) {
                    HStack(spacing: 12) {
                        Image(systemName: cat.iconName)
                            .font(.headline)
                            .foregroundColor(cat.themeColor)
                            .frame(width: 36, height: 36)
                            .background(cat.themeColor.opacity(0.15))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cat.titleArabic)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            let total = viewModel.bankService.count(for: cat)
                            let avail = viewModel.bankService.availableCount(for: cat)
                            Text("\(avail) متاح من أصل \(total)")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(12)
                    .background(AppTheme.bgCard)
                    .cornerRadius(14)
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { showImportSheet = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("استيراد حزمة أسئلة JSON جديدة")
                        .fontWeight(.bold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.goldGradient)
                .cornerRadius(14)
            }
            
            Button(action: { showResetDialog = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                    Text("إعادة ضبط سجل الأسئلة المستخدمة")
                        .fontWeight(.semibold)
                }
                .foregroundColor(AppTheme.error)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(AppTheme.error.opacity(0.12))
                .cornerRadius(14)
            }
        }
        .padding(.top, 10)
    }
    
    // MARK: - Import Sheet
    private var importSheetContent: some View {
        NavigationView {
            ZStack {
                AppTheme.bgDark
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("ألصق محتوى مصفوفة JSON لإضافتها إلى بنك الأسئلة مع التحقق التلقائي من الصحة ومنع التكرار:")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.leading)
                        
                        TextEditor(text: $jsonInputText)
                            .frame(minHeight: 220)
                            .padding(8)
                            .background(AppTheme.bgSecondary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.goldPrimary.opacity(0.3), lineWidth: 1)
                            )
                        
                        Button(action: {
                            viewModel.importJSON(from: jsonInputText)
                        }) {
                            Text("التحقق والاستيراد")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(AppTheme.goldGradient)
                                .cornerRadius(14)
                        }
                        .disabled(jsonInputText.trimmingCharacters(in: .whitespaces).isEmpty)
                        
                        // تقرير نتائج الاستيراد
                        if let res = viewModel.importResult {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("تقرير الفحص:")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.goldPrimary)
                                
                                Text("إجمالي المفحوص: \(res.totalParsed)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("أُضيفت بنجاح: \(res.successfullyAdded)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.success)
                                Text("المكررة المتخطاة: \(res.duplicatesSkipped)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.warning)
                                
                                if !res.errors.isEmpty {
                                    Text("الأخطاء المكتشفة (\(res.errors.count)):")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.error)
                                    
                                    ForEach(res.errors.prefix(10), id: \.self) { err in
                                        Text("• \(err)")
                                            .font(.caption2)
                                            .foregroundColor(AppTheme.error)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.bgCard)
                            .cornerRadius(14)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("استيراد أسئلة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") {
                        showImportSheet = false
                    }
                }
            }
        }
    }
}
