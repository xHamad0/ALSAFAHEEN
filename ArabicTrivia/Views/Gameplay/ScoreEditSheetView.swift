import SwiftUI

/// نافذة تعديل نتيجة الفريق يدوياً أثناء المباراة (Requirement 2)
public struct ScoreEditSheetView: View {
    @ObservedObject var viewModel: GamePlayViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var team: Team {
        viewModel.editingTeamIndex == 0 ? viewModel.session.team1 : viewModel.session.team2
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgDark
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // ترويسة الفريق
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: team.colorHex))
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("تعديل نتيجة")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(team.name)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.bgCardElevated)
                    .cornerRadius(16)
                    
                    // حقل تعديل النقاط المباشر
                    VStack(spacing: 8) {
                        Text("النقاط الحالية:")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        HStack {
                            TextField("أدخل النتيجة...", text: $viewModel.manualScoreText)
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundColor(AppTheme.goldPrimary)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                            
                            Text("نقطة")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .padding()
                        .background(AppTheme.bgSecondary)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.goldPrimary.opacity(0.4), lineWidth: 1.5)
                        )
                    }
                    
                    // أزرار الزيادة السريعة
                    VStack(alignment: .leading, spacing: 8) {
                        Text("إضافة سريعة:")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.success)
                        
                        HStack(spacing: 8) {
                            ForEach([100, 200, 300, 400, 500], id: \.self) { pts in
                                Button("+\(pts)") {
                                    viewModel.adjustScore(delta: pts)
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(AppTheme.success.opacity(0.85))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // أزرار الخصم السريعة
                    VStack(alignment: .leading, spacing: 8) {
                        Text("خصم سريع:")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.error)
                        
                        HStack(spacing: 8) {
                            ForEach([100, 200, 300, 400, 500], id: \.self) { pts in
                                Button("-\(pts)") {
                                    viewModel.adjustScore(delta: -pts)
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(AppTheme.error.opacity(0.85))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // زر الحفظ النهائي
                    Button(action: {
                        viewModel.applyManualScore()
                        dismiss()
                    }) {
                        Text("تأكيد وحفظ النتيجة")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.goldGradient)
                            .cornerRadius(16)
                            .shadow(color: AppTheme.goldPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(20)
            }
            .navigationTitle("تعديل النتيجة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textMuted)
                }
            }
        }
    }
}
