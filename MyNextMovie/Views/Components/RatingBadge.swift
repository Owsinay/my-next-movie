import SwiftUI

struct RatingBadge: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: spacingTiny) {
            Image(systemName: symbolNameRatingStar)
            Text(formattedRating(movie))
                .monospacedDigit()
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, spacingSmall)
        .padding(.vertical, spacingExtraSmall)
        .foregroundStyle(.white)
        .background(.ultraThinMaterial, in: Capsule())
        .environment(\.colorScheme, .dark)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating \(formattedRating(movie))")
    }
}

#Preview {
    RatingBadge(movie: sampleMovies[0])
        .padding()
        .background(.gray)
}
