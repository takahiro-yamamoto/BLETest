//
//  PeripheralViewController.swift
//  BLETest
//
//  Created by TY on 2018/04/26.
//  Copyright © 2018年 yamatakajp. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController, CBPeripheralManagerDelegate, CBPeripheralDelegate {

    var manager: CBPeripheralManager!

    var imageDataChara1: CBCharacteristic!
    var imageDataChara2: CBMutableCharacteristic!

    var image: UIImage!
    var imageData1: Data!
    var imageData2: Data!

    var imageDataCnt1 = 0

    var currentOffset1 = 0
    var currentOffset2 = 0

    let label1 = UILabel()
    let label2 = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        manager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        self.view.backgroundColor = UIColor.white

        let s = UIImage(named: "tako")!.size
        let newSize = CGSize(width: s.width * 0.6, height: s.height * 0.6)

        //        imageData1 = UIImagePNGRepresentation(UIImage(named: "tako")!)
//        imageData1 = UIImageJPEGRepresentation(UIImage(named: "tako")!, 0.5)
        let my = MyClass2()
        imageData1 = my.quantizedImageData(my.rgba(from: UIImage(named: "tako")!))
        imageDataCnt1 = imageData1.count
        //        imageData2 = UIImagePNGRepresentation(UIImage(named: "star")!)

        label1.textColor = UIColor.blue
        label1.font = UIFont.boldSystemFont(ofSize: 20)
        label1.frame.size = CGSize(width: 240, height: 120)
        label1.textAlignment = .center
        label1.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - 60)
        self.view.addSubview(label1)

        label2.textColor = UIColor.blue
        label2.font = UIFont.boldSystemFont(ofSize: 20)
        label2.frame.size = CGSize(width: 240, height: 120)
        label2.textAlignment = .center
        label2.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + 60)
        self.view.addSubview(label2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // peripheralManagerの生成後に呼ばれる
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

        switch (peripheral.state) {
        case CBManagerState.poweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            break;
        case CBManagerState.unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            break

        case CBManagerState.unknown:
            print("CoreBluetooth BLE state is unknown");
            break

        case CBManagerState.poweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            // ペリフェラルの検出
            break;

        case CBManagerState.resetting:
            print("CoreBluetooth BLE hardware is resetting")
            break;
        case CBManagerState.unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform");
            break
        }

        // 画像データ1
        imageDataChara1 = CBMutableCharacteristic(type: imageDataCharaUUID1, properties: [CBCharacteristicProperties.read,CBCharacteristicProperties.notify], value: nil, permissions: .readable)

        // 画像データ2
        //        imageDataChara2 = CBMutableCharacteristic(type: imageDataCharaUUID2, properties: [CBCharacteristicProperties.read,CBCharacteristicProperties.notify], value: nil, permissions: .readable)

        // primary = trueの場合は主サービス
        // サービスに他のサービスをぶら下げることもできる
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [imageDataChara1]
        //        service.characteristics = [imageDataChara1, imageDataChara2]

        // serviceの追加
        manager.add(service)
    }

    // サービスの追加を検知
    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let e = error {
            print("Error publishing service: \(e.localizedDescription)")
        } else {
            print("Success publishing service")

            // サービスのアドバタイズ
            manager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service.uuid]])
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let e = error {
            print("Error advertising service: \(e.localizedDescription)")
        } else {
            print("Success advertising service")
        }
    }

    // 特性値の読み取り要求が来た
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        //        print("maximumUpdateValueLength=\(request.central.maximumUpdateValueLength)")
        let s = 182
        switch request.characteristic.uuid {
        case imageDataCharaUUID1:
            if currentOffset1 < 0 {
                break
            }
            if currentOffset1 >= imageDataCnt1 {
                break
            }

            if currentOffset1 <= imageDataCnt1 {
                request.value = imageData1.subdata(in: currentOffset1...min(currentOffset1 + s, imageDataCnt1) - 1)
                self.label1.text = "\(currentOffset1...min(currentOffset1 + s, imageDataCnt1) - 1) sending"
                currentOffset1 = currentOffset1 + s;
                manager.respond(to: request, withResult: .success)
            }
            break
        case imageDataCharaUUID2:
            if currentOffset2 < 0 {
                break
            }
            if currentOffset2 >= imageData2.count {
                break
            }

            if currentOffset2 <= imageData2.count {
                request.value = imageData2.subdata(in: currentOffset2...min(currentOffset2 + s, imageData2.count) - 1)
                self.label2.text = "\(currentOffset2...min(currentOffset2 + s, imageData2.count) - 1) sending"
                currentOffset2 = currentOffset2 + s;
                manager.respond(to: request, withResult: .success)
            }
            break
        default:
            break
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
