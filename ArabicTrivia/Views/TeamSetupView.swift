import SwiftUI

/// شاشة إعداد الفريقين المشاركين واختيار ألوانهما
public struct TeamSetupView: View {
    @ObservedObject var setupViewModel: SetupGameViewModel
    @State private var navigateToCategories: Bool = false
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("إعداد الفريقين")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("حدد أسماء الفريقين وألوانهما المميزة في المواجهة")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 10)
                    
                    // بطاقة الفريق الأول
                    teamCard(
                        title: "الفريق الأول",
                        name: $setupViewModel.team1Name,
                        selectedColor: $setupViewModel.team1ColorHex
                    )
                    
                    // علامة المواجهة
                    ZStack {
                        Circle()
                            .fill(AppTheme.bgCardElevated)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle().stroke(AppTheme.goldPrimary.opacity(0.4), lineWidth: 1.5)
                            )
                        Text("VS")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(AppTheme.goldPrimary)
                    }
                    
                    // بطاقة الفريق الثاني
                    teamCard(
                        title: "الفريق الثاني",
                        name: $setupViewModel.team2Name,
                        selectedColor: $setupViewModel.team2ColorHex
                    )
                    
                    // زر المتابعة إلى اختيار التصنيفات
                    NavigationLink(destination: CategorySelectionView(setupViewModel: setupViewModel)) {
                        HStack(spacing: 8) {
                            Text("متابعة لاختيار التصنيفات")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.left.circle.fill")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(setupViewModel.isValidSetup ? AppTheme.goldGradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                        .cornerRadius(16)
                        .shadow(color: AppTheme.goldPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(!setupViewModel.isValidSetup)
                    .padding(.top, 10)
                }
                .padding(16)
            }
        }
        .navigationTitle("الفريقان")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func teamCard(title: String, name: Binding<String>, selectedColor: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Circle()
                    .fill(Color(hex: selectedColor.wrappedValue))
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            // حقل الاسم
            TextField("اسم الفريق...", text: name)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding()
                .background(AppTheme.bgSecondary)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: selectedColor.wrappedValue).opacity(0.5), lineWidth: 1.5)
                )
            
            // اختيار اللون
            VStack(alignment: .leading, spacing: 8) {
                Text("اختر لون الفريق:")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                HStack(spacing: 12) {
                    ForEach(AppTheme.teamColorOptions, id: \.self) { colorHex in
                        Button(action: {
                            selectedColor.wrappedValue = colorHex
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 34, height: 34)
                                
                                if selectedColor.wrappedValue == colorHex {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .premiumCard(borderColor: Color(hex: selectedColor.wrappedValue).opacity(0.4))
    }
}
