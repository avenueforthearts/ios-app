import Foundation

extension API.Models {
    struct Event: Codable {
        enum CodingKeys: String, CodingKey {
            case id, category, cover, description, name, owner, place, timezone, type
            case attendingCount = "attending_count"
            case canGuestsInvite = "can_guests_invite"
            case canViewerPost = "can_viewer_post"
            case declinedCount = "declined_count"
            case endDate = "end_time"
//            case eventTimes = "event_times"
            case isGuestListEnabled = "guest_list_enabled"
            case interestedCount = "interested_count"
            case isCanceled = "is_canceled"
            case isDraft = "is_draft"
            case isPageOwned = "is_page_owned"
            case isViewerAdmin = "is_viewer_admin"
            case maybeCount = "maybe_count"
            case noReplyCount = "no_reply_count"
            case parentGroup = "parent_group"
            case scheduledPublishDate = "scheduled_publish_time"
            case startDate = "start_time"
            case ticketURI = "ticket_uri"
            case ticketingPrivacyURI = "ticketing_privacy_uri"
            case ticketingTermsURI = "ticketing_terms_uri"
            case updatedDate = "updated_time"
        }

        typealias ChildEvent = Event

        let id: String
        let name: String
        let description: String
        let owner: Owner?
        let place: Place

        let category: String?
        let cover: CoverPhoto?

        let canGuestsInvite: Bool?
        let canViewerPost: Bool?

        let isGuestListEnabled: Bool?
        let isCanceled: Bool?
        let isDraft: Bool?
        let isPageOwned: Bool?
        let isViewerAdmin: Bool?

        let attendingCount: Int?
        let interestedCount: Int?
        let maybeCount: Int?
        let noReplyCount: Int?
        let declinedCount: Int?

        let parentGroup: Group?

        let scheduledPublishDate: Date?  // iso8601
        let startDate: Date  // iso8601
        let endDate: Date?  // iso8601
        let updatedDate: Date?  // iso8601
        let timezone: TimeZone?
//        let eventTimes: [ChildEvent]?

        let ticketURI: String?
        let ticketingPrivacyURI: String?
        let ticketingTermsURI: String?

        let type: EventType?
    }

    enum EventType: String, Codable {
        case `private`
        case `public`
        case group
        case community

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let value = EventType(rawValue: raw) {
                self = value
            } else {
                throw DecodingError.typeMismatch(
                    EventType.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "EventType failed to decode with raw value \(raw)"
                    )
                )
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        }
    }

    struct CoverPhoto: Codable {
        enum CodingKeys: String, CodingKey {
            case id
            case offsetX = "offset_x"
            case offsetY = "offset_y"
            case source
        }

        let id: String
        let offsetX: Float
        let offsetY: Float
        let source: String
    }

    struct Place: Codable {
        enum codingKeys: String, CodingKey {
            case id, location, name
            case rating = "overall_rating"
        }


        struct Location: Codable {
            enum CodingKeys: String, CodingKey {
                case city, country, latitude, longitude, name, region, state, street, zip
                case cityID = "city_id"
                case countryCode = "country_code"
                case regionID = "region_id"
            }

            let city: String
            let country: String
            let latitude: Float
            let longitude: Float
            let name: String?
            let state: String
            let street: String
            let zip: String

            let cityID: UInt?
            let countryCode: String?
            let region: String?
            let regionID: UInt?
        }

        let id: String?
        let location: Location?
        let name: String
        let rating: Float?
    }

    struct Group: Codable {

    }

    struct Owner: Codable {

    }
}
