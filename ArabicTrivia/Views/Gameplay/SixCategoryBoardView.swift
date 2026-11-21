import SwiftUI

/// لوحة الجولة المكونة من 6 فئات ثابتة، وكل فئة بها 10 أسئلة (سؤالان لكل قيمة من 100 إلى 500)
public struct SixCategoryBoardView: View {
    @ObservedObject var viewModel: GamePlayViewModel
    @State private var selectedCategoryIndex: Int = 0
    
    private let difficulties = DifficultyLevel.allCases
    
    public var body: some View {
        VStack(spacing: 16) {
            // شريط إحصائيات اللوحة والتنبيه التكتيكي
            boardStatsHeader
            
            // شريط الفئات الـ 6 الثابتة للجولة
            categoriesTabBar
            
            // محتوى الفئة المختارة: القيم من 100 إلى 500 وبكل خانة سؤالان
            if selectedCategoryIndex < viewModel.session.boardCategories.count {
                let activeCat = viewModel.session.boardCategories[selectedCategoryIndex]
                categorySlotsView(category: activeCat)
            }
        }
    }
    
    // MARK: - Board Header
    private var boardStatsHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "square.grid.3x3.fill")
                    .foregroundColor(AppTheme.goldPrimary)
                Text("لوحة الجولة: 6 فئات ثابتة")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.bgCardElevated)
            .cornerRadius(12)
            
            Spacer()
            
            // عداد الخانات المنجزة من أصل 60
            HStack(spacing: 4) {
                Text("\(viewModel.session.totalPlayedSlotsCount) / 60")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .foregroundColor(AppTheme.goldPrimary)
                Text("سؤال لُعب")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.bgSecondary)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Categories Tab Bar (الفئات الـ 6)
    private var categoriesTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(viewModel.session.boardCategories.enumerated()), id: \.offset) { index, cat in
                    let isSelected = selectedCategoryIndex == index
                    let playedInCat = viewModel.session.boardSlots.filter { $0.category == cat && $0.isPlayed }.count
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategoryIndex = index
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: cat.iconName)
                                .font(.subheadline)
                                .foregroundColor(isSelected ? .black : cat.themeColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cat.titleArabic)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(isSelected ? .black : AppTheme.textPrimary)
                                    .lineLimit(1)
                                
                                Text("\(playedInCat)/10 سؤال")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(isSelected ? .black.opacity(0.8) : AppTheme.textMuted)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            isSelected ?
                            AnyView(AppTheme.goldGradient) :
                            AnyView(AppTheme.bgCardElevated)
                        )
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? AppTheme.goldPrimary : Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 2)
        }
    }
    
    // MARK: - Category Slots View (100 - 500، سؤالان لكل قيمة)
    private func categorySlotsView(category: QuestionCategory) -> some View {
        VStack(spacing: 12) {
            // ترويسة الفئة الحالية
            HStack {
                Image(systemName: category.iconName)
                    .foregroundColor(category.themeColor)
                    .font(.headline)
                
                Text(category.titleArabic)
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("اختر سؤالاً من الأسئلة المتاحة")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AppTheme.bgSecondary)
            .cornerRadius(14)
            
            // شبكة القيم الخمس (100 | 200 | 300 | 400 | 500) وبكل منها خانتان
            VStack(spacing: 10) {
                ForEach(difficulties, id: \.self) { diff in
                    let slots = viewModel.session.boardSlots.filter { $0.category == category && $0.difficulty == diff }
                    let slot1 = slots.first(where: { $0.slotNumber == 1 })
                    let slot2 = slots.first(where: { $0.slotNumber == 2 })
                    
                    HStack(spacing: 10) {
                        // شارة القيمة والصعوبة
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(diff.gradient)
                                .frame(width: 72, height: 48)
                                .shadow(color: diff.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            VStack(spacing: 1) {
                                Text("\(diff.points)")
                                    .font(.headline)
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                                Text("نقطة")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        // الخانة الأولى (سؤال 1)
                        if let s1 = slot1 {
                            slotButton(slot: s1, label: "سؤال 1", diff: diff)
                        }
                        
                        // الخانة الثانية (سؤال 2)
                        if let s2 = slot2 {
                            slotButton(slot: s2, label: "سؤال 2", diff: diff)
                        }
                    }
                    .padding(8)
                    .background(AppTheme.bgCard)
                    .cornerRadius(14)
                }
            }
        }
        .padding(14)
        .premiumCard()
    }
    
    // MARK: - زر الخانة الفردية
    private func slotButton(slot: BoardSlot, label: String, diff: DifficultyLevel) -> some View {
        Button(action: {
            if !slot.isPlayed {
                viewModel.selectBoardSlot(slot)
            }
        }) {
            HStack(spacing: 6) {
                if slot.isPlayed {
                    // إذا لُعب السؤال مسبقاً
                    if slot.wasCorrect == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.success)
                            .font(.subheadline)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.error)
                            .font(.subheadline)
                    }
                    
                    Text("تم اللعب")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textMuted)
                } else {
                    // سؤال متاح للعب
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(diff.primaryColor)
                        .font(.caption)
                    
                    Text(label)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.left")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.goldPrimary)
                }
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                slot.isPlayed ?
                AppTheme.bgSecondary.opacity(0.6) :
                AppTheme.bgCardElevated
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(slot.isPlayed ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .disabled(slot.isPlayed)
        .opacity(slot.isPlayed ? 0.45 : 1.0)
    }
}
