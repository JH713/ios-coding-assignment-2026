import Foundation
import Testing
@testable import JoonggonaraAssignment

struct ProductDTOTests {
    private let decoder = APIClient.makeDecoder()

    @Test("상품 응답을 디코딩하면 중첩·배열·옵셔널 필드까지 채워진다")
    func decodesProduct() throws {
        let dto = try decoder.decode(ProductDTO.self, from: Fixture.data("product_1"))
        #expect(dto.id == 1)
        #expect(dto.title == "Essence Mascara Lash Princess")
        #expect(dto.brand == "Essence")
        #expect(dto.tags.isEmpty == false)
        #expect(dto.dimensions.width > 0)
        #expect(dto.reviews.isEmpty == false)
        #expect(dto.meta.barcode.isEmpty == false)
        #expect(dto.images.isEmpty == false)
    }

    @Test("brand가 없는 상품 응답은 brand가 nil이다")
    func decodesMissingBrandAsNil() throws {
        let dto = try decoder.decode(ProductDTO.self, from: Fixture.data("product_without_brand"))
        #expect(dto.id == 16)
        #expect(dto.brand == nil)
    }

    @Test("목록 응답을 디코딩하면 products와 페이징 정보가 채워진다")
    func decodesListResponse() throws {
        let dto = try decoder.decode(ProductListResponseDTO.self, from: Fixture.data("products_skip0_limit2"))
        #expect(dto.products.map(\.id) == [1, 2])
        #expect(dto.total == 194)
        #expect(dto.skip == 0)
        #expect(dto.limit == 2)
    }

    @Test("도메인 변환 시 URL 문자열은 URL로, 날짜는 Date로 바뀐다")
    func convertsToDomain() throws {
        let product = try decoder.decode(ProductDTO.self, from: Fixture.data("product_1")).toDomain()
        #expect(product.thumbnailURL?.host() == "cdn.dummyjson.com")
        #expect(product.imageURLs.isEmpty == false)
        #expect(product.meta.qrCodeURL != nil)
        let expected = try Date("2025-04-30T09:41:02.053Z", strategy: .iso8601.year().month().day().time(includingFractionalSeconds: true))
        #expect(product.reviews.first?.date == expected)
    }

    @Test("목록 응답의 도메인 변환은 ProductPage가 된다")
    func convertsListToPage() throws {
        let page = try decoder.decode(ProductListResponseDTO.self, from: Fixture.data("products_skip0_limit2")).toDomain()
        #expect(page.items.map(\.id) == [1, 2])
        #expect(page.total == 194)
        #expect(page.skip == 0)
        #expect(page.limit == 2)
    }
}
