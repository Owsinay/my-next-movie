import SwiftUI

private let backdropHeight: CGFloat = 460
private let posterWidthOnBackdrop: CGFloat = 200
private let posterShadowColor = Color.black.opacity(0.35)
private let posterShadowRadius: CGFloat = 20
private let posterShadowOffset: CGFloat = 10
private let statsCornerRadius: CGFloat = 20
private let overviewLineSpacing: CGFloat = 4

/// Shown in a stat when the value is unknown.
private let missingValue = "–"

struct MovieDetailView: View {
    let movie: Movie

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: spacingExtraLarge) {
                MovieBackdrop(movie: movie)
                MovieInfo(movie: movie).padding(.horizontal)
            }
            .padding(.bottom, spacingHuge)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

/// The poster, sharp, on top of itself stretched to the screen width and blurred.
private struct MovieBackdrop: View {
    let movie: Movie

    var body: some View {
        GeometryReader { geometry in
            BlurredPoster(movie: movie, backdropSize: geometry.size)
        }
        .frame(height: backdropHeight)
        .clipped()
        .overlay { fadeToBackground }
        .overlay(alignment: .bottom) { sharpPoster }
    }

    private var fadeToBackground: some View {
        LinearGradient(
            colors: [.clear, Color(.systemBackground)],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    private var sharpPoster: some View {
        PosterView(movie: movie, showsTitle: false)
            .frame(width: posterWidthOnBackdrop)
            .shadow(color: posterShadowColor, radius: posterShadowRadius, y: posterShadowOffset)
    }
}

/// Title and genres, rating and year, and the overview under the backdrop.
private struct MovieInfo: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: spacingExtraLarge) {
            heading
            MovieStats(movie: movie)
            overview
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: spacingMedium) {
            Text(movie.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)
            GenreRow(genreIds: knownGenreIds(movie))
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: spacingSmall) {
            Text("Overview")
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)
            Text(movie.overview)
                .foregroundStyle(.secondary)
                .lineSpacing(overviewLineSpacing)
        }
    }
}

/// Rating and year side by side in a soft panel.
private struct MovieStats: View {
    let movie: Movie

    var body: some View {
        HStack {
            StatItem(label: "Rating", value: rating, symbolName: symbolNameRatingStar)
            Divider()
            StatItem(label: "Year", value: year)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, spacingLarge)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: statsCornerRadius, style: .continuous)
        )
    }

    private var rating: String {
        formattedRating(movie)
    }

    private var year: String {
        let year = releaseYear(movie)
        return year.isEmpty ? missingValue : year
    }
}

private struct StatItem: View {
    let label: String
    let value: String
    var symbolName: String?

    var body: some View {
        VStack(spacing: spacingExtraSmall) {
            valueLabel
            Text(label)
                .font(.caption.weight(.medium))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var valueLabel: some View {
        HStack(spacing: spacingExtraSmall) {
            if let symbolName {
                Image(systemName: symbolName).font(.subheadline)
            }
            Text(value).monospacedDigit()
        }
        .font(.title3.weight(.semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

/// Genre chips in one row that scrolls sideways when they do not fit.
private struct GenreRow: View {
    let genreIds: [Int]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            chips
        }
        .scrollClipDisabled()
    }

    private var chips: some View {
        HStack(spacing: spacingSmall) {
            ForEach(genreIds, id: \.self) { genreId in
                GenreChip(genreId: genreId)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: sampleMovies[0])
    }
}
