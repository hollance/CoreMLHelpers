import XCTest
import CoreML
@testable import CoreMLHelpers

class MultiArrayTests: XCTestCase {
  func testMultiArrayFromCoreMLArray() {
    let coreMLArray = try! MLMultiArray(shape: [3, 4, 2], dataType: .double)
    coreMLArray[[1, 2, 0] as [NSNumber]] = NSNumber(value: 3.14159)
    print(coreMLArray)

    var m = MultiArray<Double>(coreMLArray)
    XCTAssertEqual(m.shape.count, 3)
    XCTAssertEqual(m.shape[0], 3)
    XCTAssertEqual(m.shape[1], 4)
    XCTAssertEqual(m.shape[2], 2)

    XCTAssertEqual(m[1, 2, 0], 3.14159)

    m[1, 2, 0] = 2.71828
    XCTAssertEqual(m[1, 2, 0], 2.71828)
  }

  func testMultiArray() {
    var m = MultiArray<Float>(shape: [3, 4, 2])
    print(m.shape)

    for i in 0..<m.count {
      m[i] = Float(i)
    }
    print(m)

    let t = m.transposed([1, 2, 0])
    print(t.shape)
    print(t)

    let r = m.reshaped([8, 3])
    print(r.shape)
    print(r)
  }
}
