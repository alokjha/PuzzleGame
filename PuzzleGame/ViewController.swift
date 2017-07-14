//
//  ViewController.swift
//  PuzzleGame
//
//  Created by Alok Jha on 13/07/17.
//  Copyright © 2017 Alok Jha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cancelBtn : UIButton!
    @IBOutlet weak var timerWrapperView : UIView!
    @IBOutlet weak var sourceImageView : UIImageView!
    @IBOutlet weak var imageWrapperView : UIView!
    @IBOutlet weak var timerView : UIView!
    @IBOutlet weak var timerViewTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var timerLabel : UILabel!
    
    let countdownLabel : UILabel = UILabel()
    var originalImageArray : [UIImage] = []
    var gameStarted : Bool = false
    var timer : Timer?
    var dragSource : UIImageView?
    var dragDestination : UIImageView?
    var dragTemp : UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        toggleViewsVisibility(hidden: true)
        
        addBackgroundGradient()
        
        downloadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func toggleViewsVisibility(hidden : Bool) {
        
        cancelBtn.isHidden = hidden
        timerWrapperView.isHidden = hidden
        imageWrapperView.isHidden = hidden
        timerLabel.isHidden = hidden
        sourceImageView.isHidden = !hidden
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                    self.startCountDown()
                })
            }
            
        }
        
        task.resume()
    }

    
    @IBAction func cancelBtnTapped(_ sender : UIButton) {
        
       reset()
    }
    
    fileprivate func reset() {
        self.gameStarted = false
        toggleViewsVisibility(hidden: true)
        timerViewTopConstraint.constant = 2
        self.timerLabel.text = "21"
        timerWrapperView.layoutIfNeeded()
        timer?.invalidate()
        timer = nil
        for vw in imageWrapperView.subviews {
            vw.removeFromSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.startCountDown()
        }
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
        
        self.animateLable()
    }
    
    
    fileprivate func animateLable() {
        
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
    
    fileprivate func startGame() {
        
        if let img = sourceImageView.image {
            splitImage(img, intoRows: 4, andColumns: 3)
            toggleViewsVisibility(hidden: false)
            timerLabel.isHidden = true
            gameStarted = true
            startTimer()
        }
        
    }

    
    fileprivate func splitImage(_ image : UIImage , intoRows rows : Int , andColumns columns:Int) {
        
        let imageSize = image.size
        
        var xPos = CGFloat(0)
        var yPos = CGFloat(0)
        let width = imageSize.width/CGFloat(rows)
        let height = imageSize.height/CGFloat(columns)
        
        var imgArrays : [UIImage] = []
        
        for _ in 0..<columns {
            
            xPos = CGFloat(0)
            
            for _ in 0..<rows {
                
                let rect = CGRect(x: xPos, y: yPos, width: width, height: height)
                
                let cImage = image.cgImage!.cropping(to: rect)
                
                let img = UIImage(cgImage: cImage!)
                
                imgArrays.append(img)
                
                xPos += width
                
            }
            
            yPos += height
            
        }
        
        originalImageArray = imgArrays
        
        imgArrays.shuffle()
        
        var  i = 0
        var  j = 0
        
        let imgViewWidth = imageWrapperView.frame.size.width/CGFloat(rows)
        let imgViewHeight = imageWrapperView.frame.size.height/CGFloat(columns)
        
        for img in imgArrays {
            
            let imgViewFrm = CGRect(x: CGFloat(i)*imgViewWidth, y: CGFloat(j)*imgViewHeight, width:imgViewWidth, height: imgViewHeight)
            
            let imgView = UIImageView(frame: imgViewFrm)
            imgView.image = img
            imgView.layer.borderColor = UIColor.white.cgColor
            imgView.layer.borderWidth = 0.5
            imageWrapperView.addSubview(imgView)
            
            i += 1
            
            if i >= rows {
                i = 0
                j += 1
            }
            
        }
        
    }
    

    
}

extension ViewController : CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag {
            
            if var num = Int(countdownLabel.text!) {
                
                if num <= 1 {
                    countdownLabel.alpha = 0
                    startGame()
                    return
                }
                num -= 1
                countdownLabel.text = "\(num)"
                animateLable()

            }
            
        }
        
        
    }
    
}
//MARK: -  Drag N Drop

extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first , touch.view == imageWrapperView {
            
            let location = touch.location(in: imageWrapperView)
            
            for vw in imageWrapperView.subviews {
                
                let point = imageWrapperView.convert(location, to: vw)
                
                if vw.point(inside: point, with: event) {
                    
                    dragSource = vw as? UIImageView
                    break
                }
                
            }
            
            
            dragTemp = UIImageView()
            dragTemp?.frame = dragSource!.frame
            dragTemp?.image = dragSource?.image
            dragTemp?.center = location
            
            imageWrapperView.addSubview(dragTemp!)
            
            dragSource?.alpha = 0
           
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first , touch.view == imageWrapperView {
            dragTemp?.center = touch.location(in: imageWrapperView)
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first , touch.view == imageWrapperView {
            dragTemp?.center = touch.location(in: imageWrapperView)
            
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.dragTemp?.frame = self.dragSource!.frame
                
            }, completion: { (success) in
                self.dragSource?.alpha = 1
                self.dragTemp?.removeFromSuperview()
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if let touch = touches.first , touch.view == imageWrapperView {
            dragTemp?.center = touch.location(in: imageWrapperView)
            let location = touch.location(in: imageWrapperView)
            
            for vw in imageWrapperView.subviews {
                
                let point = imageWrapperView.convert(location, to: vw)
                
                if vw.point(inside: point, with: event) {
                    
                    dragDestination = vw as? UIImageView
                    break
                }
                
            }
            
            let temp = UIImageView()
            temp.image = dragDestination?.image
            temp.frame = dragDestination!.frame
            imageWrapperView.addSubview(temp)
            
            dragTemp?.center = dragDestination!.center
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                
                temp.frame = self.dragSource!.frame
                self.dragSource?.image = self.dragDestination?.image
                self.dragDestination?.image = self.dragTemp?.image
                
            }, completion: { (success) in
                 self.dragSource?.alpha = 1
                temp.removeFromSuperview()
                self.dragTemp?.removeFromSuperview()
            })
            
        }

    }
}

//MARK: -  Timer

extension ViewController {
    
    func startTimer() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            
            guard self.gameStarted else {
                return
            }
            
            let totalHeight = self.timerWrapperView.bounds.size.height - 4.0
            let duration = CGFloat(21.0)
            let timerInterval = CGFloat(0.5)
            let offSet = timerInterval * totalHeight / duration
            
            var counter = 0
            var num = 21
            
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timerInterval), repeats: true) { (timer) in
                
                let newY = self.timerViewTopConstraint.constant + offSet
                
                if  newY >= self.timerWrapperView.bounds.size.height {
                    self.timerWrapperView.layoutIfNeeded()
                    timer.invalidate()
                    self.calculateScore()
                    return
                }
                
                self.timerViewTopConstraint.constant = newY
                
                counter += 1
                
                if counter % 2 == 0 {
                    num -= 1
                    self.timerLabel.isHidden = false
                    self.timerLabel.text = "\(num)"
                }
                
                self.timerWrapperView.layoutIfNeeded()
            }
            
            
        })
        
    }
    
    fileprivate func calculateScore() {
        
        var finalImgArray : [UIImage] = []
        
        for view in imageWrapperView.subviews {
            
            if let imgView = view as? UIImageView {
                
                finalImgArray.append(imgView.image!)
                
            }
            
        }
        
        var score = 0
        
        for i in 0..<originalImageArray.count {
            
            let orginalImage = originalImageArray[i]
            let finalImage = finalImgArray[i]
            
            if orginalImage == finalImage {
                score += 1
            }
        }
        
        if score < 12 {
            showFailureAlert(score)
        }
        else {
            showSuccesAlert(score)
        }
        
    }
    
    fileprivate func showFailureAlert(_ score : Int) {
        
        let alertController = UIAlertController(title: "Puzzle", message: "Sorry you were unable to complete the puzzle. Your final score : \(score)/12", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel) { (action) in
            self.reset()
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(closeAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    fileprivate func showSuccesAlert(_ score : Int) {
        
        let alertController = UIAlertController(title: "Puzzle", message: "Excellent!! You solved the puzzle. Your final score : \(score)/12", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel) { (action) in
            self.reset()
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(closeAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

}



