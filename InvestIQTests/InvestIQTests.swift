@testable import InvestIQ
import XCTest

class InvestIQTests: XCTestCase {
    var viewModel: StockViewModel!

    override func setUpWithError() throws {
        viewModel = StockViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testFetchStocks_givenSymbol_fetchesStocks() {
        let expectation = XCTestExpectation(description: "Fetch stocks expectation")
        let symbol = "AAPL"
        viewModel.fetchStocks(for: symbol)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertNotNil(self.viewModel.response, "Response should not be nil after fetching stocks")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testGetPriceData_givenTimeSeries_returnsDataPoints() {
        let timeSeries = ["2022-01-01": TimeSeries(open: "100.00", high: "110.00", low: "90.00", close: "105.00", volume: "100000")]
        let dataPoints = ContentView().getPriceData(timeSeries: timeSeries)
        XCTAssertEqual(dataPoints, [100.00], "Data points should match expected values")
    }

    func testFormatPrice_givenPriceAndTimeSeries_formatsPriceCorrectly() {
        let price = 100.00
        let timeSeries = ["2022-01-01": TimeSeries(open: "100.00", high: "110.00", low: "90.00", close: "105.00", volume: "100000")]
        let formattedPrice = PriceSummaryView(timeSeries: timeSeries).formatPrice(price)
        XCTAssertEqual(formattedPrice, "$ 100.00")
    }
}
