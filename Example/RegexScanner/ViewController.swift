//
//  ViewController.swift
//  RegexScanner
//
//  Created by Narlei Moreira on 07/08/2021.
//  Copyright (c) 2021 Narlei Moreira. All rights reserved.
//

import UIKit
import RegexScanner

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func action(_ sender: Any) {
        let scannerView = RegexScanner.getScanner(regex: "[A-Z]{2}[0-9]{9}[A-Z]{2}") { value in
            print(value)
        }
        present(scannerView, animated: true, completion: nil)
    }

}

