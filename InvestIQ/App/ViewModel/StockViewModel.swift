import Foundation

class StockViewModel: ObservableObject {
    @Published var response: AlphaVantageResponse?
    @Published var errorMessage: String?

    private let apiKey = "JZ8FRH7K9GWW13SL"

    func fetchStocks(for symbol: String) {
        guard let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=5min&apikey=\(apiKey)") else {
            self.errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                self.errorMessage = error?.localizedDescription ?? "Unknown error"
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(AlphaVantageResponse.self, from: data)
                self.response = response
            } catch let error {
                self.errorMessage = error.localizedDescription
            }
        }.resume()
    }
}
