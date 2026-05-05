import SwiftUI

// MARK: - Typography Modifiers
// Gunakan modifier ini supaya gaya teks konsisten di seluruh app

struct AerunHeadlineStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .fontWeight(.heavy)
            .foregroundStyle(.white)
    }
}

struct AerunSubheadStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
    }
}

struct AerunBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundStyle(.white)
    }
}

struct AerunCaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundStyle(.gray)
    }
}

// MARK: - View Extensions
extension View {
    func aerunHeadline() -> some View { modifier(AerunHeadlineStyle()) }
    func aerunSubhead()  -> some View { modifier(AerunSubheadStyle()) }
    func aerunBody()     -> some View { modifier(AerunBodyStyle()) }
    func aerunCaption()  -> some View { modifier(AerunCaptionStyle()) }
}
