//
//  SelectViewController.swift
//  BLETest
//
//  Created by TY on 2018/04/26.
//  Copyright © 2018年 yamatakajp. All rights reserved.
//

import UIKit

class SelectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let btn1 = UIButton()
        btn1.frame.size = CGSize(width: 144, height: 72)
        btn1.setTitle("Central", for: .normal)
        btn1.center.x = self.view.frame.width / 2
        btn1.center.y = self.view.frame.height / 2 - 70
        btn1.addTarget(self, action: #selector(self.onTapCentral), for: .touchUpInside)
        self.view.addSubview(btn1)


        let btn2 = UIButton()
        btn2.frame.size = CGSize(width: 144, height: 72)
        btn2.setTitle("Peripheral", for: .normal)
        btn2.center.x = self.view.frame.width / 2
        btn2.center.y = self.view.frame.height / 2 + 70
        btn2.addTarget(self, action: #selector(self.onTapPeripferal), for: .touchUpInside)
        self.view.addSubview(btn2)

        let img = UIImage(named: "tako")!
        let ns = CGSize(width: img.size.width * 0.5, height: img.size.height * 0.5)

        let newImg = UIImage(named: "tako")!.resize(size: ns)!

        print("tako size=\(UIImageJPEGRepresentation(UIImage(named: "tako")!, 0.8)?.count)")
        print("\(UIImagePNGRepresentation(newImg)?.count)")

//        let iv1 = UIImageView(image: img)
//        iv1.frame.size = CGSize(width: 384, height: 256)
//        iv1.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height * 1 / 4)
//
//        self.view.addSubview(iv1)


//        let my = MyClass2()
//        let compressedData = my.quantizedImageData(my.rgba(from: img))
//        print(compressedData!.count)
//
//        let iv2 = UIImageView(image: UIImage(data: compressedData!))
//        iv2.frame.size = CGSize(width: 384, height: 256)
//        iv2.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height * 3 / 4)
//
//        self.view.addSubview(iv2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func onTapCentral(_ sender: UIButton) {
        self.navigationController?.pushViewController(CentralViewController(), animated: true)
    }

    @objc func onTapPeripferal(_ sender: UIButton) {
        self.navigationController?.pushViewController(PeripheralViewController(), animated: true)
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
