import SwiftUI

private let blurredPosterRadius: CGFloat = 40

/// The poster stretched to fill `backdropSize` and blurred into a soft background.
/// Place it in a `GeometryReader` and pass the reader's size.
struct BlurredPoster: View {
    let movie: Movie
    let backdropSize: CGSize
    var blurRadius = blurredPosterRadius

    var body: some View {
        PosterView(movie: movie, cornerRadius: 0, showsTitle: false)
            .frame(width: backdropSize.width)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: backdropSize.width, height: backdropSize.height)
            .blur(radius: blurRadius, opaque: true)
    }
}
