//
//  StringExtensions.swift
//  BLETest
//
//  Created by TY on 2018/04/26.
//  Copyright © 2018年 yamatakajp. All rights reserved.
//

import Foundation
import UIKit
import Compression

extension String {
    func splitInto(_ length: Int) -> [String] {
        var str = self
        for i in 0 ..< (str.count - 1) / max(length, 1) {
            str.insert(",", at: str.index(str.startIndex, offsetBy: (i + 1) * max(length, 1) + i))
        }
        return str.components(separatedBy: ",")
    }
}

extension Data {
    func subdata(in range: ClosedRange<Index>) -> Data {
        return subdata(in: range.lowerBound ..< range.upperBound + 1)
    }
}

extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 1) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }

    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}

//enum LZFSEAction: Int {
//    case Compress
//    case Decompress
//}

//extension NSData {
//    class func compress(data: NSData, action: LZFSEAction) -> NSData {
//
////        let data: NSData = NSData(contentsOfURL: fileURL)!
//
//        data.bytes
//        let sourceBuffer: UnsafePointer<UInt8> = UnsafePointer<UInt8>(data.bytes)
//        let sourceBufferSize: Int = data.length
//
//        let destinationBuffer: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: sourceBufferSize)
//        let destinationBufferSize: Int = sourceBufferSize
//
//        var status: Int
//        switch action {
//        case .Compress:
//            status = compression_encode_buffer(destinationBuffer, destinationBufferSize, sourceBuffer, sourceBufferSize, nil, COMPRESSION_LZFSE)
//        default:
//            status = compression_decode_buffer(destinationBuffer, destinationBufferSize, sourceBuffer, sourceBufferSize, nil, COMPRESSION_LZFSE)
//        }
//
//        if status == 0 {
//            print("Error with status: \(status)")
//        }
//        print("Original size: \(sourceBufferSize) | Compressed size: \(status)")
//        return NSData(bytesNoCopy: destinationBuffer, length: status)
//    }
//}

public extension Data
{
    /// Compresses the data.
    /// - parameter withAlgorithm: Compression algorithm to use. See the `CompressionAlgorithm` type
    /// - returns: compressed data
    public func compress(withAlgorithm algo: CompressionAlgorithm) -> Data?
    {
        return self.withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let config = (operation: COMPRESSION_STREAM_ENCODE, algorithm: algo.lowLevelType)
            return perform(config, source: sourcePtr, sourceSize: count)
        }
    }

    /// Decompresses the data.
    /// - parameter withAlgorithm: Compression algorithm to use. See the `CompressionAlgorithm` type
    /// - returns: decompressed data
    public func decompress(withAlgorithm algo: CompressionAlgorithm) -> Data?
    {
        return self.withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let config = (operation: COMPRESSION_STREAM_DECODE, algorithm: algo.lowLevelType)
            return perform(config, source: sourcePtr, sourceSize: count)
        }
    }

    /// Please consider the [libcompression documentation](https://developer.apple.com/reference/compression/1665429-data_compression)
    /// for further details. Short info:
    /// ZLIB  : Fast with a very solid compression rate. There is a reason it is used everywhere.
    /// LZFSE : Apples proprietary compression algorithm. Claims to compress as good as ZLIB but 2 to 3 times faster.
    /// LZMA  : Horribly slow. Compression as well as decompression. Normally you will regret choosing LZMA.
    /// LZ4   : Fast, but depending on the data the compression rate can be really bad. Which is often the case.
    public enum CompressionAlgorithm
    {
        case ZLIB
        case LZFSE
        case LZMA
        case LZ4
    }

    /// Compresses the data using the zlib deflate algorithm.
    /// - returns: raw deflated data according to [RFC-1951](https://tools.ietf.org/html/rfc1951).
    /// - note: Fixed at compression level 5 (best trade off between speed and time)
    public func deflate() -> Data?
    {
        return self.withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let config = (operation: COMPRESSION_STREAM_ENCODE, algorithm: COMPRESSION_ZLIB)
            return perform(config, source: sourcePtr, sourceSize: count)
        }
    }

    /// Deompresses the data using the zlib deflate algorithm. Self is expected to be a raw deflate
    /// stream according to [RFC-1951](https://tools.ietf.org/html/rfc1951).
    /// - returns: uncompressed data
    public func inflate() -> Data?
    {
        return self.withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let config = (operation: COMPRESSION_STREAM_DECODE, algorithm: COMPRESSION_ZLIB)
            return perform(config, source: sourcePtr, sourceSize: count)
        }
    }

    /// Compresses the data using the zlib deflate algorithm.
    /// - returns: zlib deflated data according to [RFC-1950](https://tools.ietf.org/html/rfc1950)
    /// - note: Fixed at compression level 5 (best trade off between speed and time)
    public func zip() -> Data?
    {
        var res = Data(bytes: [0x78, 0x5e])

        guard let deflated = self.deflate() else { return nil }
        res.append(deflated)

        var adler = self.adler32().bigEndian
        res.append(Data(bytes: &adler, count: MemoryLayout<UInt32>.size))

        return res
    }

    /// Deompresses the data using the zlib deflate algorithm. Self is expected to be a zlib deflate
    /// stream according to [RFC-1950](https://tools.ietf.org/html/rfc1950).
    /// - returns: uncompressed data
    public func unzip(skipCheckSumValidation: Bool = true) -> Data?
    {
        // 2 byte header + 4 byte adler32 checksum
        let overhead = 6
        guard count > overhead else { return nil }

        let header: UInt16 = withUnsafeBytes { (ptr: UnsafePointer<UInt16>) -> UInt16 in
            return ptr.pointee.bigEndian
        }

        // check for the deflate stream bit
        guard header >> 8 & 0b1111 == 0b1000 else { return nil }
        // check the header checksum
        guard header % 31 == 0 else { return nil }

        let cresult: Data? = withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> Data? in
            let source = ptr.advanced(by: 2)
            let config = (operation: COMPRESSION_STREAM_DECODE, algorithm: COMPRESSION_ZLIB)
            return perform(config, source: source, sourceSize: count - overhead)
        }

        guard let inflated = cresult else { return nil }

        if skipCheckSumValidation { return inflated }

        let cksum: UInt32 = withUnsafeBytes { (bytePtr: UnsafePointer<UInt8>) -> UInt32 in
            let last = bytePtr.advanced(by: count - 4)
            return last.withMemoryRebound(to: UInt32.self, capacity: 1) { (intPtr) -> UInt32 in
                return intPtr.pointee.bigEndian
            }
        }

        return cksum == inflated.adler32() ? inflated : nil
    }

    /// Rudimentary implementation of the adler32 checksum.
    /// - returns: adler32 checksum (4 byte)
    public func adler32() -> UInt32
    {
        var s1: UInt32 = 1
        var s2: UInt32 = 0
        let prime: UInt32 = 65521

        for byte in self {
            s1 += UInt32(byte)
            if s1 >= prime { s1 = s1 % prime }
            s2 += s1
            if s2 >= prime { s2 = s2 % prime }
        }

        return (s2 << 16) | s1
    }
}


fileprivate extension Data.CompressionAlgorithm
{
    var lowLevelType: compression_algorithm {
        switch self {
        case .ZLIB    : return COMPRESSION_ZLIB
        case .LZFSE   : return COMPRESSION_LZFSE
        case .LZ4     : return COMPRESSION_LZ4
        case .LZMA    : return COMPRESSION_LZMA
        }
    }
}

fileprivate typealias Config = (operation: compression_stream_operation, algorithm: compression_algorithm)


fileprivate func perform(_ config: Config, source: UnsafePointer<UInt8>, sourceSize: Int) -> Data?
{
    guard config.operation == COMPRESSION_STREAM_ENCODE || sourceSize > 0 else { return nil }

    let streamBase = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
    defer { streamBase.deallocate(capacity: 1) }
    var stream = streamBase.pointee

    let status = compression_stream_init(&stream, config.operation, config.algorithm)
    guard status != COMPRESSION_STATUS_ERROR else { return nil }
    defer { compression_stream_destroy(&stream) }

    let bufferSize = Swift.max( Swift.min(sourceSize, 64 * 1024), 64)
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { buffer.deallocate(capacity: bufferSize) }

    stream.dst_ptr  = buffer
    stream.dst_size = bufferSize
    stream.src_ptr  = source
    stream.src_size = sourceSize

    var res = Data()
    let flags: Int32 = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)

    while true {
        switch compression_stream_process(&stream, flags) {
        case COMPRESSION_STATUS_OK:
            guard stream.dst_size == 0 else { return nil }
            res.append(buffer, count: stream.dst_ptr - buffer)
            stream.dst_ptr = buffer
            stream.dst_size = bufferSize

        case COMPRESSION_STATUS_END:
            res.append(buffer, count: stream.dst_ptr - buffer)
            return res

        default:
            return nil
        }
    }
}
