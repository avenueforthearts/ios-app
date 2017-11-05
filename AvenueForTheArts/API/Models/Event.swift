import Foundation

extension API.Models {
    struct Event: Codable {
        enum CodingKeys: String, CodingKey {
            case id
            case name = "event_name"
            case description
            case category
            case cover
            case startDate = "start_time"
            case endDate = "end_time"
            case ticketURI = "ticket_uri"
            case placeName = "place_name"
            case city
            case country
            case latitude
            case longitude
            case state
            case street
            case zip
        }

        let id: String
        let name: String
        let description: String?
        let category: String?
        let cover: URL?
        let startDate: Date  // iso8601
        let endDate: Date?  // iso8601
        let ticketURI: URL?
        let placeName: String
        let city: String?
        let country: String?
        let latitude: Double?
        let longitude: Double?
        let state: String?
        let street: String?
        let zip: String?

        var link: URL? {
            return URL(string: "https://facebook.com/events/\(self.id)")
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.description = try container.decode(String.self, forKey: .description)
            self.category = try container.decode(String.self, forKey: .category)
            self.cover = try? container.decode(URL.self, forKey: .cover)
            self.startDate = try container.decode(Date.self, forKey: .startDate)
            self.endDate = try? container.decode(Date.self, forKey: .endDate)
            self.ticketURI = try? container.decode(URL.self, forKey: .ticketURI)
            self.placeName = try container.decode(String.self, forKey: .placeName)
            self.city = try container.decode(String.self, forKey: .city)
            self.country = try container.decode(String.self, forKey: .country)
            if let rawLatitude = try container.decodeIfPresent(String.self, forKey: .latitude) {
                self.latitude = Double(rawLatitude)
            } else {
                self.latitude = nil
            }
            if let rawLongitude = try container.decodeIfPresent(String.self, forKey: .longitude) {
                self.longitude = Double(rawLongitude)
            } else {
                self.longitude = nil
            }
            self.state = try container.decode(String.self, forKey: .state)
            self.street = try container.decode(String.self, forKey: .street)
            self.zip = try container.decode(String.self, forKey: .zip)
        }
    }
}

extension API.Models.Event: PrettyDateRange {
    var start: Date { return self.startDate }
    var end: Date? { return self.endDate }
}
