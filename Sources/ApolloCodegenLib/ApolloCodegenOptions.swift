import Foundation

/// An object to hold all the various options for running codegen
public struct ApolloCodegenOptions {
  
  /// Enum to select how you want to export your API files.
  public enum OutputFormat {
    /// Outputs everything into a single file at the given URL.
    /// NOTE: URL must be a file URL
    case singleFile(atFileURL: URL)
    /// Outputs everything into individual files in a folder a the given URL
    /// NOTE: URL must be a folder URL
    case multipleFiles(inFolderAtURL: URL)
  }
  
  /// Enum to select which code generation you wish to use
  public enum CodeGenerationEngine {
    /// The default, tried and true code generation engine
    case typescript
    
    /// The VERY WORK IN PROGRESS Swift code generation engine. Use at your own risk!
    case swiftExperimental
    
    /// The current default for the code generation engine.
    public static var `default`: CodeGenerationEngine {
      .typescript
    }
    
    var targetForApolloTools: String {
      switch self {
      case .typescript:
        return "swift"
      case .swiftExperimental:
        return "json"
      }
    }
  }
  
  let codegenEngine: CodeGenerationEngine
  let includes: String
  let mergeInFieldsFromFragmentSpreads: Bool
  let namespace: String?
  let only: URL?
  let omitDeprecatedEnumCases: Bool
  let operationIDsURL: URL?
  let outputFormat: OutputFormat
  let passthroughCustomScalars: Bool
  let suppressSwiftMultilineStringLiterals: Bool
  let urlToSchemaFile: URL
  
  let downloadTimeout: Double

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - codegenEngine: The code generation engine to use. Defaults to `CodeGenerationEngine.default`
  ///  - includes: Glob of files to search for GraphQL operations. This should be used to find queries *and* any client schema extensions. Defaults to `./**/*.graphql`, which will search for `.graphql` files throughout all subfolders of the folder where the script is run.
  ///  - mergeInFieldsFromFragmentSpreads: Set true to merge fragment fields onto its enclosing type. Defaults to true.
  ///  - namespace: [optional] The namespace to emit generated code into. Defaults to nil.
  ///  - omitDeprecatedEnumCases: Whether deprecated enum cases should be omitted from generated code. Defaults to false.
  ///  - only: [optional] Parse all input files, but only output generated code for the file at this URL if non-nil. Defaults to nil.
  ///  - operationIDsURL: [optional] Path to an operation id JSON map file. If specified, also stores the operation ids (hashes) as properties on operation types. Defaults to nil.
  ///  - outputFormat: The `OutputFormat` enum option to use to output generated code.
  ///  - passthroughCustomScalars: Set true to use your own types for custom scalars. Defaults to false.
  ///  - suppressSwiftMultilineStringLiterals: Don't use multi-line string literals when generating code. Defaults to false.
  ///  - urlToSchemaFile: The URL to your schema file.
  ///  - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.
  public init(codegenEngine: CodeGenerationEngine = .default,
              includes: String = "./**/*.graphql",
              mergeInFieldsFromFragmentSpreads: Bool = true,
              namespace: String? = nil,
              omitDeprecatedEnumCases: Bool = false,
              only: URL? = nil,
              operationIDsURL: URL? = nil,
              outputFormat: OutputFormat,
              passthroughCustomScalars: Bool = false,
              suppressSwiftMultilineStringLiterals: Bool = false,
              urlToSchemaFile: URL,
              downloadTimeout: Double = 30.0) {
    self.codegenEngine = codegenEngine
    self.includes = includes
    self.mergeInFieldsFromFragmentSpreads = mergeInFieldsFromFragmentSpreads
    self.namespace = namespace
    self.omitDeprecatedEnumCases = omitDeprecatedEnumCases
    self.only = only
    self.operationIDsURL = operationIDsURL
    self.outputFormat = outputFormat
    self.passthroughCustomScalars = passthroughCustomScalars
    self.suppressSwiftMultilineStringLiterals = suppressSwiftMultilineStringLiterals
    self.urlToSchemaFile = urlToSchemaFile
    self.downloadTimeout = downloadTimeout
  }
  
  /// Convenience initializer that takes the root folder of a target and generates
  /// code with some default assumptions.
  /// Makes the following assumptions:
  ///   - Schema is at [folder]/schema.json
  ///   - Output is a single file to [folder]/API.swift
  ///   - You want operation IDs generated and output to [folder]/operationIDs.json
  ///
  /// - Parameters:
  ///  - folder: The root of the target.
  ///  - codegenEngine: The code generation engine to use. Defaults to `CodeGenerationEngine.default`
  ///  - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds
  public init(targetRootURL folder: URL,
              codegenEngine: CodeGenerationEngine = .default,
              downloadTimeout: Double = 30.0) {
    let schema = folder.appendingPathComponent("schema.json")
    
    let outputFileURL: URL
    switch codegenEngine {
    case .typescript:
      outputFileURL = folder.appendingPathComponent("API.swift")
    case .swiftExperimental:
      outputFileURL = folder.appendingPathComponent("API.json")
    }
    
    let operationIDsURL = folder.appendingPathComponent("operationIDs.json")
    
    self.init(codegenEngine: codegenEngine,
              operationIDsURL: operationIDsURL,
              outputFormat: .singleFile(atFileURL: outputFileURL),
              urlToSchemaFile: schema,
              downloadTimeout: downloadTimeout)
  }
  
  var arguments: [String] {
    var arguments = [
      "codegen:generate",
      "--target=\(self.codegenEngine.targetForApolloTools)",
      "--addTypename",
      "--includes=\(self.includes)",
      "--localSchemaFile=\(self.urlToSchemaFile.path)"
    ]
    
    if let namespace = self.namespace {
      arguments.append("--namespace=\(namespace)")
    }

    if let only = only {
      arguments.append("--only=\(only.path)")
    }
    
    if let idsURL = self.operationIDsURL {
      arguments.append("--operationIdsPath=\(idsURL.path)")
    }
    
    if self.omitDeprecatedEnumCases {
      arguments.append("--omitDeprecatedEnumCases")
    }
    
    if self.passthroughCustomScalars {
      arguments.append("--passthroughCustomScalars")
    }
    
    if self.mergeInFieldsFromFragmentSpreads {
      arguments.append("--mergeInFieldsFromFragmentSpreads")
    }
    
    if self.suppressSwiftMultilineStringLiterals {
      arguments.append("--suppressSwiftMultilineStringLiterals")
    }
    
    switch self.outputFormat {
    case .singleFile(let fileURL):
      arguments.append(fileURL.path)
    case .multipleFiles(let folderURL):
      arguments.append(folderURL.path)
    }
    
    return arguments
  }
}

extension ApolloCodegenOptions: CustomDebugStringConvertible {
  public var debugDescription: String {
    self.arguments.joined(separator: "\n")
  }
}
