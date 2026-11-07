import SwiftUI

private let gridMinimumColumnWidth: CGFloat = 150
private let numberOfFeaturedMovies = 3

/// Carousel cards next to the centered one shrink and fade a little.
/// `nonisolated` because SwiftUI runs scroll transitions off the main actor.
nonisolated private let carouselSideCardScale: CGFloat = 0.92
nonisolated private let carouselSideCardOpacity = 0.6

/// A movie opened from one section of the screen.
/// The same movie can be in the carousel and in the grid, so the section tells
/// the zoom transition which of the two cards to grow from.
private struct MovieRoute: Hashable {
    let movie: Movie
    let section: MovieSection
}

private enum MovieSection {
    case featured
    case popular
}

struct MovieListView: View {
    @State private var viewModel: MovieListViewModel
    @Namespace private var zoomNamespace

    init(viewModel: MovieListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("My Next Movie")
                .navigationDestination(for: MovieRoute.self, destination: movieDetail)
        }
        .task { await viewModel.loadIfNeeded() }
    }

    private func movieDetail(_ route: MovieRoute) -> some View {
        MovieDetailView(movie: route.movie)
            .navigationTransition(.zoom(sourceID: route, in: zoomNamespace))
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingGrid
        case .loaded:
            loadedGrid
        case .failed:
            ErrorView(title: "Could not load movies", message: viewModel.errorMessage) {
                Task { await viewModel.load() }
            }
        }
    }

    /// Sample movies drawn as gray shapes while the real ones load.
    private var loadingGrid: some View {
        MovieGrid(movies: sampleMovies, zoomNamespace: zoomNamespace)
            .redacted(reason: .placeholder)
            .allowsHitTesting(false)
    }

    @ViewBuilder
    private var loadedGrid: some View {
        if viewModel.movies.isEmpty {
            ContentUnavailableView("No movies", systemImage: symbolNameMovies)
        } else {
            MovieGrid(movies: viewModel.movies, zoomNamespace: zoomNamespace)
        }
    }
}

/// The best rated movies, best first.
private func featuredMovies(_ movies: [Movie]) -> [Movie] {
    let byRating = movies.sorted { $0.voteAverage > $1.voteAverage }
    return Array(byRating.prefix(numberOfFeaturedMovies))
}

private struct MovieGrid: View {
    let movies: [Movie]
    let zoomNamespace: Namespace.ID

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: spacingHuge) {
                FeaturedCarousel(movies: featuredMovies(movies), zoomNamespace: zoomNamespace)
                popularSection
            }
            .padding(.top, spacingSmall)
            .padding(.bottom, spacingHuge)
        }
    }

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: spacingLarge) {
            SectionHeader(title: "Popular", subtitle: "\(movies.count) movies to pick from")
            grid
        }
        .padding(.horizontal)
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: gridMinimumColumnWidth), spacing: spacingLarge)]
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: spacingExtraLarge) {
            ForEach(movies) { movie in
                MovieGridItem(movie: movie, zoomNamespace: zoomNamespace)
            }
        }
    }
}

/// Featured movies in a row that snaps to one card at a time.
private struct FeaturedCarousel: View {
    let movies: [Movie]
    let zoomNamespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: spacingLarge) {
            SectionHeader(title: "Top rated", subtitle: "The highest rated picks right now")
                .padding(.horizontal)
            cards
        }
    }

    private var cards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacingMedium) {
                ForEach(movies.indices, id: \.self, content: carouselCard)
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, spacingLarge, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled()
    }

    private func carouselCard(_ position: Int) -> some View {
        FeaturedCarouselItem(
            movie: movies[position],
            rank: position + 1,
            zoomNamespace: zoomNamespace
        )
    }
}

nonisolated private func carouselTransition(
    _ card: EmptyVisualEffect,
    phase: ScrollTransitionPhase
) -> some VisualEffect {
    card
        .scaleEffect(phase.isIdentity ? 1 : carouselSideCardScale)
        .opacity(phase.isIdentity ? 1 : carouselSideCardOpacity)
}

/// One page of the carousel, as wide as the carousel.
private struct FeaturedCarouselItem: View {
    let movie: Movie
    let rank: Int
    let zoomNamespace: Namespace.ID

    var body: some View {
        let route = MovieRoute(movie: movie, section: .featured)
        NavigationLink(value: route) {
            FeaturedMovieCard(movie: movie, rank: rank)
        }
        .buttonStyle(PressableCardStyle())
        .matchedTransitionSource(id: route, in: zoomNamespace)
        .containerRelativeFrame(.horizontal)
        .scrollTransition(axis: .horizontal, transition: carouselTransition)
    }
}

/// One cell of the grid. Tapping it zooms the card into the movie details.
private struct MovieGridItem: View {
    let movie: Movie
    let zoomNamespace: Namespace.ID

    var body: some View {
        let route = MovieRoute(movie: movie, section: .popular)
        NavigationLink(value: route) {
            MovieCardView(movie: movie)
        }
        .buttonStyle(PressableCardStyle())
        .matchedTransitionSource(id: route, in: zoomNamespace)
    }
}

#Preview {
    MovieListView(viewModel: MovieListViewModel(loadMovies: loadSampleMovies))
}
