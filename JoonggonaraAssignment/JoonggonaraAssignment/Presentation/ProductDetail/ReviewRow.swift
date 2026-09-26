import SwiftUI

struct ReviewRow: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(review.reviewerName).font(.subheadline.bold())
                Spacer()
                Text(review.date, format: .dateTime.year().month().day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(String(repeating: "★", count: review.rating))
                .font(.caption)
                .foregroundStyle(.orange)
            Text(review.comment)
        }
        .padding(.vertical, 4)
    }
}
