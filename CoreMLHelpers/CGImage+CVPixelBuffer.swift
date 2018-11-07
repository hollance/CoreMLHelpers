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

#if canImport(CoreGraphics)

import CoreGraphics
import CoreImage
import VideoToolbox

extension CGImage {
    /**
     Creates a new CGImage from a CVPixelBuffer.
     NOTE: This only works for RGB pixel buffers, not for grayscale.
     */
    public static func create(pixelBuffer: CVPixelBuffer) -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        return cgImage
    }
    
    /**
     Creates a new UIImage from a CVPixelBuffer, using Core Image.
     */
    public static func create(pixelBuffer: CVPixelBuffer, context: CIContext) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let rect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer),
                          height: CVPixelBufferGetHeight(pixelBuffer))
        
        return context.createCGImage(ciImage, from: rect)
    }
}

extension CGImage {
    /**
     Creates a new CGImage from an array of RGBA bytes.
     */
    @nonobjc public class func fromByteArrayRGBA(_ bytes: [UInt8],
                                                 width: Int,
                                                 height: Int) -> CGImage? {
        return fromByteArray(bytes, width: width, height: height,
                             bytesPerRow: width * 4,
                             colorSpace: CGColorSpaceCreateDeviceRGB(),
                             alphaInfo: .premultipliedLast)
    }
    
    /**
     Creates a new CGImage from an array of grayscale bytes.
     */
    @nonobjc public class func fromByteArrayGray(_ bytes: [UInt8],
                                                 width: Int,
                                                 height: Int) -> CGImage? {
        return fromByteArray(bytes, width: width, height: height,
                             bytesPerRow: width,
                             colorSpace: CGColorSpaceCreateDeviceGray(),
                             alphaInfo: .none)
    }
    
    @nonobjc class func fromByteArray(_ bytes: [UInt8],
                                      width: Int,
                                      height: Int,
                                      bytesPerRow: Int,
                                      colorSpace: CGColorSpace,
                                      alphaInfo: CGImageAlphaInfo) -> CGImage? {
        return bytes.withUnsafeBytes { ptr in
            let context = CGContext(data: UnsafeMutableRawPointer(mutating: ptr.baseAddress!),
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: alphaInfo.rawValue)
            return context?.makeImage()
        }
    }
}

#endif
