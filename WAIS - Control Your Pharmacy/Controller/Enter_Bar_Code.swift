//
//  barCodeReader.swift
//  Essam Atwah
//
//  Created by MACBOOK on 8/4/17.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import AVFoundation

class Enter_Bar_Code: UIViewController , AVCaptureMetadataOutputObjectsDelegate {
    //MARK: - IBOutlet and variable

    @IBOutlet weak var photo: UIImageView!
    
    var video = AVCaptureVideoPreviewLayer()
    
    var viewCon : String = "" // To get the name for the pervious ViewController
    private var flag : Bool = false // To check if the camare get the bar code or Not
    private var barCode  : String = "" // The bar code as string

    let Alert = alertOrginal()

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        BarCodeScanner()
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
   
    //MARK: - back UIBarButtonItem

    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - BarCodeScanner
    func BarCodeScanner(){
        let session = AVCaptureSession()
        let captrueD = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captrueD!)
            session.addInput(input)
        } catch {
            print("Error on bar code session")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr
            , AVMetadataObject.ObjectType.ean8
            , AVMetadataObject.ObjectType.upce
            , AVMetadataObject.ObjectType.aztec
            , AVMetadataObject.ObjectType.itf14
            , AVMetadataObject.ObjectType.code39
            , AVMetadataObject.ObjectType.code93
            , AVMetadataObject.ObjectType.ean13
            , AVMetadataObject.ObjectType.pdf417
            , AVMetadataObject.ObjectType.code128
        ]
        
        
        video = AVCaptureVideoPreviewLayer(session: session)
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        video.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(video)
        view.bringSubview(toFront: photo)
        
        
        session.startRunning()
    }
    
    //MARK: - metadataOutput
    //  capture Output
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if (metadataObjects != nil && metadataObjects.count != 0) {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject{
                if    (object.type == AVMetadataObject.ObjectType.qr
                    || object.type == AVMetadataObject.ObjectType.code128
                    || object.type == AVMetadataObject.ObjectType.pdf417
                    || object.type == AVMetadataObject.ObjectType.ean13
                    || object.type == AVMetadataObject.ObjectType.code93
                    || object.type == AVMetadataObject.ObjectType.code39
                    || object.type == AVMetadataObject.ObjectType.itf14
                    || object.type == AVMetadataObject.ObjectType.aztec
                    || object.type == AVMetadataObject.ObjectType.upce
                    || object.type == AVMetadataObject.ObjectType.ean8)
                {
                    if let barCodeString = object.stringValue {
                        flag = true
                        barCode = barCodeString
                    }
                }
            }
        }
        
        // if he capture an Output
        if (flag){
            flag = false
            
            // the viewCon has the name for the perivous viewController
            
            // There are a lot of ways to solve this problem.
            
            let EnterDataController = "EnterData"
            let Many_SellingController = "Many_Selling"
            
            if (viewCon == EnterDataController){
                EnterData.Bar_code = barCode
                EnterData.flagCheckBarCode = true // to open the button
                self.dismiss(animated: true, completion: nil)
            }else if (viewCon == Many_SellingController){
                addToDrugWillSell(barcode : barCode)// search for this barCode in drug will sell
            }
        }
        barCode = "" // To don't repeat the function 'addToDrugWillSell' more than one time
    }
    
    
    
    //MARK: - addToDrugWillSell
    // I am searching for the drug by it bar code if I found it add it on the Array "Drugs Will Sell"
    func addToDrugWillSell(barcode : String){
        var FoundTheDrug = false // flag

        if (barcode != ""){ // To don't repeat the alert more than one time
            
            for drug in All_Drugs.Dru {
                if (barcode == drug.bar_code){
                    FoundTheDrug = true// this drug in our database
                    // check if this drug already in the Drugs which will sell
                    if(!Many_Selling.DrugsWillSell.contains(drug)){
                        Many_Selling.DrugsWillSell.append(drug)
                    }else{
                        Alert.CancelAlert(view: self, title: "This drug Already Added", message: "If you want to but more from this drug increase the amount")
                    }
                    break
                }
            }
            // if We don't found this barcode in our database
            if (!FoundTheDrug){
                Alert.CancelAlert(view: self, title: "Not Found", message: "Please add this drug from Enter Drugs View or try searching by name")
            }else{
                let alert2 = UIAlertController(title: "Are you will Sell another item?" , message:"Press Yes to continue or No to back", preferredStyle: .alert)
                // alert action
                alert2.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                alert2.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                }))
                // present the alert
                self.present(alert2, animated: true, completion: nil)
            }
        }
    }
}
