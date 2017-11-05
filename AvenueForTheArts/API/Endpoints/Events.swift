import Foundation

extension API.Endpoints {
    class Events {
        struct Request: Encodable {}

        struct Response: Decodable {
            let events: [API.Models.Event]

            init(from decoder: Decoder) throws {
                let failables = try [FailableDecodable<API.Models.Event>](from: decoder)
                self.events = failables.flatMap { $0.value }
            }
        }
    }
}

struct FailableDecodable<ValueType: Decodable> : Decodable {
    let value: ValueType?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try? container.decode(ValueType.self)
    }
}
