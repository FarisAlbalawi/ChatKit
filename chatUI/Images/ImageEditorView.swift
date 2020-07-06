//
//  ImageEditorView.swift
//  chatUI
//
//  Created Faris Albalawi on 4/23/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.


import UIKit



class ImageEditorView: UIViewController {
    
     var ui = ImageEditorUI()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .black
        self.ui.presentationController = self
    
    }
    
    override func loadView() {
        self.view = ui
        
    }
    

}
