import SwiftUI

/// شاشة كشف الإجابة الصحيحة واحتساب النقاط والتوضيح
public struct AnswerRevealView: View {
    @ObservedObject var viewModel: GamePlayViewModel
    
    public var body: some View {
        VStack(spacing: 20) {
            let isCorrect = viewModel.session.lastAnswerWasCorrect == true
            
            // أيقونة النتيجة وتأثيرها
            ZStack {
                Circle()
                    .fill(isCorrect ? AppTheme.success.opacity(0.18) : AppTheme.error.opacity(0.18))
                    .frame(width: 90, height: 90)
                
                Image(systemName: isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isCorrect ? AppTheme.success : AppTheme.error)
            }
            .padding(.top, 10)
            
            // عنوان النتيجة والنقاط
            VStack(spacing: 6) {
                Text(isCorrect ? "إجابة صحيحة وممتازة! 🎉" : "إجابة خاطئة أو انتهى الوقت! ❌")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(isCorrect ? AppTheme.success : AppTheme.error)
                
                if isCorrect {
                    Text("+\(viewModel.session.lastPointsEarned) نقطة لصالح \(viewModel.session.currentTeam.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.goldPrimary)
                } else {
                    Text("لم يحصل الفريق على أي نقاط في هذه الجولة")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            // كرت الإجابة الصحيحة النموذجية
            if let question = viewModel.session.currentQuestion {
                VStack(alignment: .leading, spacing: 10) {
                    Text("الإجابة الصحيحة:")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textMuted)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.success)
                        Text(question.answer)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    // الشرح والتوضيح إذا وجد
                    if let explanation = question.explanation, !explanation.isEmpty {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(AppTheme.goldPrimary)
                                    .font(.caption)
                                Text("معلومة إضافية:")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.goldPrimary)
                            }
                            Text(explanation)
                                .font(.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                                .lineSpacing(4)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.bgSecondary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.goldPrimary.opacity(0.2), lineWidth: 1)
                )
            }
            
            // زر المتابعة إلى الدور التالي
            Button(action: {
                viewModel.proceedToNextTurn()
            }) {
                HStack(spacing: 8) {
                    Text("متابعة إلى الدور التالي")
                        .font(.headline)
                        .fontWeight(.bold)
                    Image(systemName: "arrow.left.circle.fill")
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppTheme.goldGradient)
                .cornerRadius(16)
                .shadow(color: AppTheme.goldPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 10)
        }
        .padding(20)
        .premiumCard()
    }
}
