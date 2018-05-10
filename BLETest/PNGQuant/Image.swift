////
////  Image.swift
////  PNGQuant
////
////  Created by Antwan van Houdt on 06/07/2017.
////  Copyright © 2017 Antwan van Houdt. All rights reserved.
////
//
//import Foundation
//
//class Image {
//    private let ptr: OpaquePointer
//
//    init(attributes: Attributes, image: UIImage) {
//
////        liq_attr *attr = liq_attr_create();
////        liq_image *image = liq_image_create_rgba(attr, example_bitmap_rgba, width, height, 0);
////        liq_result *res;
////        liq_image_quantize(image, attr, &res);
//
//
////        ptr = liq_image_create_rgba(attributes, <#T##bitmap: UnsafeRawPointer##UnsafeRawPointer#>, <#T##width: Int32##Int32#>, <#T##height: Int32##Int32#>, <#T##gamma: Double##Double#>)
//
//
//        
//        let data = UIImagePNGRepresentation(image)!
//
//        let charPtr = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: data.count)
//        charPtr.initialize(from: data)
//        let dataBytes = UnsafeRawPointer(charPtr)
//
//        let attr = liq_attr_create()
////        liq_image_create_rgba(attr, <#T##bitmap: UnsafeRawPointer##UnsafeRawPointer#>, <#T##width: Int32##Int32#>, <#T##height: Int32##Int32#>, <#T##gamma: Double##Double#>)
//
//        ptr = liq_image_create_rgba(attr!, dataBytes, 384, 256, 0)
//        let res = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 384 * 256)
//        liq_image_quantize(ptr, attr!, res)
//
//    }
//
//
//
//    deinit {
//        liq_image_destroy(ptr)
//    }
//}
