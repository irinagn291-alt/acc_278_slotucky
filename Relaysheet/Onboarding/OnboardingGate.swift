import SwiftUI

/// Full-page gate. Continue sits full width at the bottom. Skip still writes a bond.
struct OnboardingGate: View {
    var session: SpreadSession
    @State private var page = 0
    @State private var seatA = "Ada"
    @State private var seatB = "Ren"

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                pageCopy(
                    image: "rls_Onboarding1",
                    title: "Two seats, one phone",
                    line: "A nightly prompt with a first half and a reply."
                )
                .tag(0)
                pageCopy(
                    image: "rls_Onboarding2",
                    title: "Post the first half",
                    line: "The reply stays closed until the first half is posted."
                )
                .tag(1)
                pageCopy(
                    image: "rls_Onboarding3",
                    title: "Then it stitches",
                    line: "Both halves land on the shelf as one spread."
                )
                .tag(2)
                names
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            VStack(spacing: Space.s2) {
                Button(page == 3 ? "Continue" : "Next") {
                    if page < 3 {
                        page += 1
                    } else {
                        session.finishOnboarding(seatAName: seatA, seatBName: seatB)
                    }
                }
                .buttonStyle(SpreadPressStyle(kind: .primary))
                Button("Skip") {
                    session.finishOnboarding(seatAName: seatA, seatBName: seatB)
                }
                .buttonStyle(SpreadPressStyle(kind: .quiet))
            }
            .padding(Space.s2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Tone.background.ignoresSafeArea())
    }

    private func pageCopy(image: String, title: String, line: String) -> some View {
        VStack(alignment: .leading, spacing: Space.s3) {
            Spacer(minLength: Space.s2)
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: Space.art + Space.s10)
                .accessibilityHidden(true)
            Text(title)
                .font(TypeScale.title)
                .foregroundStyle(Tone.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .font(TypeScale.body)
                .foregroundStyle(Tone.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Space.s2)
        }
        .padding(Space.s3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var names: some View {
        VStack(alignment: .leading, spacing: Space.s2) {
            Text("Name the seats")
                .font(TypeScale.title)
                .foregroundStyle(Tone.ink)
            Text("You can change these names later.")
                .font(TypeScale.body)
                .foregroundStyle(Tone.muted)
            TextField("Your name", text: $seatA)
                .font(TypeScale.body)
                .padding(Space.s2)
                .background(Tone.surface, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
            TextField("Their name", text: $seatB)
                .font(TypeScale.body)
                .padding(Space.s2)
                .background(Tone.surface, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
            Spacer(minLength: 0)
        }
        .padding(Space.s3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// Full-page empty or error. One headline, one line, one bottom action.
struct EmptySpreadPage: View {
    var imageName: String
    var title: String
    var line: String
    var action: String
    var onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.s3) {
            Spacer(minLength: Space.s2)
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Space.art + Space.s6, maxHeight: Space.art + Space.s6)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text(title)
                .font(TypeScale.title)
                .foregroundStyle(Tone.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .font(TypeScale.body)
                .foregroundStyle(Tone.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Space.s2)
            Button(action, action: onAction)
                .buttonStyle(SpreadPressStyle(kind: .primary))
        }
        .padding(Space.s3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Tone.background.ignoresSafeArea())
    }
}
