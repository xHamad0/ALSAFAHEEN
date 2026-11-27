import SwiftUI

/// لوحة الجولة المكونة من 6 فئات ثابتة، وكل فئة بها 100-500 يميناً و100-500 يساراً
public struct SixCategoryBoardView: View {
    @ObservedObject var viewModel: GamePlayViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let difficulties = DifficultyLevel.allCases // 100, 200, 300, 400, 500
    
    private var columns: [GridItem] {
        // في الوضع الأفقي (Landscape) نعرض 3 أعمدة × صفين، وفي العمودي عمودان
        let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        let count = (horizontalSizeClass == .regular || isLandscape) ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: count)
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            // شبكة الفئات الست (يمين 100-500 + صورة الفئة + يسار 100-500)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.session.boardCategories) { category in
                    categoryBoardCard(category: category)
                }
            }
            
            // شريط التقدم المختصر أسفل اللوحة
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption2)
                    .foregroundColor(Color(hex: "#EA580C"))
                
                Text("الأسئلة المنجزة: \(viewModel.session.totalPlayedSlotsCount) من \(viewModel.session.boardSlots.count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#4B5563"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
    }
    
    // MARK: - بطاقة الفئة الواحدة (يمين 100-500 | صورة الفئة | يسار 100-500)
    private func categoryBoardCard(category: QuestionCategory) -> some View {
        HStack(spacing: 4) {
            // العمود الأيمن (RTL): 100 إلى 500
            VStack(spacing: 4) {
                ForEach(difficulties, id: \.self) { diff in
                    if let slot = slotFor(category: category, difficulty: diff, slotNumber: 1) {
                        pointPill(slot: slot, diff: diff)
                    }
                }
            }
            .frame(width: 42)
            
            // البطاقة المركزية للفئة (الأيقونة + الشريط البرتقالي لاسم الفئة)
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.white,
                            category.themeColor.opacity(0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    Circle()
                        .fill(category.themeColor.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [category.themeColor, category.themeColor.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 102)
                
                // الشريط البرتقالي السفلي باسم الفئة
                Text(category.titleArabic)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#EA580C"), Color(hex: "#F97316")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
            
            // العمود الأيسر (RTL): 100 إلى 500
            VStack(spacing: 4) {
                ForEach(difficulties, id: \.self) { diff in
                    if let slot = slotFor(category: category, difficulty: diff, slotNumber: 2) {
                        pointPill(slot: slot, diff: diff)
                    }
                }
            }
            .frame(width: 42)
        }
        .padding(5)
        .background(Color.white.opacity(0.78))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
    
    // MARK: - كبسولة النقاط (100 - 500)
    private func pointPill(slot: BoardSlot, diff: DifficultyLevel) -> some View {
        Button(action: {
            if !slot.isPlayed {
                viewModel.selectBoardSlot(slot)
            }
        }) {
            ZStack {
                Capsule()
                    .fill(slot.isPlayed ? Color(hex: "#E5E7EB").opacity(0.5) : Color(hex: "#E5E7EB"))
                    .frame(height: 22)
                    .overlay(
                        Capsule()
                            .stroke(slot.isPlayed ? Color.clear : Color.black.opacity(0.06), lineWidth: 0.7)
                    )
                
                if slot.isPlayed {
                    Image(systemName: slot.wasCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(slot.wasCorrect == true ? Color(hex: "#10B981").opacity(0.75) : Color(hex: "#EF4444").opacity(0.65))
                } else {
                    Text("\(diff.points)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "#991B1B"))
                }
            }
        }
        .disabled(slot.isPlayed)
        .opacity(slot.isPlayed ? 0.5 : 1.0)
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func slotFor(category: QuestionCategory, difficulty: DifficultyLevel, slotNumber: Int) -> BoardSlot? {
        viewModel.session.boardSlots.first {
            $0.category == category && $0.difficulty == difficulty && $0.slotNumber == slotNumber
        }
    }
}
