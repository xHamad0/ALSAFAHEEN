import SwiftUI

/// شاشة البداية والتحميل للهوية الفاخرة للعبة «السفاحين»
public struct SplashScreenView: View {
    @State private var isAnimating: Bool = false
    let onAnimationComplete: () -> Void
    
    public var body: some View {
        ZStack {
            AppTheme.bgDark
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // شعار السفاحين المدمج: السكين وعلامة الاستفهام
                SaffahinLogoView(size: 150, isAnimated: true)
                    .scaleEffect(isAnimating ? 1.05 : 0.95)
                
                VStack(spacing: 8) {
                    Text("السَّــفَّاحِــين")
                        .font(.system(size: 42, weight: .black, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#FCA5A5"), Color(hex: "#EF4444"), Color(hex: "#D4AF37")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "#DC2626").opacity(0.5), radius: 12, x: 0, y: 4)
                    
                    Text("صراع العقول والتحدي القاتل بين الفرق")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                // مؤشر التحميل
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(Color(hex: "#EF4444"))
                    
                    Text("جاري شحذ الأسئلة وتجهيز حلبة النزال...")
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                onAnimationComplete()
            }
        }
    }
}
