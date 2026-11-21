import SwiftUI

/// شعار وهوية لعبة «السفاحين» يدمج نصل السكين الحاد مع علامة الاستفهام الفكرية
public struct SaffahinLogoView: View {
    var size: CGFloat = 120
    var isAnimated: Bool = true
    
    @State private var pulseGlow: Bool = false
    
    public init(size: CGFloat = 120, isAnimated: Bool = true) {
        self.size = size
        self.isAnimated = isAnimated
    }
    
    public var body: some View {
        ZStack {
            // هالة التوهج الدامي والذهبي
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#DC2626").opacity(pulseGlow ? 0.45 : 0.25),
                            Color(hex: "#991B1B").opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: size * 0.75
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)
            
            // الدرع والشعار
            ZStack {
                if let uiImage = UIImage(named: "logo") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: size * 0.22)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "#EF4444"), Color(hex: "#D4AF37"), Color(hex: "#991B1B")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: size * 0.025
                                )
                        )
                        .shadow(color: Color(hex: "#DC2626").opacity(0.5), radius: 15, x: 0, y: 5)
                } else {
                    // تصميم المتجه الاحتياطي المدمج
                    fallbackVectorLogo
                }
            }
        }
        .onAppear {
            if isAnimated {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseGlow = true
                }
            }
        }
    }
    
    private var fallbackVectorLogo: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#180B0F"), Color(hex: "#0F172A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#EF4444"), Color(hex: "#D4AF37"), Color(hex: "#991B1B")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: size * 0.025
                        )
                )
                .shadow(color: Color(hex: "#DC2626").opacity(0.4), radius: 15, x: 0, y: 5)
            
            // سكين مدمج مع علامة استفهام
            ZStack {
                Image(systemName: "knife.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.52, height: size * 0.52)
                    .rotationEffect(.degrees(-45))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#F1F5F9"), Color(hex: "#94A3B8"), Color(hex: "#475569")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(x: -size * 0.04, y: size * 0.04)
                
                Text("؟")
                    .font(.system(size: size * 0.65, weight: .black, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#F87171"), Color(hex: "#EF4444"), Color(hex: "#F59E0B")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(hex: "#EF4444").opacity(0.8), radius: 8, x: 0, y: 0)
                    .offset(x: size * 0.05, y: -size * 0.02)
                
                Circle()
                    .fill(Color(hex: "#EF4444"))
                    .frame(width: size * 0.1, height: size * 0.1)
                    .overlay(Circle().stroke(Color(hex: "#FDE047"), lineWidth: 1.5))
                    .offset(x: size * 0.05, y: size * 0.28)
            }
        }
    }
}
