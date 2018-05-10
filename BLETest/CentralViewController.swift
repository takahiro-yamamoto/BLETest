//
//  ViewController.swift
//  BLETest
//
//  Created by yamamoto on 2018/04/23.
//  Copyright © 2018年 jp.smarteducation. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!

    var knownPeripferal: CBPeripheral!

    let label1 = UILabel()
    let label2 = UILabel()

    let secLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Central"
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.black
        // mainQueueで実行される
        centralManager = CBCentralManager(delegate: self, queue: nil)


        label1.textColor = UIColor.blue
        label1.font = UIFont.boldSystemFont(ofSize: 20)
        label1.frame.size = CGSize(width: 240, height: 120)
        label1.textAlignment = .center
        label1.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - 40)
        self.view.addSubview(label1)

        label2.textColor = UIColor.blue
        label2.font = UIFont.boldSystemFont(ofSize: 20)
        label2.frame.size = CGSize(width: 240, height: 120)
        label2.textAlignment = .center
        label2.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + 40)
        self.view.addSubview(label2)

        secLabel.textColor = UIColor.green
        secLabel.font = UIFont.boldSystemFont(ofSize: 24)
        self.view.addSubview(secLabel)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
        switch (central.state) {
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
            // withServicesがnilの場合はサービスに関わらず全てのペリフェラルを検出する。指定すれば検出するペリフェラルを絞ることができる
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
            break;

        case CBManagerState.resetting:
            print("CoreBluetooth BLE hardware is resetting")
            break;
        case CBManagerState.unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform");
            break
        }
    }

    // ペリフェラルの検出
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // 接続先が見つかったら省電力のためペリフェラルの走査は停止する
        centralManager.stopScan()

        self.knownPeripferal = peripheral
        // 接続の要求
        centralManager.connect(peripheral, options: nil)
    }

    // ペリフェラルと接続できた
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // ペリフェラルとのやりとりのためにdelegateを登録
        peripheral.delegate = self

        // ペリフェラルが提供しているサービスを検出
        // 不要なサービスを検出しないように、nilではなくserviceのUUIDを指定するように！！
        peripheral.discoverServices([serviceUUID])
    }

    // ペリフェラルのサービスが見つかった
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach({ (service) in
            // サービスの特性を取得
            peripheral.discoverCharacteristics([imageDataCharaUUID1, imageDataCharaUUID2], for: service)
        })

    }

    var dataCharacterisic1: CBCharacteristic!
    var dataCharacterisic2: CBCharacteristic!

    // サービスの特性が見つかった
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach({ (characteristic) in
            if characteristic.uuid == imageDataCharaUUID1 {
                dataCharacterisic1 = characteristic
            } else if characteristic.uuid == imageDataCharaUUID2 {
                dataCharacterisic2 = characteristic
            }

            //            peripheral.setNotifyValue(true, for: characteristic)
            // 特性の値を取得
            peripheral.readValue(for: characteristic)
        })


    }

    // 特性の値の読み取り完了。あるいは特性の値が変化した
    // 特性の値はいつも読み取り可能とは限らない。
    // 読み取れなかった場合は、error != nil となる
    var imageData1: Data! = Data()
    var imageData2: Data! = Data()

    var start: Date?

    var done1 = false
    var done2 = false

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if start == nil {
            start = Date()
        }

        let data: Data? = characteristic.value

        if let e = error {
            print("error=\(e.localizedDescription)")
            if let d = data {
                print(String(data: d, encoding: .utf8))
            }
        }


        if characteristic.uuid == imageDataCharaUUID1 {
            if data == nil {
                return
            }

            imageData1.append(data!)
            label1.text = "\(imageData1.count)"

            // jpeg q=1 106372
            // jpeg q=0.8 25998
            // jpeg q=0.5
            // 143004
            // 83677
            // 55976
            // 38978
            // 15902
            // pnguant
            if imageData1.count >= 44848 {
                let imageUIImage = UIImage(data: imageData1)
                DispatchQueue.main.async {
                    let iv = UIImageView()
                    iv.image = imageUIImage
                    iv.frame.size = CGSize(width: 384, height: 256)
                    iv.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - 40)
                    self.view.addSubview(iv)

                    self.done1 = true
                    self.check()


                }
                //                print("end")
            } else {
                peripheral.readValue(for: self.dataCharacterisic1)
            }


            return
        } else if characteristic.uuid == imageDataCharaUUID2 {
            if data == nil {
                return
            }

            imageData2.append(data!)
            label2.text = "\(imageData2.count)"

            if imageData2.count >= 25792 {
                let imageUIImage = UIImage(data: imageData2)
                DispatchQueue.main.async {
                    let iv = UIImageView()
                    iv.image = imageUIImage
                    iv.frame.size = CGSize(width: 384, height: 256)
                    iv.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + 40)
                    self.view.addSubview(iv)

                    self.done2 = true
                    self.check()
                }

            } else {
                peripheral.readValue(for: self.dataCharacterisic2)
            }
            return
        }

    }

    func check() {
        //        if done1 && done2 {
        print("DONE!!! \(Date().timeIntervalSince(start!))")
        secLabel.text = "\(Date().timeIntervalSince(start!)) sec"
        secLabel.sizeToFit()
        secLabel.center = CGPoint(x: self.view.frame.width / 2, y: 180)
        //        }
    }

    // 特性の値の変化をウォッチできるかわかると呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("Error changing notification state: \(e.localizedDescription)")
        }
    }

    // 特性の値の書き込みの結果が返される
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("Error writing characteristic value \(e.localizedDescription)")
        }
    }

}
