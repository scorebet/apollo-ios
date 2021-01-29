//
//  ApolloSchemaTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
import ApolloTestSupport
@testable import ApolloCodegenLib

class ApolloSchemaTests: XCTestCase {
    
  func testCreatingOptionsWithDefaultParameters() throws {
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    let options = ApolloSchemaOptions(endpointURL: TestURL.starWarsServer.url,
                                      outputFolderURL: sourceRoot)
    
    let expectedOutputURL = sourceRoot.appendingPathComponent("schema.json")
    XCTAssertEqual(options.endpointURL, TestURL.starWarsServer.url)
    XCTAssertEqual(options.outputURL, expectedOutputURL)
    XCTAssertNil(options.apiKey)
    XCTAssertTrue(options.headers.isEmpty)
    
    XCTAssertEqual(options.arguments, [
        "client:download-schema",
        "--endpoint=http://localhost:8080/graphql",
        "'\(expectedOutputURL.path)'"
    ])
  }
  
  func testCreatingOptionsWithAllParameters() throws {
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    let apiKey = "Fake_API_Key"
    let firstHeader = "Authorization: Bearer tokenGoesHere"
    let secondHeader = "Custom-Header: Custom_Customer"
    let headers = [firstHeader, secondHeader]
    
    let options = ApolloSchemaOptions(schemaFileName: "different_name",
                                      schemaFileType: .schemaDefinitionLanguage,
                                      apiKey: apiKey,
                                      endpointURL: TestURL.starWarsServer.url,
                                      headers: headers,
                                      outputFolderURL: sourceRoot)
    XCTAssertEqual(options.apiKey, apiKey)
    XCTAssertEqual(options.endpointURL, TestURL.starWarsServer.url)
    XCTAssertEqual(options.headers, headers)
    
    let expectedOutputURL = sourceRoot.appendingPathComponent("different_name.graphql")
    XCTAssertEqual(options.outputURL, expectedOutputURL)

    XCTAssertEqual(options.arguments, [
        "client:download-schema",
        "--endpoint=http://localhost:8080/graphql",
        "--key=\(apiKey)",
        "'\(expectedOutputURL.path)'",
        "--header='\(firstHeader)'",
        "--header='\(secondHeader)'"
    ])
  }
  
  func testDownloadingSchemaAsJSON() throws {
    let testOutputFolderURL = CodegenTestHelper.outputFolderURL()
    
    let options = ApolloSchemaOptions(endpointURL: TestURL.starWarsServer.url,
                                      outputFolderURL: testOutputFolderURL)
    
    // Delete anything existing at the output URL
    try FileManager.default.apollo.deleteFile(at: options.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: options.outputURL))
    
    let cliFolderURL = CodegenTestHelper.cliFolderURL()

    _ = try ApolloSchemaDownloader.run(with: cliFolderURL,
                                       options: options)
    
    // Does the file now exist?
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: options.outputURL))
    
    // Is it non-empty?
    let data = try Data(contentsOf: options.outputURL)
    XCTAssertFalse(data.isEmpty)
    
    // Is it JSON?
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable:Any])
    
    // Is it schema json?
    _ = try XCTUnwrap(json["__schema"])
    
    // OK delete it now
    try FileManager.default.apollo.deleteFile(at: options.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: options.outputURL))
  }
  
  func testDownloadingSchemaInSchemaDefinitionLanguage() throws {
    let testOutputFolderURL = CodegenTestHelper.outputFolderURL()
    
    let options = ApolloSchemaOptions(schemaFileType: .schemaDefinitionLanguage,
                                      endpointURL: TestURL.starWarsServer.url,
                                      outputFolderURL: testOutputFolderURL)
    
    // Delete anything existing at the output URL
    try FileManager.default.apollo.deleteFile(at: options.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: options.outputURL))

    let cliFolderURL = CodegenTestHelper.cliFolderURL()

    print(try ApolloSchemaDownloader.run(with: cliFolderURL,
                                         options: options))
    
    // Does the file now exist?
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: options.outputURL))
    
    // Is it non-empty?
    let data = try Data(contentsOf: options.outputURL)
    XCTAssertFalse(data.isEmpty)
    
    // It should not be JSON
    XCTAssertNil(try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable:Any])
    
    // OK delete it now
    try FileManager.default.apollo.deleteFile(at: options.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: options.outputURL))
  }
}
