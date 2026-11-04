import XCTest
@testable import ParkSmart

final class ContractTests: XCTestCase {
    private func response(_ first: String = "null", _ backup: String = "null",
                          status: String = "not_implemented") throws -> RecommendationResponse {
        let json = """
        {"schema_version":"0.1","status":"\(status)","is_example":true,
         "arrival_time":"2026-10-29T09:00:00-07:00","time_zone":"America/Los_Angeles",
         "first_choice":\(first),"backup_choice":\(backup),
         "explanation":"Test fixture","limitations":[]}
        """
        return try JSONDecoder().decode(RecommendationResponse.self, from: Data(json.utf8))
    }

    private let choice = """
    {"location":{"location_id":"sample-a","name":"Sample A","coordinates":null},
     "estimated_available_fraction":null,"estimated_walking_minutes":null,
     "explanation":"Example only"}
    """

    func testNullMeasurementsStayUnknown() throws {
        let value = try response(choice, status: "ready")
        try value.validate()
        XCTAssertEqual(value.first_choice?.availabilityText, "Unavailable")
        XCTAssertEqual(value.first_choice?.walkingText, "Unavailable")
    }

    func testZeroIsKnownRatherThanUnknown() throws {
        let zero = choice.replacingOccurrences(of: "fraction\":null", with: "fraction\":0")
            .replacingOccurrences(of: "minutes\":null", with: "minutes\":0")
        let value = try response(zero, status: "ready")
        try value.validate()
        XCTAssertEqual(value.first_choice?.availabilityText, "0% estimated open")
        XCTAssertEqual(value.first_choice?.walkingText, "0.0 min")
    }

    func testDuplicateFirstAndBackupRejected() throws {
        XCTAssertThrowsError(try response(choice, choice, status: "ready").validate())
    }

    func testReadyRequiresFirstChoice() throws {
        XCTAssertThrowsError(try response(status: "ready").validate())
    }

    func testUnavailableCannotContainChoices() throws {
        XCTAssertThrowsError(try response(choice).validate())
    }

    func testOutOfRangeFractionRejected() throws {
        let invalid = choice.replacingOccurrences(of: "fraction\":null", with: "fraction\":50")
        XCTAssertThrowsError(try response(invalid, status: "ready").validate())
    }

    func testOnlyVerifiedCatalogCoordinatesBecomeMarkers() throws {
        let location = ParkingLocation(location_id: "test-only", name: "Test fixture",
                                       coordinates: Coordinates(latitude: 0, longitude: 0))
        let sample = LocationsResponse(schema_version: "0.1", data_status: "sample",
                                       locations: [location], limitations: [])
        XCTAssertTrue(sample.mappableLocations.isEmpty)
        let verified = LocationsResponse(schema_version: "0.1", data_status: "verified",
                                         locations: [location], limitations: [])
        XCTAssertEqual(verified.mappableLocations.map(\.id), ["test-only"])
        // Synthetic coordinates above are test-only and never bundled as app fixtures.
    }

    func testRequestUsesContractKeysAndCampusOffset() throws {
        let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-10-29T16:00:00Z"))
        let request = RecommendationRequest(destination: "Geisel", arrival: date, permit: "S")
        XCTAssertEqual(request.arrival_time, "2026-10-29T09:00:00-07:00")
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(request))
                                 as? [String: Any])
        XCTAssertEqual(json["permit_type"] as? String, "S")
        XCTAssertNotNil(json["destination"])
        XCTAssertNil(json["permitType"])
    }

    func testWinterRequestUsesStandardTime() throws {
        let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-12-01T17:00:00Z"))
        XCTAssertEqual(RecommendationRequest(destination: "Geisel", arrival: date, permit: "S")
            .arrival_time, "2026-12-01T09:00:00-08:00")
    }

    func testInvalidURLAndCredentialsRejected() {
        for value in ["", "file:///tmp/api", "https://user:secret@example.com", "http://localhost?q=x"] {
            XCTAssertThrowsError(try APIParkingService(baseURL: value, recommendationsEnabled: false))
        }
    }

    func testDisabledRecommendationsDoNotContactNetwork() async throws {
        let service = try APIParkingService(baseURL: "http://127.0.0.1:1", recommendationsEnabled: false)
        do {
            _ = try await service.recommendations(
                RecommendationRequest(destination: "Test", arrival: Date(), permit: "Test")
            )
            XCTFail("Expected disabled feature error")
        } catch AppError.recommendationsUnavailable {
            // Expected before any URLSession request.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
