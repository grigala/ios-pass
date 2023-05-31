// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: item_v1.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct ProtonPassItemV1_ItemNote {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ProtonPassItemV1_ItemLogin {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var username: String = String()

  public var password: String = String()

  public var urls: [String] = []

  public var totpUri: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ProtonPassItemV1_ItemAlias {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// Client extras
public struct ProtonPassItemV1_AllowedAndroidApp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var packageName: String = String()

  public var hashes: [String] = []

  public var appName: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ProtonPassItemV1_AndroidSpecific {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var allowedApps: [ProtonPassItemV1_AllowedAndroidApp] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ProtonPassItemV1_PlatformSpecific {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var android: ProtonPassItemV1_AndroidSpecific {
    get {return _android ?? ProtonPassItemV1_AndroidSpecific()}
    set {_android = newValue}
  }
  /// Returns true if `android` has been explicitly set.
  public var hasAndroid: Bool {return self._android != nil}
  /// Clears the value of `android`. Subsequent reads from it will return its default value.
  public mutating func clearAndroid() {self._android = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _android: ProtonPassItemV1_AndroidSpecific? = nil
}

public struct ProtonPassItemV1_ExtraTotp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var totpUri: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ProtonPassItemV1_ExtraTextField {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var content: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ProtonPassItemV1_ExtraHiddenField {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var content: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ProtonPassItemV1_ExtraField {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var fieldName: String = String()

  public var content: ProtonPassItemV1_ExtraField.OneOf_Content? = nil

  public var totp: ProtonPassItemV1_ExtraTotp {
    get {
      if case .totp(let v)? = content {return v}
      return ProtonPassItemV1_ExtraTotp()
    }
    set {content = .totp(newValue)}
  }

  public var text: ProtonPassItemV1_ExtraTextField {
    get {
      if case .text(let v)? = content {return v}
      return ProtonPassItemV1_ExtraTextField()
    }
    set {content = .text(newValue)}
  }

  public var hidden: ProtonPassItemV1_ExtraHiddenField {
    get {
      if case .hidden(let v)? = content {return v}
      return ProtonPassItemV1_ExtraHiddenField()
    }
    set {content = .hidden(newValue)}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_Content: Equatable {
    case totp(ProtonPassItemV1_ExtraTotp)
    case text(ProtonPassItemV1_ExtraTextField)
    case hidden(ProtonPassItemV1_ExtraHiddenField)

  #if !swift(>=4.1)
    public static func ==(lhs: ProtonPassItemV1_ExtraField.OneOf_Content, rhs: ProtonPassItemV1_ExtraField.OneOf_Content) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.totp, .totp): return {
        guard case .totp(let l) = lhs, case .totp(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.text, .text): return {
        guard case .text(let l) = lhs, case .text(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.hidden, .hidden): return {
        guard case .hidden(let l) = lhs, case .hidden(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}
}

public struct ProtonPassItemV1_Metadata {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var name: String = String()

  public var note: String = String()

  public var itemUuid: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ProtonPassItemV1_Content {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var content: ProtonPassItemV1_Content.OneOf_Content? = nil

  public var note: ProtonPassItemV1_ItemNote {
    get {
      if case .note(let v)? = content {return v}
      return ProtonPassItemV1_ItemNote()
    }
    set {content = .note(newValue)}
  }

  public var login: ProtonPassItemV1_ItemLogin {
    get {
      if case .login(let v)? = content {return v}
      return ProtonPassItemV1_ItemLogin()
    }
    set {content = .login(newValue)}
  }

  public var alias: ProtonPassItemV1_ItemAlias {
    get {
      if case .alias(let v)? = content {return v}
      return ProtonPassItemV1_ItemAlias()
    }
    set {content = .alias(newValue)}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_Content: Equatable {
    case note(ProtonPassItemV1_ItemNote)
    case login(ProtonPassItemV1_ItemLogin)
    case alias(ProtonPassItemV1_ItemAlias)

  #if !swift(>=4.1)
    public static func ==(lhs: ProtonPassItemV1_Content.OneOf_Content, rhs: ProtonPassItemV1_Content.OneOf_Content) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.note, .note): return {
        guard case .note(let l) = lhs, case .note(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.login, .login): return {
        guard case .login(let l) = lhs, case .login(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.alias, .alias): return {
        guard case .alias(let l) = lhs, case .alias(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}
}

public struct ProtonPassItemV1_Item {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var metadata: ProtonPassItemV1_Metadata {
    get {return _metadata ?? ProtonPassItemV1_Metadata()}
    set {_metadata = newValue}
  }
  /// Returns true if `metadata` has been explicitly set.
  public var hasMetadata: Bool {return self._metadata != nil}
  /// Clears the value of `metadata`. Subsequent reads from it will return its default value.
  public mutating func clearMetadata() {self._metadata = nil}

  public var content: ProtonPassItemV1_Content {
    get {return _content ?? ProtonPassItemV1_Content()}
    set {_content = newValue}
  }
  /// Returns true if `content` has been explicitly set.
  public var hasContent: Bool {return self._content != nil}
  /// Clears the value of `content`. Subsequent reads from it will return its default value.
  public mutating func clearContent() {self._content = nil}

  public var platformSpecific: ProtonPassItemV1_PlatformSpecific {
    get {return _platformSpecific ?? ProtonPassItemV1_PlatformSpecific()}
    set {_platformSpecific = newValue}
  }
  /// Returns true if `platformSpecific` has been explicitly set.
  public var hasPlatformSpecific: Bool {return self._platformSpecific != nil}
  /// Clears the value of `platformSpecific`. Subsequent reads from it will return its default value.
  public mutating func clearPlatformSpecific() {self._platformSpecific = nil}

  public var extraFields: [ProtonPassItemV1_ExtraField] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _metadata: ProtonPassItemV1_Metadata? = nil
  fileprivate var _content: ProtonPassItemV1_Content? = nil
  fileprivate var _platformSpecific: ProtonPassItemV1_PlatformSpecific? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension ProtonPassItemV1_ItemNote: @unchecked Sendable {}
extension ProtonPassItemV1_ItemLogin: @unchecked Sendable {}
extension ProtonPassItemV1_ItemAlias: @unchecked Sendable {}
extension ProtonPassItemV1_AllowedAndroidApp: @unchecked Sendable {}
extension ProtonPassItemV1_AndroidSpecific: @unchecked Sendable {}
extension ProtonPassItemV1_PlatformSpecific: @unchecked Sendable {}
extension ProtonPassItemV1_ExtraTotp: @unchecked Sendable {}
extension ProtonPassItemV1_ExtraTextField: @unchecked Sendable {}
extension ProtonPassItemV1_ExtraHiddenField: @unchecked Sendable {}
extension ProtonPassItemV1_ExtraField: @unchecked Sendable {}
extension ProtonPassItemV1_ExtraField.OneOf_Content: @unchecked Sendable {}
extension ProtonPassItemV1_Metadata: @unchecked Sendable {}
extension ProtonPassItemV1_Content: @unchecked Sendable {}
extension ProtonPassItemV1_Content.OneOf_Content: @unchecked Sendable {}
extension ProtonPassItemV1_Item: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proton_pass_item_v1"

extension ProtonPassItemV1_ItemNote: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ItemNote"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_ItemNote, rhs: ProtonPassItemV1_ItemNote) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_ItemLogin: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ItemLogin"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "username"),
    2: .same(proto: "password"),
    3: .same(proto: "urls"),
    4: .standard(proto: "totp_uri"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.username) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.password) }()
      case 3: try { try decoder.decodeRepeatedStringField(value: &self.urls) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.totpUri) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.username.isEmpty {
      try visitor.visitSingularStringField(value: self.username, fieldNumber: 1)
    }
    if !self.password.isEmpty {
      try visitor.visitSingularStringField(value: self.password, fieldNumber: 2)
    }
    if !self.urls.isEmpty {
      try visitor.visitRepeatedStringField(value: self.urls, fieldNumber: 3)
    }
    if !self.totpUri.isEmpty {
      try visitor.visitSingularStringField(value: self.totpUri, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_ItemLogin, rhs: ProtonPassItemV1_ItemLogin) -> Bool {
    if lhs.username != rhs.username {return false}
    if lhs.password != rhs.password {return false}
    if lhs.urls != rhs.urls {return false}
    if lhs.totpUri != rhs.totpUri {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_ItemAlias: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ItemAlias"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_ItemAlias, rhs: ProtonPassItemV1_ItemAlias) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_AllowedAndroidApp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".AllowedAndroidApp"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "package_name"),
    2: .same(proto: "hashes"),
    3: .standard(proto: "app_name"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.packageName) }()
      case 2: try { try decoder.decodeRepeatedStringField(value: &self.hashes) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.appName) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.packageName.isEmpty {
      try visitor.visitSingularStringField(value: self.packageName, fieldNumber: 1)
    }
    if !self.hashes.isEmpty {
      try visitor.visitRepeatedStringField(value: self.hashes, fieldNumber: 2)
    }
    if !self.appName.isEmpty {
      try visitor.visitSingularStringField(value: self.appName, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_AllowedAndroidApp, rhs: ProtonPassItemV1_AllowedAndroidApp) -> Bool {
    if lhs.packageName != rhs.packageName {return false}
    if lhs.hashes != rhs.hashes {return false}
    if lhs.appName != rhs.appName {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_AndroidSpecific: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".AndroidSpecific"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "allowed_apps"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.allowedApps) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.allowedApps.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.allowedApps, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_AndroidSpecific, rhs: ProtonPassItemV1_AndroidSpecific) -> Bool {
    if lhs.allowedApps != rhs.allowedApps {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_PlatformSpecific: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".PlatformSpecific"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "android"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._android) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._android {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_PlatformSpecific, rhs: ProtonPassItemV1_PlatformSpecific) -> Bool {
    if lhs._android != rhs._android {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_ExtraTotp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExtraTotp"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "totp_uri"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.totpUri) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.totpUri.isEmpty {
      try visitor.visitSingularStringField(value: self.totpUri, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_ExtraTotp, rhs: ProtonPassItemV1_ExtraTotp) -> Bool {
    if lhs.totpUri != rhs.totpUri {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_ExtraTextField: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExtraTextField"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "content"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.content) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_ExtraTextField, rhs: ProtonPassItemV1_ExtraTextField) -> Bool {
    if lhs.content != rhs.content {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_ExtraHiddenField: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExtraHiddenField"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "content"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.content) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_ExtraHiddenField, rhs: ProtonPassItemV1_ExtraHiddenField) -> Bool {
    if lhs.content != rhs.content {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_ExtraField: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExtraField"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "field_name"),
    2: .same(proto: "totp"),
    3: .same(proto: "text"),
    4: .same(proto: "hidden"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.fieldName) }()
      case 2: try {
        var v: ProtonPassItemV1_ExtraTotp?
        var hadOneofValue = false
        if let current = self.content {
          hadOneofValue = true
          if case .totp(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.content = .totp(v)
        }
      }()
      case 3: try {
        var v: ProtonPassItemV1_ExtraTextField?
        var hadOneofValue = false
        if let current = self.content {
          hadOneofValue = true
          if case .text(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.content = .text(v)
        }
      }()
      case 4: try {
        var v: ProtonPassItemV1_ExtraHiddenField?
        var hadOneofValue = false
        if let current = self.content {
          hadOneofValue = true
          if case .hidden(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.content = .hidden(v)
        }
      }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.fieldName.isEmpty {
      try visitor.visitSingularStringField(value: self.fieldName, fieldNumber: 1)
    }
    switch self.content {
    case .totp?: try {
      guard case .totp(let v)? = self.content else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case .text?: try {
      guard case .text(let v)? = self.content else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }()
    case .hidden?: try {
      guard case .hidden(let v)? = self.content else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_ExtraField, rhs: ProtonPassItemV1_ExtraField) -> Bool {
    if lhs.fieldName != rhs.fieldName {return false}
    if lhs.content != rhs.content {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_Metadata: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Metadata"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "note"),
    3: .standard(proto: "item_uuid"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.note) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.itemUuid) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.note.isEmpty {
      try visitor.visitSingularStringField(value: self.note, fieldNumber: 2)
    }
    if !self.itemUuid.isEmpty {
      try visitor.visitSingularStringField(value: self.itemUuid, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_Metadata, rhs: ProtonPassItemV1_Metadata) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.note != rhs.note {return false}
    if lhs.itemUuid != rhs.itemUuid {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_Content: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Content"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    2: .same(proto: "note"),
    3: .same(proto: "login"),
    4: .same(proto: "alias"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 2: try {
        var v: ProtonPassItemV1_ItemNote?
        var hadOneofValue = false
        if let current = self.content {
          hadOneofValue = true
          if case .note(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.content = .note(v)
        }
      }()
      case 3: try {
        var v: ProtonPassItemV1_ItemLogin?
        var hadOneofValue = false
        if let current = self.content {
          hadOneofValue = true
          if case .login(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.content = .login(v)
        }
      }()
      case 4: try {
        var v: ProtonPassItemV1_ItemAlias?
        var hadOneofValue = false
        if let current = self.content {
          hadOneofValue = true
          if case .alias(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.content = .alias(v)
        }
      }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    switch self.content {
    case .note?: try {
      guard case .note(let v)? = self.content else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case .login?: try {
      guard case .login(let v)? = self.content else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }()
    case .alias?: try {
      guard case .alias(let v)? = self.content else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_Content, rhs: ProtonPassItemV1_Content) -> Bool {
    if lhs.content != rhs.content {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtonPassItemV1_Item: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Item"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "metadata"),
    2: .same(proto: "content"),
    3: .standard(proto: "platform_specific"),
    4: .standard(proto: "extra_fields"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._metadata) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._content) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._platformSpecific) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.extraFields) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._metadata {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._content {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._platformSpecific {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if !self.extraFields.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.extraFields, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ProtonPassItemV1_Item, rhs: ProtonPassItemV1_Item) -> Bool {
    if lhs._metadata != rhs._metadata {return false}
    if lhs._content != rhs._content {return false}
    if lhs._platformSpecific != rhs._platformSpecific {return false}
    if lhs.extraFields != rhs.extraFields {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
