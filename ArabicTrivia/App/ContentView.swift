import SwiftUI

public struct ContentView: View {
    @State private var isShowingSplash: Bool = true
    
    public init() {}
    
    public var body: some View {
        ZStack {
            if isShowingSplash {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowingSplash = false
                    }
                }
            } else {
                HomeView()
                    .environment(\.layoutDirection, .rightToLeft)
            }
        }
        .preferredColorScheme(.dark)
    }
}
