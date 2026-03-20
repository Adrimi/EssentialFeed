//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by adrian.szymanowski on 12/10/2020.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }

    func test_getFromURL_performsGETRequestWithURL() async {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        let task = Task {
            try? await makeSUT().get(from: url)
        }

        await fulfillment(of: [exp], timeout: 1.0)
        _ = await task.result
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() async {
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.stub(data: nil, response: nil, error: nil, requestObserver: nil) { _ in
            exp.fulfill()
        }

        let task = Task {
            try await makeSUT().get(from: anyURL())
        }

        await fulfillment(of: [exp], timeout: 1.0)
        task.cancel()
        let receivedError = await resultError(for: task) as NSError?
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    func test_getFromURL_failsOnRequestError() async {
        let requestError = anyNSError()
        let receivedError = await resultErrorFor((data: nil, response: nil, error: requestError))

        XCTAssertNotNil(receivedError)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() async {
        let error1 = await resultErrorFor((data: nil, response: nil, error: nil))
        let error2 = await resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil))
        let error3 = await resultErrorFor((data: anyData(), response: nil, error: nil))
        let error4 = await resultErrorFor((data: anyData(), response: nil, error: anyNSError()))
        let error5 = await resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        let error6 = await resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        let error7 = await resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        let error8 = await resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        let error9 = await resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil))

        XCTAssertNotNil(error1)
        XCTAssertNotNil(error2)
        XCTAssertNotNil(error3)
        XCTAssertNotNil(error4)
        XCTAssertNotNil(error5)
        XCTAssertNotNil(error6)
        XCTAssertNotNil(error7)
        XCTAssertNotNil(error8)
        XCTAssertNotNil(error9)
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() async {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = await resultValuesFor((data: data, response: response, error: nil))
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponse_withNilData() async {
        let response = anyHTTPURLResponse()
        
        let receivedValues = await resultValuesFor((data: nil, response: response, error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }

    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, file: StaticString = #filePath, line: UInt = #line) async -> Error? {
        let result = await resultFor(values, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        case let .success(values):
            XCTFail("Expected failure, got \(values) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath, line: UInt = #line) async -> (data: Data, response: HTTPURLResponse)? {
        let result = await resultFor(values, file: file, line: line)
        switch result {
        case let .success((data, response)):
            return (data, response)
        case let .failure(error):
            XCTFail("Expected success, got \(error) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultError(for task: Task<(Data, HTTPURLResponse), Error>, file: StaticString = #filePath, line: UInt = #line) async -> Error? {
        do {
            _ = try await task.value
            XCTFail("Expected failure, got success instead", file: file, line: line)
            return nil
        } catch {
            return error
        }
    }

    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, file: StaticString = #filePath, line: UInt = #line) async -> Result<(Data, HTTPURLResponse), Error> {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        let sut = makeSUT(file: file, line: line)

        do {
            return .success(try await sut.get(from: anyURL()))
        } catch {
            return .failure(error)
        }
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}
