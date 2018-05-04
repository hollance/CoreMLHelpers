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

  func testMultiArrayTransposeReshape() {
    let coreMLArray = try! MLMultiArray(shape: [1, 1, 48, 17, 27], dataType: .double)
    let ptr = UnsafeMutablePointer<Double>(OpaquePointer(coreMLArray.dataPointer))
    for i in 0..<1*1*48*17*27 {
      ptr.advanced(by: i).pointee = Double(i)
    }

    var a = MultiArray<Double>(coreMLArray)
    XCTAssertEqual(a.shape, [1, 1, 48, 17, 27])
    XCTAssertEqual(a.strides, [22032, 22032, 459, 27, 1])

    let expected_a: [[Double]] = [[  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10,
                                    11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
                                    22, 23, 24, 25, 26 ],
                                  [ 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37,
                                    38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
                                    49, 50, 51, 52, 53]]
    for j in 0..<2 {
      for i in 0..<27 {
        XCTAssertEqual(a[0, 0, 0, j, i], expected_a[j][i])
      }
    }

    var b = a.transposed([0, 1, 3, 4, 2])
    XCTAssertEqual(b.shape, [1, 1, 17, 27, 48])
    XCTAssertEqual(b.strides, [22032, 22032, 27, 1, 459])

    let expected_b: [[Double]] = [[     0,   459,   918,  1377,  1836,  2295,  2754,  3213,  3672,
                                     4131,  4590,  5049,  5508,  5967,  6426,  6885,  7344,  7803,
                                     8262,  8721,  9180,  9639, 10098, 10557, 11016, 11475, 11934,
                                    12393, 12852, 13311, 13770, 14229, 14688, 15147, 15606, 16065,
                                    16524, 16983, 17442, 17901, 18360, 18819, 19278, 19737, 20196,
                                    20655, 21114, 21573 ],
                                  [     1,   460,   919,  1378,  1837,  2296,  2755,  3214,  3673,
                                     4132,  4591,  5050,  5509,  5968,  6427,  6886,  7345,  7804,
                                     8263,  8722,  9181,  9640, 10099, 10558, 11017, 11476, 11935,
                                    12394, 12853, 13312, 13771, 14230, 14689, 15148, 15607, 16066,
                                    16525, 16984, 17443, 17902, 18361, 18820, 19279, 19738, 20197,
                                    20656, 21115, 21574 ]]
    for j in 0..<2 {
      for i in 0..<48 {
        XCTAssertEqual(b[0, 0, 0, j, i], expected_b[j][i])
      }
    }

    let expected_b_end: [[Double]] = [[    26,   485,   944,  1403,  1862,  2321,  2780,  3239,  3698,
                                         4157,  4616,  5075,  5534,  5993,  6452,  6911,  7370,  7829,
                                         8288,  8747,  9206,  9665, 10124, 10583, 11042, 11501, 11960,
                                        12419, 12878, 13337, 13796, 14255, 14714, 15173, 15632, 16091,
                                        16550, 17009, 17468, 17927, 18386, 18845, 19304, 19763, 20222,
                                        20681, 21140, 21599 ]]

    for j in 0..<1 {
      for i in 0..<48 {
        XCTAssertEqual(b[0, 0, 0, j + 26, i], expected_b_end[j][i])
      }
    }

    var c = b.reshaped([5508, 4])
    XCTAssertEqual(c.shape, [5508, 4])
    XCTAssertEqual(c.strides, [4, 1])

    let expected_c: [[Double]] = [[    0,  459,  918, 1377 ],
                                  [ 1836, 2295, 2754, 3213 ]]
    for j in 0..<2 {
      for i in 0..<4 {
        XCTAssertEqual(c[j, i], expected_c[j][i])
      }
    }

    let expected_c_end: [[Double]] = [[20654, 21113, 21572, 22031]]

    for j in 0..<1 {
      for i in 0..<4 {
        print(c[j + 5507, i])
        XCTAssertEqual(c[j + 5507, i], expected_c_end[j][i])
      }
    }

    //print(c)
  }
}
