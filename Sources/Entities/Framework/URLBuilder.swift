import Foundation

/// A helper builder to construct the full api endpoint given a type of request.
public class UrlBuilder {
    private var endpoint: EndpointProtocol
    private var urlComponents = URLComponents()

    public init(endpoint: EndpointProtocol) {
        self.endpoint = endpoint
    }

    /// Sets the basic url components, e.g. host, path, scheme
    public func components() -> Self {
        urlComponents.scheme = "https"
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path

        return self
    }

    public func queryItems() -> Self {
        urlComponents.queryItems = endpoint.queryParameters?
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        return self
    }

    /// The full url for the requested endpoint.
    public func build() -> URL? {
        urlComponents.url
    }
}
