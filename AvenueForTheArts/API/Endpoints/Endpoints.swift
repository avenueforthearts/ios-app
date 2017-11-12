import Foundation
import RxSwift
import Alamofire
import RxAlamofire

extension API {
    private static var host: String {
        return "https://avenue-for-the-arts-backend.herokuapp.com"
    }

    class Endpoints {
        enum Route: URLRequestConvertible {
            case events(API.Endpoints.Events.Request)

            var path: String {
                switch self {
                case .events:
                    return "/events/"
                }
            }

            var method: HTTPMethod {
                switch self {
                case .events:
                    return .get
                }
            }

            var url: URL {
                return URL(string: "\(API.host)\(self.path)")!
            }

            func asURLRequest() throws -> URLRequest {
                var urlRequest = URLRequest(url: self.url)
                urlRequest.httpMethod = self.method.rawValue
                urlRequest.allHTTPHeaderFields = [
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                ]

                urlRequest.timeoutInterval = 10
                if !API.hasInternetConnection {
                    urlRequest.cachePolicy = .returnCacheDataDontLoad
                    urlRequest.setValue(
                        String(format: "max-stale=%d", INT32_MAX),
                        forHTTPHeaderField: "Cache-Control"
                    )
                }


                return urlRequest
            }
        }
    }
}
