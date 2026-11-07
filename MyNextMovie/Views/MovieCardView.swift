import SwiftUI

private let cardShadowColor = Color.black.opacity(0.18)
private let cardShadowRadius: CGFloat = 10
private let cardShadowOffset: CGFloat = 6
private let cardTextMaxLines = 1

/// One movie in the grid: the poster with a rating badge, the title and the subtitle under it.
struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: spacingSmall) {
            poster
            caption
        }
        .accessibilityElement(children: .combine)
    }

    /// The title is printed under the poster, so the placeholder art leaves it out.
    private var poster: some View {
        PosterView(movie: movie, showsTitle: false)
            .overlay(alignment: .topTrailing) { ratingBadge }
            .shadow(color: cardShadowColor, radius: cardShadowRadius, y: cardShadowOffset)
    }

    private var ratingBadge: some View {
        RatingBadge(movie: movie)
            .padding(spacingSmall)
    }

    private var caption: some View {
        VStack(alignment: .leading, spacing: spacingTiny) {
            Text(movie.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(cardTextMaxLines)
            Text(movieSubtitle(movie))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(cardTextMaxLines)
        }
        .padding(.horizontal, spacingTiny)
    }
}

#Preview {
    MovieCardView(movie: sampleMovies[0])
        .frame(width: 170)
        .padding()
}
