/*
  Copyright (c) 2017 M.I. Hollemans

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
*/

import Foundation
import Accelerate
import CoreImage

/**
  Creates a RGB pixel buffer of the specified width and height.
*/
public func createPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
  var pixelBuffer: CVPixelBuffer?
  let status = CVPixelBufferCreate(nil, width, height,
                                   kCVPixelFormatType_32BGRA, nil,
                                   &pixelBuffer)
  if status != kCVReturnSuccess {
    print("Error: could not create pixel buffer", status)
    return nil
  }
  return pixelBuffer
}

/**
  First crops the pixel buffer, then resizes it.
*/
public func resizePixelBuffer(_ srcPixelBuffer: CVPixelBuffer,
                              cropX: Int,
                              cropY: Int,
                              cropWidth: Int,
                              cropHeight: Int,
                              scaleWidth: Int,
                              scaleHeight: Int) -> CVPixelBuffer? {
  let flags = CVPixelBufferLockFlags(rawValue: 0)
  guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(srcPixelBuffer, flags) else {
    return nil
  }
  defer { CVPixelBufferUnlockBaseAddress(srcPixelBuffer, flags) }

  guard let srcData = CVPixelBufferGetBaseAddress(srcPixelBuffer) else {
    print("Error: could not get pixel buffer base address")
    return nil
  }
  let srcBytesPerRow = CVPixelBufferGetBytesPerRow(srcPixelBuffer)
  let offset = cropY*srcBytesPerRow + cropX*4
  var srcBuffer = vImage_Buffer(data: srcData.advanced(by: offset),
                                height: vImagePixelCount(cropHeight),
                                width: vImagePixelCount(cropWidth),
                                rowBytes: srcBytesPerRow)

  let destBytesPerRow = scaleWidth*4
  guard let destData = malloc(scaleHeight*destBytesPerRow) else {
    print("Error: out of memory")
    return nil
  }
  var destBuffer = vImage_Buffer(data: destData,
                                 height: vImagePixelCount(scaleHeight),
                                 width: vImagePixelCount(scaleWidth),
                                 rowBytes: destBytesPerRow)

  let error = vImageScale_ARGB8888(&srcBuffer, &destBuffer, nil, vImage_Flags(0))
  if error != kvImageNoError {
    print("Error:", error)
    free(destData)
    return nil
  }

  let releaseCallback: CVPixelBufferReleaseBytesCallback = { _, ptr in
    if let ptr = ptr {
      free(UnsafeMutableRawPointer(mutating: ptr))
    }
  }

  let pixelFormat = CVPixelBufferGetPixelFormatType(srcPixelBuffer)
  var dstPixelBuffer: CVPixelBuffer?
  let status = CVPixelBufferCreateWithBytes(nil, scaleWidth, scaleHeight,
                                            pixelFormat, destData,
                                            destBytesPerRow, releaseCallback,
                                            nil, nil, &dstPixelBuffer)
  if status != kCVReturnSuccess {
    print("Error: could not create new pixel buffer")
    free(destData)
    return nil
  }
  return dstPixelBuffer
}

/**
  Resizes a CVPixelBuffer to a new width and height.
*/
public func resizePixelBuffer(_ pixelBuffer: CVPixelBuffer,
                              width: Int, height: Int) -> CVPixelBuffer? {
  return resizePixelBuffer(pixelBuffer, cropX: 0, cropY: 0,
                           cropWidth: CVPixelBufferGetWidth(pixelBuffer),
                           cropHeight: CVPixelBufferGetHeight(pixelBuffer),
                           scaleWidth: width, scaleHeight: height)
}

/**
  Resizes a CVPixelBuffer to a new width and height.
*/
public func resizePixelBuffer(_ pixelBuffer: CVPixelBuffer,
                              width: Int, height: Int,
                              output: CVPixelBuffer, context: CIContext) {
  let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
  let sx = CGFloat(width) / CGFloat(CVPixelBufferGetWidth(pixelBuffer))
  let sy = CGFloat(height) / CGFloat(CVPixelBufferGetHeight(pixelBuffer))
  let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
  let scaledImage = ciImage.transformed(by: scaleTransform)
  context.render(scaledImage, to: output)
}

/**
  Rotates CVPixelBuffer by the provided factor of 90 counterclock-wise.
*/
public func rotate90PixelBuffer(_ srcPixelBuffer: CVPixelBuffer, factor: UInt8) -> CVPixelBuffer? {
  let flags = CVPixelBufferLockFlags(rawValue: 0)
  guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(srcPixelBuffer, flags) else {
    return nil
  }
  defer { CVPixelBufferUnlockBaseAddress(srcPixelBuffer, flags) }

  guard let srcData = CVPixelBufferGetBaseAddress(srcPixelBuffer) else {
    print("Error: could not get pixel buffer base address")
    return nil
  }
  let sourceWidth = CVPixelBufferGetWidth(srcPixelBuffer)
  let sourceHeight = CVPixelBufferGetHeight(srcPixelBuffer)
  var destWidth = sourceHeight
  var destHeight = sourceWidth
  var color = UInt8(0)

  if factor % 2 == 0 {
    destWidth = sourceWidth
    destHeight = sourceHeight
  }

  let srcBytesPerRow = CVPixelBufferGetBytesPerRow(srcPixelBuffer)
  var srcBuffer = vImage_Buffer(data: srcData,
                                height: vImagePixelCount(sourceHeight),
                                width: vImagePixelCount(sourceWidth),
                                rowBytes: srcBytesPerRow)

  let destBytesPerRow = destWidth*4
  guard let destData = malloc(destHeight*destBytesPerRow) else {
    print("Error: out of memory")
    return nil
  }
  var destBuffer = vImage_Buffer(data: destData,
                                 height: vImagePixelCount(destHeight),
                                 width: vImagePixelCount(destWidth),
                                 rowBytes: destBytesPerRow)

  let error = vImageRotate90_ARGB8888(&srcBuffer, &destBuffer, factor, &color, vImage_Flags(0))
  if error != kvImageNoError {
    print("Error:", error)
    free(destData)
    return nil
  }

  let releaseCallback: CVPixelBufferReleaseBytesCallback = { _, ptr in
    if let ptr = ptr {
      free(UnsafeMutableRawPointer(mutating: ptr))
    }
  }

  let pixelFormat = CVPixelBufferGetPixelFormatType(srcPixelBuffer)
  var dstPixelBuffer: CVPixelBuffer?
  let status = CVPixelBufferCreateWithBytes(nil, destWidth, destHeight,
                                            pixelFormat, destData,
                                            destBytesPerRow, releaseCallback,
                                            nil, nil, &dstPixelBuffer)
  if status != kCVReturnSuccess {
    print("Error: could not create new pixel buffer")
    free(destData)
    return nil
  }
  return dstPixelBuffer
}

/**
 Copies a CVPixelBuffer to a new CVPixelBuffer backed by an IOSurface compatible with Metal
 If CVMetalTextureCacheCreateTextureFromImage is failing then make sure you have an IOSurface Backed CVPixelBuffer
 For other options see: https://developer.apple.com/documentation/metal/mixing_metal_and_opengl_rendering_in_a_view
 - String(kCVPixelBufferOpenGLCompatibilityKey): true,
 - String(kCVPixelBufferIOSurfacePropertiesKey): [
     "IOSurfaceOpenGLESFBOCompatibility": true,
     "IOSurfaceOpenGLESTextureCompatibility": true,
     "IOSurfaceCoreAnimationCompatibility": true
   ]
 */
func copyToIOSurfaceBackedPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
  let pixelBufferAttributes = [
    String(kCVPixelBufferMetalCompatibilityKey): true
    ]
  return pixelBuffer.deepCopyWithAttributes(pixelBufferAttributes)
}

extension CVPixelBuffer {
  /**
   Copies a CVPixelBuffer to a new CVPixelBuffer with no options
   */
  func deepCopy() -> CVPixelBuffer? {
    let emptyAttributes: [String: Any] = [:]
    return self.deepCopyWithAttributes(emptyAttributes)
  }

  /**
   Copies a CVPixelBuffer to a new CVPixelBuffer with allowing options
   See: https://developer.apple.com/library/archive/qa/qa1781/_index.html
   */
  func deepCopyWithAttributes(_ attributes: [String: Any]) -> CVPixelBuffer? {
    let sourceFlag: CVPixelBufferLockFlags = .readOnly
    guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(self, sourceFlag) else {
      return nil
    }
    defer { CVPixelBufferUnlockBaseAddress(self, sourceFlag) }

    var combinedAttributes: [String: Any] = [:]

    // copy attachment attributes
    if let attachments = CVBufferGetAttachments(self, .shouldPropagate) as? [String: Any] {
      for (key, value) in attachments {
        combinedAttributes[key] = value
      }
    }

    // add user attributes
    let attributesCFDict = combinedAttributes.merging(attributes) { $1 } as CFDictionary

    var _copy: CVPixelBuffer?
    CVPixelBufferCreate(
      nil,
      CVPixelBufferGetWidth(self),
      CVPixelBufferGetHeight(self),
      CVPixelBufferGetPixelFormatType(self),
      attributesCFDict,
      &_copy
    )

    guard let copy = _copy else { fatalError() }

    CVPixelBufferLockBaseAddress(copy, CVPixelBufferLockFlags(rawValue: 0))

    // important as plane 0 is a valid plane
    // ClosedRange from 0 -> max(0, count-1)
    for plane in 0...max(0, CVPixelBufferGetPlaneCount(self) - 1) {
      let dest = CVPixelBufferGetBaseAddressOfPlane(copy, plane)
      let source = CVPixelBufferGetBaseAddressOfPlane(self, plane)
      let height = CVPixelBufferGetHeightOfPlane(self, plane)
      let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(self, plane)
      let bytesPerRowDst = CVPixelBufferGetBytesPerRowOfPlane(copy, plane)

      for h in 0..<height {
        memcpy(
          dest?.advanced(by: h*bytesPerRowDst),
          source?.advanced(by: h*bytesPerRow),
          bytesPerRow
        )
      }
    }

    CVPixelBufferUnlockBaseAddress(copy, CVPixelBufferLockFlags(rawValue: 0))

    return copy
  }
}
