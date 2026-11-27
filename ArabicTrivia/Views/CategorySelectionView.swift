import SwiftUI

/// شاشة اختيار الفئات الـ 6 الثابتة للجولة (Requirement 4)
public struct CategorySelectionView: View {
    @ObservedObject var setupViewModel: SetupGameViewModel
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                // شريط التحديد والعداد
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("الفئات الـ 6 الثابتة للجولة")
                                .font(.headline)
                                .fontWeight(.black)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("اختر 6 فئات لجميع الفرق (100-500 يمين ويسار)")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        // عداد 6 فئات
                        ZStack {
                            Capsule()
                                .fill(setupViewModel.selectedCategories.count == 6 ? AppTheme.success.opacity(0.2) : AppTheme.goldPrimary.opacity(0.15))
                                .frame(width: 80, height: 32)
                            
                            HStack(spacing: 2) {
                                Text("\(setupViewModel.selectedCategories.count)")
                                    .fontWeight(.black)
                                    .foregroundColor(setupViewModel.selectedCategories.count == 6 ? AppTheme.success : AppTheme.goldPrimary)
                                Text("/ 6")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                    }
                    
                    // زر اختيار 6 فئات عشوائياً
                    Button(action: {
                        setupViewModel.selectRandomSixCategories()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "dice.fill")
                            Text("اختيار 6 فئات عشوائياً بضغطة واحدة 🎲")
                                .fontWeight(.bold)
                        }
                        .font(.caption)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(AppTheme.goldGradient)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                
                // قائمة التصنيفات
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
                                                .stroke(isSelected ? AppTheme.goldPrimary.opacity(0.6) : Color.white.opacity(0.05), lineWidth: 1.2)
                                        )
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80)
                }
                
                // زر المتابعة (مفعل فقط عند اختيار 6 فئات تماماً)
                NavigationLink(destination: GameSettingsView(setupViewModel: setupViewModel)) {
                    HStack(spacing: 8) {
                        Text(setupViewModel.selectedCategories.count == 6 ? "تأكيد الـ 6 فئات والمتابعة" : "يرجى تحديد 6 فئات (\(setupViewModel.selectedCategories.count)/6)")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.left.circle.fill")
                    }
                    .font(.headline)
                    .foregroundColor(setupViewModel.selectedCategories.count == 6 ? .black : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(setupViewModel.selectedCategories.count == 6 ? AnyView(AppTheme.goldGradient) : AnyView(Color.gray.opacity(0.3)))
                    .cornerRadius(16)
                    .shadow(color: setupViewModel.selectedCategories.count == 6 ? AppTheme.goldPrimary.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                }
                .disabled(setupViewModel.selectedCategories.count != 6)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .navigationTitle("فئات الجولة")
        .navigationBarTitleDisplayMode(.inline)
    }
}
