import Foundation
import SwiftHash

/// Allow storing primitive and image
final class PrimitiveStorage {
  let internalStorage: StorageAware

  init(storage: StorageAware) {
    self.internalStorage = storage
  }
}

extension PrimitiveStorage: StorageAware {
  public func entry<T: Codable>(forKey key: String) throws -> Entry<T> {
    return try internalStorage.entry(forKey: key)
  }

  public func removeObject(forKey key: String) throws {
    try internalStorage.removeObject(forKey: key)
  }

  public func setObject<T: Codable>(_ object: T, forKey key: String,
                                    expiry: Expiry? = nil) throws {
    guard isPrimitive(type: T.self) else {
      try internalStorage.setObject(object, forKey: key, expiry: expiry)
      return
    }

    switch object {
    case let object as Image:
      let wrapper = ImageWrapper(image: object)
      try internalStorage.setObject(wrapper, forKey: key, expiry: expiry)
    default:
      let wrapper = PrimitiveWrapper(value: object)
      try internalStorage.setObject(wrapper, forKey: key, expiry: expiry)
    }
  }

  public func removeAll() throws {
    try internalStorage.removeAll()
  }

  public func removeExpiredObjects() throws {
    try internalStorage.removeExpiredObjects()
  }
}

extension PrimitiveStorage {
  func isPrimitive<T>(type: T.Type) -> Bool {
    let primitives: [Any.Type] = [
      Image.self,
      Bool.self, [Bool].self,
      String.self, [String].self,
      Int.self, [Int].self,
      Float.self, [Float].self,
      Double.self, [Double].self
    ]

    return primitives.contains(where: { $0.self == type.self })
  }
}
