import Combine
import Foundation

@MainActor
final class PlannerModel: ObservableObject {
    @Published var destination = ""
    @Published var permit = ""
    @Published var arrival = Date()
    @Published var useAPI = false
    @Published var scenario: SampleScenario = .cards
    @Published var baseURL = UserDefaults.standard.string(forKey: "apiBaseURL")
        ?? "http://127.0.0.1:8000"
    @Published var recommendationsEnabled = false
    @Published private(set) var catalog: LocationsResponse?
    @Published private(set) var result: RecommendationResponse?
    @Published private(set) var error: String?
    @Published private(set) var busy = false
    @Published private(set) var requestJSON = ""
    @Published var selectedID: String?
    private var work: Task<Void, Never>?

    var validInput: Bool {
        [destination, permit].allSatisfy {
            let text = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            return !text.isEmpty && text.count <= 200
        }
    }

    private func service() throws -> any ParkingService {
        if useAPI {
            return try APIParkingService(baseURL: baseURL,
                                         recommendationsEnabled: recommendationsEnabled)
        }
        return SampleParkingService(scenario: scenario)
    }

    /// Discard stale responses when inputs or connection settings change.
    func invalidate(clearCatalog: Bool = false) {
        work?.cancel()
        busy = false
        result = nil
        error = nil
        selectedID = nil
        requestJSON = ""
        if clearCatalog { catalog = nil }
    }

    func loadLocations() {
        invalidate(clearCatalog: true)
        busy = true
        work = Task {
            do {
                let value = try await service().locations()
                try Task.checkCancellation()
                catalog = value
                busy = false
            } catch {
                guard !Task.isCancelled else { return }
                self.error = error.localizedDescription
                busy = false
            }
        }
    }

    func plan() {
        guard validInput else { return }
        invalidate()
        let request = RecommendationRequest(
            destination: destination.trimmingCharacters(in: .whitespacesAndNewlines),
            arrival: arrival, permit: permit.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        requestJSON = (try? String(data: encoder.encode(request), encoding: .utf8)) ?? ""
        busy = true
        work = Task {
            do {
                let value = try await service().recommendations(request)
                try Task.checkCancellation()
                result = value
                selectedID = value.first_choice?.location.id
                busy = false
            } catch {
                guard !Task.isCancelled else { return }
                self.error = error.localizedDescription
                busy = false
            }
        }
    }

    func saveConnection() {
        UserDefaults.standard.set(baseURL, forKey: "apiBaseURL")
        loadLocations()
    }
}
