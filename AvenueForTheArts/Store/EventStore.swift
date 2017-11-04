import Foundation
import RxSwift

class EventStore {
    static func get() -> Observable<[API.Models.Event]> {
        let request = API.Endpoints.Events.Request()
        return API.session.rx
            .request(.events(request))
            .map { (_, data) in
                return try API.decoder.decode(API.Endpoints.Events.Response.self, from: data)
            }
            .map { return $0.data }
    }
}
