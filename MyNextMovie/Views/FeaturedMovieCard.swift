import SwiftUI

private let featuredCardHeight: CGFloat = 210
private let featuredCardCornerRadius: CGFloat = 24
private let featuredPosterWidth: CGFloat = 116
private let featuredBlurRadius: CGFloat = 30
private let featuredTitleMaxLines = 2
private let featuredLabelTracking: CGFloat = 1.2
private let featuredShadowColor = Color.black.opacity(0.25)
private let featuredShadowRadius: CGFloat = 16
private let featuredShadowOffset: CGFloat = 8
private let featuredScrim = LinearGradient(
    colors: [.black.opacity(0.15), .black.opacity(0.65)],
    startPoint: .top,
    endPoint: .bottom
)

/// A wide card for the top of the list: the poster over its own blurred copy,
/// with its rank, the title, year and rating, and the main genre next to it.
struct FeaturedMovieCard: View {
    let movie: Movie
    let rank: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: spacingLarge) {
            poster
            details
            Spacer(minLength: 0)
        }
        .padding(spacingLarge)
        .frame(height: featuredCardHeight)
        .background { background }
        .clipShape(RoundedRectangle(cornerRadius: featuredCardCornerRadius, style: .continuous))
        .shadow(color: featuredShadowColor, radius: featuredShadowRadius, y: featuredShadowOffset)
        .accessibilityElement(children: .combine)
    }

    private var background: some View {
        GeometryReader { geometry in
            BlurredPoster(
                movie: movie,
                backdropSize: geometry.size,
                blurRadius: featuredBlurRadius
            )
        }
        .overlay(featuredScrim)
    }

    private var poster: some View {
        PosterView(movie: movie, showsTitle: false)
            .frame(width: featuredPosterWidth)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: spacingSmall) {
            Text("No. \(rank)")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .tracking(featuredLabelTracking)
                .foregroundStyle(.white.opacity(0.7))
            Text(movie.title)
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(featuredTitleMaxLines)
            Text(yearAndRating(movie))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .monospacedDigit()
            GenreChip(genreId: mainGenreId(movie), isSelected: true)
        }
    }
}

#Preview {
    FeaturedMovieCard(movie: sampleMovies[1], rank: 1)
        .padding()
}
