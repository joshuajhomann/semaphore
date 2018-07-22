import PlaygroundSupport
import UIKit

struct StarwarsCharacter: Codable {
    let name: String
}

enum APIResult<T> {
    case failure(Error), success(T)
}

func getCharactersSerially(completion: @escaping (APIResult<StarwarsCharacter>) -> ()) {
    var characters: [StarwarsCharacter] = []
    let semaphore = DispatchSemaphore(value: 1)
    let urls = (1...9).map {"https://swapi.co/api/people/\($0)"}.compactMap(URL.init(string:))
    urls.forEach { url in
        semaphore.wait()
        print("starting request for \(url) at \(Date())")
        URLSession.shared.dataTask(with: url) { data, response, error in
            print("completed request for \(url) at \(Date())")
            defer {
                semaphore.signal()
            }
            guard error == nil,
                let data = data,
                let character = try? JSONDecoder().decode(StarwarsCharacter.self, from: data) else {
                    completion(.failure(error ?? NSError()))
                    return
            }
            completion(.success(character))
            }.resume()
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
getCharactersSerially() { result in
    switch result {
    case .failure(let error):
        print(error.localizedDescription)
    case .success(let character):
        print(character.name)
    }
}
