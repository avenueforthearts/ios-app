import Foundation

extension API.Endpoints {
    enum Routes {
        case events

        var path: String {
            switch self {
            case .events:
                return "/events"
            }
        }
    }
}
