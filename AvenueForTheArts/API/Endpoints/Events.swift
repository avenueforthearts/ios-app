import Foundation

extension API.Endpoints {
    class Events {
        struct Request: Encodable {}

        struct Response: Decodable {
            let data: [API.Models.Event]
        }
    }
}
