import SwiftUI

struct ProductDetailView: View {
    @State private var viewModel: ProductDetailViewModel

    init(viewModel: ProductDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("상품 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                FavoriteButton(isFavorite: viewModel.isFavorite, action: viewModel.toggleFavorite)
            }
            .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .failed(let error):
            ContentUnavailableView {
                Label("불러오지 못했습니다", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.localizedDescription)
            } actions: {
                Button("다시 시도") { Task { await viewModel.load() } }
            }
        case .loaded(let product):
            List {
                Section {
                    ProductImageCarousel(urls: product.imageURLs)
                        .listRowInsets(EdgeInsets())
                }
                Section {
                    Text(product.title).font(.title3.bold())
                    Text(product.description)
                }
                Section("기본 정보") {
                    LabeledContent("가격", value: product.price, format: .currency(code: "USD"))
                    LabeledContent("할인율", value: product.discountPercentage / 100, format: .percent)
                    LabeledContent("평점", value: product.rating, format: .number.precision(.fractionLength(2)))
                    LabeledContent("브랜드", value: product.brand ?? "-")
                    LabeledContent("카테고리", value: product.category)
                    LabeledContent("태그", value: product.tags.joined(separator: ", "))
                }
                Section("재고·주문") {
                    LabeledContent("재고", value: product.stock, format: .number)
                    LabeledContent("판매 상태", value: product.availabilityStatus)
                    LabeledContent("최소 주문 수량", value: product.minimumOrderQuantity, format: .number)
                }
                Section("규격") {
                    LabeledContent("SKU", value: product.sku)
                    LabeledContent("무게", value: product.weight, format: .number)
                    LabeledContent("치수", value: "\(product.dimensions.width) × \(product.dimensions.height) × \(product.dimensions.depth)")
                }
                Section("정책") {
                    LabeledContent("보증", value: product.warrantyInformation)
                    LabeledContent("배송", value: product.shippingInformation)
                    LabeledContent("반품", value: product.returnPolicy)
                }
                Section("리뷰") {
                    ForEach(Array(product.reviews.enumerated()), id: \.offset) { _, review in
                        ReviewRow(review: review)
                    }
                }
                Section("메타") {
                    LabeledContent("등록", value: product.meta.createdAt, format: .dateTime)
                    LabeledContent("수정", value: product.meta.updatedAt, format: .dateTime)
                    LabeledContent("바코드", value: product.meta.barcode)
                    if let qrCodeURL = product.meta.qrCodeURL {
                        LabeledContent("QR") {
                            RemoteImage(url: qrCodeURL, contentMode: .fit)
                                .frame(width: 80, height: 80)
                        }
                    }
                }
            }
        }
    }
}
