import Foundation

struct TodoApiResponse: Codable {
    let todos: [TodoItem]
    let total, skip, limit: Int
}

struct TodoItem: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

protocol ToDoAPIServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void)
}

class NetworkService: ToDoAPIServiceProtocol {

    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        let urlString = "https://dummyjson.com/todos"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                 completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TodoApiResponse.self, from: data)
                completion(.success(decodedResponse.todos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
