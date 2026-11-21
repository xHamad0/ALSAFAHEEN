import SwiftUI

/// شاشة اختيار التصنيفات الـ 26 للمباراة
public struct CategorySelectionView: View {
    @ObservedObject var setupViewModel: SetupGameViewModel
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                // شريط تحديد الكل والتنبيه
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("التصنيفات المختارة")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("\(setupViewModel.selectedCategories.count) من أصل \(QuestionCategory.allCases.count) تصنيف")
                            .font(.caption)
                            .foregroundColor(AppTheme.goldPrimary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button("تحديد الكل") {
                            setupViewModel.selectAllCategories()
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.goldPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.bgCardElevated)
                        .cornerRadius(10)
                        
                        Button("إلغاء") {
                            setupViewModel.deselectAllCategories()
                        }
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                
                // شبكة التصنيفات الـ 26
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(QuestionCategory.allCases) { cat in
                            let isSelected = setupViewModel.selectedCategories.contains(cat)
                            
                            Button(action: {
                                setupViewModel.toggleCategory(cat)
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: cat.iconName)
                                        .font(.title3)
                                        .foregroundColor(cat.themeColor)
                                        .frame(width: 36, height: 36)
                                        .background(cat.themeColor.opacity(0.15))
                                        .clipShape(Circle())
                                    
                                    Text(cat.titleArabic)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textMuted)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isSelected ? AppTheme.goldPrimary : AppTheme.textMuted.opacity(0.4))
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(isSelected ? AppTheme.bgCardElevated : AppTheme.bgCard.opacity(0.4))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(isSelected ? AppTheme.goldPrimary.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80)
                }
                
                // زر المتابعة إلى إعدادات المباراة
                NavigationLink(destination: GameSettingsView(setupViewModel: setupViewModel)) {
                    HStack(spacing: 8) {
                        Text("متابعة لإعدادات المباراة")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.left.circle.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(!setupViewModel.selectedCategories.isEmpty ? AppTheme.goldGradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                    .cornerRadius(16)
                    .shadow(color: AppTheme.goldPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(setupViewModel.selectedCategories.isEmpty)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .navigationTitle("اختيار التصنيفات")
        .navigationBarTitleDisplayMode(.inline)
    }
}
