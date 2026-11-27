import SwiftUI

/// شاشة كشف الإجابة ثم شاشة تحديد الفريق الفائز ("أي فريق جاوب صح ؟" مع خيارات الفريقين و"ولا أحد" و"العودة للإجابة")
public struct AnswerRevealView: View {
    @ObservedObject var viewModel: GamePlayViewModel
    @State private var showWhoAnswered: Bool = false
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(spacing: 16) {
                if !showWhoAnswered {
                    // المرحلة 1: عرض الإجابة الصحيحة بعد إيقاف الوقت
                    answerDisplaySection
                } else {
                    // المرحلة 2: "أي فريق جاوب صح ؟" مطابقة للصورة المرفقة
                    whoAnsweredSection
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(hex: "#F97316"), lineWidth: 2.5)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            
            // زر "العودة للإجابة" الأخضر أسفل الزاوية مثل الصورة المرفقة
            if showWhoAnswered {
                Button(action: {
                    withAnimation(.spring(response: 0.25)) {
                        showWhoAnswered = false
                    }
                }) {
                    Text("العودة للإجابة")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#166534"))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                }
                .offset(x: 8, y: 12)
            }
        }
        .padding(.bottom, showWhoAnswered ? 14 : 0)
    }
    
    // MARK: - المرحلة 1: عرض الإجابة الصحيحة
    private var answerDisplaySection: some View {
        VStack(spacing: 14) {
            if let question = viewModel.session.currentQuestion {
                Text("الإجابة الصحيحة")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#6B7280"))
                
                Text(question.answer)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(Color(hex: "#B91C1C"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#FEF2F2"))
                    .cornerRadius(14)
                
                if let explanation = question.explanation, !explanation.isEmpty {
                    Text(explanation)
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#4B5563"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.25)) {
                    showWhoAnswered = true
                }
            }) {
                HStack(spacing: 8) {
                    Text("من جاوب صح ؟")
                        .fontWeight(.black)
                    Image(systemName: "arrow.left.circle.fill")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: 260)
                .frame(height: 46)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#C8232C"), Color(hex: "#F97316")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#F97316").opacity(0.35), radius: 6, x: 0, y: 3)
            }
        }
    }
    
    // MARK: - المرحلة 2: أي فريق جاوب صح ؟ (مطابقة للصورة)
    private var whoAnsweredSection: some View {
        VStack(spacing: 18) {
            Text("أي فريق جاوب صح ؟")
                .font(.title3)
                .fontWeight(.black)
                .foregroundColor(Color(hex: "#1F2937"))
                .padding(.top, 4)
            
            VStack(spacing: 12) {
                // صفا الفريقين جنباً إلى جنب
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.awardQuestionTo(teamIndex: 0)
                    }) {
                        Text(viewModel.session.team1.name)
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color(hex: "#991B1B"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button(action: {
                        viewModel.awardQuestionTo(teamIndex: 1)
                    }) {
                        Text(viewModel.session.team2.name)
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color(hex: "#991B1B"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                // زر "ولا أحد" الرمادي بعرض كامل
                Button(action: {
                    viewModel.awardQuestionTo(teamIndex: nil)
                }) {
                    Text("ولا أحد")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color(hex: "#9CA3AF"))
                        .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .frame(maxWidth: 420)
            .padding(.bottom, 10)
        }
    }
}
