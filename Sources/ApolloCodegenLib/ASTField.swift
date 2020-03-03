import Foundation

/// A field with data on any item.
class ASTField: Codable {
  
  /// An argument which can be passed along with a field
  class Argument: Codable {
    /// The name of the argument
    let name: String
    
    /// The value of the argument - this is generally a dictionary or a string, but it's set up as a JSONValue to allow flexibility.
    let value: JSONValue
    
    /// The type of the argument
    let type: ASTVariableType
  }
  
  /// The name of the field that will come back in the response. Will generally be the same as `fieldName` unless aliased.
  let responseName: String
  
  /// The name of the field in the schema
  let fieldName: String
  
  /// The type of this field
  let type: ASTVariableType
  
  /// If this field is conditional
  let isConditional: Bool
  
  /// [optional] Any description of this field
  let description: String?
  
  /// [optional] If this field is deprecated. If this is nil, the field is **NOT** deprecated.
  let isDeprecated: Bool?
  
  /// [optional] Any arguments to pass along with this field
  let args: [ASTField.Argument]?
  
  /// [optional] Any sub-fields which should be passed along with this field
  let fields: [ASTField]?
  
  /// [optional] The names of any fragments referenced at this level of the field
  let fragmentSpreads: [String]?
  
  /// [optional] Any Fragments defined inline at this level
  let inlineFragments: [ASTInlineFragment]?
}
