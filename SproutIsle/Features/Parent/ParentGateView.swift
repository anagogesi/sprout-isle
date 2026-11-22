import SwiftUI

struct ParentGateView: View {
    @Environment(\.dismiss) private var dismiss
    let onUnlock: () -> Void

    @State private var lhs: Int = Int.random(in: 12...24)
    @State private var rhs: Int = Int.random(in: 6...15)
    @State private var answerInput: String = ""
    @State private var showError: Bool = false

    private var expectedAnswer: Int { lhs + rhs }

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer(minLength: 12)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(IslandTheme.mint)

                Text("家长安全门")
                    .font(.kidTitle(26))
                    .foregroundStyle(IslandTheme.inkDark)

                Text("请家长计算下面这道算术题，进入学习报告与 AI 设置：")
                    .font(.kidBody(16))
                    .foregroundStyle(IslandTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("\(lhs) + \(rhs) = ?")
                    .font(.kidGiant(44))
                    .foregroundStyle(IslandTheme.inkDark)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(hex: "F1FCF6"))
                    )

                TextField("请输入答案", text: $answerInput)
                    .keyboardType(.numberPad)
                    .font(.kidTitle(26))
                    .multilineTextAlignment(.center)
                    .padding(14)
                    .frame(width: 180)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(showError ? IslandTheme.coral : IslandTheme.borderSoft, lineWidth: 2)
                            )
                    )

                if showError {
                    Text("答案不对哦，再算一下吧")
                        .font(.kidCaption(14))
                        .foregroundStyle(IslandTheme.coralDark)
                }

                Button {
                    verify()
                } label: {
                    Text("进入家长小屋")
                        .font(.kidHeadline(18))
                        .foregroundStyle(.white)
                        .frame(width: 220)
                        .padding(.vertical, 15)
                }
                .buttonStyle(ToyButtonStyle(fill: IslandTheme.mint, shadow: IslandTheme.mintDark))

                Spacer()
            }
            .padding()
            .background(IslandTheme.creamCanvas.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("返回小岛") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func verify() {
        if Int(answerInput.trimmingCharacters(in: .whitespacesAndNewlines)) == expectedAnswer {
            onUnlock()
        } else {
            showError = true
            answerInput = ""
            lhs = Int.random(in: 12...24)
            rhs = Int.random(in: 6...15)
        }
    }
}
