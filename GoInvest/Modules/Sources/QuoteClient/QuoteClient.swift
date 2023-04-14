import DomainModels
import Foundation

public enum ClientError: Error {
    case urlError
    case getRequestError
    case parseDataError
    case anotherError
    case algorithmError
    case decodeJsonError
}

public final class QuoteClient: DetailProvider, ChartsProvider, QuoteListProvider {
    private static let UrlComponentGetListBySearch = "https://iss.moex.com/iss/securities.json?"
    private static let UrlComponentGetDefaultList = "https://iss.moex.com/iss/history/engines/stock/markets/shares/boards/tqbr/securities.json"
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    private let decoder = JSONDecoder()
    public init() {}

    public func quoteList(search: SearchForList, completion: @escaping (_: Result<[Quote], Error>) -> Void) {
        let url: URL?
        switch search {
        case .listByName(let searchStr):
            url = URL(string: QuoteClient.UrlComponentGetListBySearch + "q=" + searchStr)
        case .defaultList:
            url = URL(string: QuoteClient.UrlComponentGetDefaultList)
        }
        guard let url = url else {
            DispatchQueue.main.async {
                completion(.failure(ClientError.algorithmError))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(ClientError.getRequestError))
                }
                return
            }
            do {
                let quotesResult = try self.decoder.decode(QuoteListResult.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(quotesResult.toQuotes()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(ClientError.decodeJsonError))
                }
                return
            }
        }
        task.resume()
    }

    
    
    
    
    
    
    
    
    
    
    
    public func quoteCharts(id: String, completion: (_: Result<QuoteCharts, Error>) -> Void) {
        fatalError("Code will be modified")
    }
    public func quoteDetail(id: String, completion: (_: Result<QuoteDetail, Error>) -> Void) {
        fatalError("Code will be modified")
//        let url: URL?
//        switch search {
//        case .listByName(let searchStr):
//            url = URL(string: QuoteClient.UrlComponentGetList + "q=" + searchStr)
//        case .defaultList:
//            url = URL(string: QuoteClient.UrlComponentGetList)
//        }
//        guard let url = url else {
//            DispatchQueue.main.async {
//                completion(.failure(ClientError.algorithmError))
//            }
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        let task = session.dataTask(with: request) { data, _, error in
//            guard let data = data else {
//                print(error as Any)
//                return
//            }
////            do {
////                let json = try JSONSerialization.jsonObject(with: data, options: [])
////                print(json)
////            } catch {
////                DispatchQueue.main.async {
////                    completion(.failure(ClientError.decodeJsonError))
////                }
////                return
////            }
//            do {
//                let quotesResult = try self.decoder.decode(QuoteListResult.self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(quotesResult.toQuotes()))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(ClientError.decodeJsonError))
//                }
//                return
//            }
//        }
//        task.resume()
    }
    
}
