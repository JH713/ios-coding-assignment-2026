import Foundation
import Testing
@testable import JoonggonaraAssignment

struct APIClientDecoderTests {
    private struct Payload: Decodable {
        let date: Date
    }

    private let decoder = APIClient.makeDecoder()

    @Test("소수점 초가 있는 ISO 8601 날짜를 디코딩한다")
    func decodesFractionalSeconds() throws {
        let payload = try decoder.decode(Payload.self, from: Data(#"{"date":"2025-04-30T09:41:02.053Z"}"#.utf8))
        #expect(abs(payload.date.timeIntervalSince1970 - 1_746_006_062.053) < 0.001)
    }

    @Test("소수점 초가 없는 ISO 8601 날짜도 디코딩한다")
    func decodesWholeSeconds() throws {
        let payload = try decoder.decode(Payload.self, from: Data(#"{"date":"2025-04-30T09:41:02Z"}"#.utf8))
        #expect(abs(payload.date.timeIntervalSince1970 - 1_746_006_062) < 0.001)
    }

    @Test("ISO 8601이 아닌 날짜 문자열은 디코딩에 실패한다")
    func failsOnInvalidDate() {
        #expect(throws: DecodingError.self) {
            try decoder.decode(Payload.self, from: Data(#"{"date":"2025/04/30"}"#.utf8))
        }
    }
}
