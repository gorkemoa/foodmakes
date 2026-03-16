import SwiftUI

struct TranslationInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header handle
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Animated Illustration
                    ZStack {
                        Circle()
                            .fill(Color.warmOrange.opacity(0.1))
                            .frame(width: 140, height: 140)
                            .scaleEffect(appear ? 1 : 0.8)
                        
                        Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.warmOrange, .warmOrangeLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .offset(y: appear ? 0 : 10)
                            .opacity(appear ? 1 : 0)
                        
                        // Floating language icons
                        ForEach(0..<4) { i in
                            languageBadge(index: i)
                        }
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        Text("Yemek Tarifleri Artık Türkçe!")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text("Apple'ın en yeni teknolojisini kullanarak tarifleri anında çeviriyoruz. Tamamen gizli ve cihazınızda gerçekleşir.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Info Steps
                    VStack(alignment: .leading, spacing: 20) {
                        infoRow(
                            icon: "icloud.and.arrow.down.fill",
                            color: .blue,
                            title: "Bir Kez İndirin",
                            text: "Dil paketini bir defa indirdikten sonra internete ihtiyaç duymazsınız."
                        )
                        
                        infoRow(
                            icon: "lock.shield.fill",
                            color: .green,
                            title: "Gizlilik Önceliğimiz",
                            text: "Çeviriler hiçbir sunucuya gönderilmez, her şey cihazınızda biter."
                        )
                        
                        infoRow(
                            icon: "bolt.fill",
                            color: .orange,
                            title: "Yüksek Performans",
                            text: "Yapay zeka işlemcisi sayesinde tarifler milisaniyeler içinde çevrilir."
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Button
                    Button {
                        dismiss()
                    } label: {
                        Text("Anladım")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.warmOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .warmOrange.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appear = true
            }
        }
    }
    
    private func infoRow(icon: String, color: Color, title: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(text)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func languageBadge(index: Int) -> some View {
        let icons = ["TR", "EN", "FR", "ES"]
        let angles: [Double] = [200, 310, 45, 140]
        let distances: [CGFloat] = [75, 80, 70, 78]
        
        return Text(icons[index])
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(6)
            .background(Color.warmOrange)
            .clipShape(Circle())
            .offset(
                x: appear ? cos(angles[index] * .pi / 180) * distances[index] : 0,
                y: appear ? sin(angles[index] * .pi / 180) * distances[index] : 0
            )
            .opacity(appear ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2 + Double(index) * 0.1), value: appear)
    }
}

#Preview {
    TranslationInfoView()
}
