//
//  AttributionVC.swift
//  FilmPal
//
//  Created by The Dude on 5/1/24.
//

import UIKit


class AttributionVC: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    var timer: Timer!
    var waitTime = 30
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.isHidden = true
        
        //checks to see if they already opened the app
        if (defaults.bool(forKey: "First Launch") == true) {
            defaults.set(true, forKey: "First Launch")
            performSegue(withIdentifier: "startApp", sender: self)
        } else {
            print("First")
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(waitTick), userInfo: nil, repeats: true)
            defaults.set(true, forKey: "First Launch")
        }
    }
    
    
    //Timer Function
    @objc func waitTick() {
        waitTime -= 1
        if (waitTime <= 0) {
            continueButton.isHidden = false
            timer.invalidate()
            timer = nil
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
