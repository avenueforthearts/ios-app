import Foundation

extension API.Endpoints {
    class Events {
        struct Request: Encodable {}

        typealias Response = [API.Models.Event]
    }
}
