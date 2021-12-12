//
//  SearchViewController.swift
//  Nearbrary
//
//  Created by Release on 19/05/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet var searchTextField: UITextField!
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if let _ = searchTextField.text {
            performSegue(withIdentifier: "searchSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.returnKeyType = .done
        searchTextField.delegate=self
        self.navigationController?.isNavigationBarHidden = true
        searchTextField.delegate=self
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField:UITextField) -> Bool{
        self.view.endEditing(true)
        searchButtonPressed(self)
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let booksVC = segue.destination as? BooksTableViewController {
            if let text = searchTextField.text {
                booksVC.queryText = text
            }
        }
    }
    
}
