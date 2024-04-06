import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = StockViewModel()
    @State private var searchText = ""

    var body: some View {
        VStack {
            SearchBar(text: $searchText, onSearch: { symbol in
                viewModel.fetchStocks(for: symbol)
            })
            .padding()

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                if let metaData = viewModel.response?.metaData,
                   let timeSeries = viewModel.response?.timeSeries
                {
                    VStack(spacing: 10) {
                        Text("Ticker: \(metaData.symbol)")
                            .font(.title)
                            .foregroundColor(.blue)

                        LineChartView(dataPoints: getPriceData(timeSeries: timeSeries))
                            .frame(height: 200)
                            .padding()

                        PriceSummaryView(timeSeries: timeSeries)
                            .padding()

                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.cyan.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding()
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            viewModel.fetchStocks(for: "AAPL")
        }
    }

    func getPriceData(timeSeries: [String: TimeSeries]) -> [Double] {
        timeSeries.sorted(by: { $0.key < $1.key }).compactMap { (_, series) in
            guard let openPrice = Double(series.open) else { return nil }
            return openPrice
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearch: (String) -> Void

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 10)

            Button(action: {
                onSearch(text)
            }) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.primary)
                    .padding(.trailing, 10)
            }
        }
    }
}

struct LineChartView: View {
    var dataPoints: [Double]

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for (index, point) in dataPoints.enumerated() {
                    let xPosition = geometry.size.width / CGFloat(dataPoints.count - 1) * CGFloat(index)
                    let yPosition = geometry.size.height * CGFloat(1 - (point / dataPoints.max()!))

                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
            }
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}

struct PriceSummaryView: View {
    var timeSeries: [String: TimeSeries]

    var body: some View {
        HStack {
            Spacer()
            Text("Highest: \(formatPrice(getHighestPrice(timeSeries: timeSeries)))")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text("Lowest: \(formatPrice(getLowestPrice(timeSeries: timeSeries)))")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private func getHighestPrice(timeSeries: [String: TimeSeries]) -> Double {
        guard let highestPrice = timeSeries.max(by: { $0.value.high < $1.value.high })?.value.high,
              let highestPriceDouble = Double(highestPrice)
        else {
            return 0.0
        }
        return highestPriceDouble
    }

    private func getLowestPrice(timeSeries: [String: TimeSeries]) -> Double {
        guard let lowestPrice = timeSeries.min(by: { $0.value.low < $1.value.low })?.value.low,
              let lowestPriceDouble = Double(lowestPrice)
        else {
            return 0.0
        }
        return lowestPriceDouble
    }

    func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? ""
    }
}
