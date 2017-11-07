import Foundation
import Alamofire
import RxSwift
import RxAlamofire

class API {
    static let session: SessionManager = {
        let manager = SessionManager()
        return manager
    }()

    static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "Inf",
            negativeInfinity: "-Inf",
            nan: "NaN"
        )
        return encoder
    }()

    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "Inf",
            negativeInfinity: "-Inf",
            nan: "NaN"
        )
        return decoder
    }()

    static var hasInternetConnection: Bool {
        guard let reach = NetworkReachabilityManager() else { return false }
        return reach.isReachable
    }
}

extension Reactive where Base: SessionManager {
    func request(_ route: API.Endpoints.Route) -> Observable<(HTTPURLResponse, Data)> {
        return self.request(urlRequest: route)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap { $0.rx.responseData() }
    }
}
