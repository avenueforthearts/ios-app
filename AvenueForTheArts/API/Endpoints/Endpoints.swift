import Foundation
import RxSwift
import Alamofire
import RxAlamofire

extension API {
    private static var host: String {
        return "http://10.152.191.53:1234"
    }

    class Endpoints {
        enum Route: URLRequestConvertible {
            case events(API.Endpoints.Events.Request)

            var path: String {
                switch self {
                case .events:
                    return "/events.json"
                }
            }

            var method: HTTPMethod {
                switch self {
                case .events:
                    return .get
                }
            }

            var url: URL {
                let string = "\(API.host)\(self.path)"
                return URL(string: string)!
            }

            func asURLRequest() throws -> URLRequest {
                var urlRequest = URLRequest(url: self.url)
                urlRequest.httpMethod = self.method.rawValue
                urlRequest.allHTTPHeaderFields = [
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                ]

                switch self {
                case .events(let request):
                    urlRequest.httpBody = try? API.encoder.encode(request)
                }

                return urlRequest
            }
        }
    }
}
