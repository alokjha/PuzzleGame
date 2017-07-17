//
//  ViewController.swift
//  PuzzleGame
//
//  Created by Alok Jha on 13/07/17.
//  Copyright © 2017 Alok Jha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var sourceImageView : UIImageView!
    
    let countdownLabel : UILabel = UILabel()
    var originalImageArray : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addBackgroundGradient()
        
        downloadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            self.startCountDown()
        })
    }
    
    
    fileprivate func addBackgroundGradient() {
        
        let startColor = UIColor(white: 220/255.0, alpha: 1.0)
        let midColor = UIColor(white: 253/255.0, alpha: 1.0)
        let endColor = startColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [startColor.cgColor , midColor.cgColor , endColor.cgColor]
        
        let x: Double = 45.0 / 360.0
        let pi = Double.pi
        
        let a = pow(sinf(Float(2.0 * pi * ((x + 0.75) / 2.0))),2.0);
        let b = pow(sinf(Float(2*pi*((x+0.0)/2))),2);
        let c = pow(sinf(Float(2*pi*((x+0.25)/2))),2);
        let d = pow(sinf(Float(2*pi*((x+0.5)/2))),2);
        
        gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
        
        //gradientLayer.locations = [0.0,NSNumber(value:0.09*Double(view.bounds.size.width)) , NSNumber(value:0.09*Double(view.bounds.size.height)),1.0]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    fileprivate func downloadImage() {
        
        let urlStr = "https://s3-eu-west-1.amazonaws.com/wagawin-ad-platform/media/testmode/banner-landscape.jpg"
        let url = URL(string : urlStr)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                return
            }
            
            guard data != nil else {
                return
            }
            
            DispatchQueue.main.async {
                let img = UIImage(data: data!)
                self.sourceImageView.image = img
                
            }
            
        }
        
        task.resume()
    }

    
    
    fileprivate func startCountDown() {
        
        countdownLabel.text = "3"
        countdownLabel.font = UIFont.systemFont(ofSize: 15.0)
        countdownLabel.textColor = UIColor.white
        countdownLabel.sizeToFit()
        
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(countdownLabel)
        
        NSLayoutConstraint(item: countdownLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: countdownLabel, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        
        self.animateLabel()
    }
    
    
    fileprivate func animateLabel() {
        
        let alpha = CABasicAnimation(keyPath: "opacity")
        alpha.fromValue = 1
        alpha.toValue = 0
        
        let scaleUp = CABasicAnimation(keyPath: "transform.scale")
        scaleUp.fromValue = 1
        scaleUp.toValue = 12
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [scaleUp,alpha]
        animGroup.duration = 1
        animGroup.beginTime = CACurrentMediaTime()
        animGroup.isRemovedOnCompletion = false
        animGroup.fillMode = kCAFillModeForwards
        animGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animGroup.delegate = self
        countdownLabel.layer.add(animGroup, forKey: nil)
    }
    
    fileprivate func showPuzzleVC() {
        
        let puzzleVC = self.storyboard?.instantiateViewController(withIdentifier: "puzzleVC") as! PuzzleViewController
        puzzleVC.sourceImage = sourceImageView.image
        puzzleVC.modalTransitionStyle = .crossDissolve
        self.present(puzzleVC, animated: true, completion: nil)
    }

    
}

extension ViewController : CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag {
            
            if var num = Int(countdownLabel.text!) {
                
                if num <= 1 {
                    countdownLabel.alpha = 0
                    showPuzzleVC()
                    return
                }
                num -= 1
                countdownLabel.text = "\(num)"
                animateLabel()

            }
            
        }
        
        
    }
    
}




