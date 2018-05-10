//
//  ViewController.swift
//  BLETest
//
//  Created by yamamoto on 2018/04/23.
//  Copyright © 2018年 jp.smarteducation. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // mainQueueで実行される
        centralManager = CBCentralManager(delegate: self, queue: nil)

        // ペリフェラルの検出
        // withServicesがnilの場合はサービスに関わらず全てのペリフェラルを検出する。指定すれば検出するペリフェラルを絞ることができる
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

    }

    // ペリフェラルの検出
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // 接続先が見つかったら省電力のためペリフェラルの走査は停止する
        centralManager.stopScan()

        // 接続の要求
        centralManager.connect(peripheral, options: nil)
    }

    // ペリフェラルと接続できた
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // ペリフェラルとのやりとりのためにdelegateを登録
        peripheral.delegate = self

        // ペリフェラルが提供しているサービスを検出
        // 不要なサービスを検出しないように、nilではなくserviceのUUIDを指定するように！！
        peripheral.discoverServices(nil)


    }

    // ペリフェラルのサービスが見つかった
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach({ (service) in
            // サービスの特性を取得
            peripheral.discoverCharacteristics([], for: service)
        })

    }

    // サービスの特性が見つかった
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach({ (character) in
            print(character)
            // 特性の値を取得
            peripheral.readValue(for: character)
        })
    }

    // 特性の値の読み取り完了。あるいは特性の値が変化した
    // 特性の値はいつも読み取り可能とは限らない。
    // 読み取れなかった場合は、error != nil となる
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data: Data? = characteristic.value
        let dataStr: String? = String(data: data!, encoding: .utf8)

        print("\(characteristic.uuid)=\(String(describing: dataStr))")

        // 特性の値が変更したことを検知するために必要
        // ただし、変更の検知を許可しない特性もある
        peripheral.setNotifyValue(true, for: characteristic)

        // 特性の値を書き換え
        // 書き込みの成功失敗も返すようにする
        peripheral.writeValue("test".data(using: .utf8)!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
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
