//
//  PeripheralViewController.swift
//  BLETest
//
//  Created by TY on 2018/04/26.
//  Copyright © 2018年 yamatakajp. All rights reserved.
//

import UIKit
import CoreBluetooth
import MultipeerConnectivity

class PeripheralViewController: UIViewController, CBPeripheralManagerDelegate, CBPeripheralDelegate {

    var manager: CBPeripheralManager!
    var imageDataChara: CBCharacteristic!

    var image: UIImage!
    var imageData: Data!

    var imageDataCnt = 0

    var currentOffset = 0

    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

//        // Do any additional setup after loading the view.
//        manager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
//        self.view.backgroundColor = UIColor.white
//
//        imageData = UIImagePNGRepresentation(UIImage(named: "tako")!)
//        imageDataCnt = imageData.count

        label.textColor = UIColor.blue
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.frame.size = CGSize(width: 240, height: 120)
        label.textAlignment = .center
        label.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - 60)
        self.view.addSubview(label)

        P2PConnectivity.manager.start(
            serviceType: "MIKE-SIMPLE-P2P",
            displayName: UIDevice.current.name,
            stateChangeHandler: { state in
                print(state)
                // 接続状況の変化した時の処理
        }, recieveHandler: { data in
            print("receive")
            // データを受信した時の処理
        })

        let btn = UIButton()
        btn.frame.origin = CGPoint(x: 200, y: 200)
        btn.frame.size = CGSize(width: 100, height: 100)
        btn.addTarget(self, action: #selector(self.tap(sender:)), for: .touchUpInside)
        btn.setTitle("send", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        self.view.addSubview(btn)

        let my = MyClass2()
//        takoData = my.quantizedImageData(my.rgba(from: UIImage(named: "tako")!))
        takoData = UIImagePNGRepresentation(UIImage(named: "tako")!)
        print(takoData.count)
    }
    var takoData: Data!
var cnt=0
    @objc func tap(sender: UIButton) {

        let my = MyClass2()
//        imageData = my.quantizedImageData(my.rgba(from: UIImage(named: "tako")!))
        if cnt % 2 == 0 {
imageData = takoData
        } else {
imageData = UIImagePNGRepresentation(UIImage(named: "sakana")!)
        }
        self.label.text = "start!!! \(cnt)"

        cnt+=1;
        P2PConnectivity.manager.sendData(data: imageData)
//        P2PConnectivity.manager.send(message: "koreda")
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

        // 画像データ
        imageDataChara = CBMutableCharacteristic(type: imageDataCharaUUID1, properties: [CBCharacteristicProperties.read,CBCharacteristicProperties.notify], value: nil, permissions: .readable)

        // primary = trueの場合は主サービス
        // サービスに他のサービスをぶら下げることもできる
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [imageDataChara]

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
            if currentOffset < 0 {
                break
            }

            if currentOffset >= imageDataCnt {
                break
            }

            if currentOffset <= imageDataCnt {
                request.value = imageData.subdata(in: currentOffset...min(currentOffset + s, imageDataCnt) - 1)
                self.label.text = "\(currentOffset...min(currentOffset + s, imageDataCnt) - 1) sending"
                currentOffset = currentOffset + s;
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
