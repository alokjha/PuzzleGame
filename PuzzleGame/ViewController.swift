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
    @IBOutlet weak var timerView : UIView!
    @IBOutlet weak var sourceImageView : UIImageView!
    @IBOutlet weak var imageWrapperView : UIView!
    
    var dragSource : UIImageView?
    var dragDestination : UIImageView?
    var dragTemp : UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.imgTapped(_:)))
        sourceImageView.addGestureRecognizer(tapGesture)
        sourceImageView.isUserInteractionEnabled = true
        
        toggleViewsVisibility(hidden: true)
        
        downloadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func toggleViewsVisibility(hidden : Bool) {
        
        cancelBtn.isHidden = hidden
        timerView.isHidden = hidden
        imageWrapperView.isHidden = hidden
        sourceImageView.isHidden = !hidden
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
    
    @objc fileprivate func imgTapped(_ sender : UITapGestureRecognizer) {
        
        if let img = sourceImageView.image {
            splitImage(img, intoRows: 4, andColumns: 3)
            toggleViewsVisibility(hidden: false)
        }
        
    }
    
    @IBAction func cancelBtnTapped(_ sender : UIButton) {
        
        for vw in imageWrapperView.subviews {
            vw.removeFromSuperview()
        }
        toggleViewsVisibility(hidden: true)
    }
    
    fileprivate func splitImage(_ image : UIImage , intoRows rows : Int , andColumns columns:Int) {
        
        let imageSize = image.size
        
        var xPos = CGFloat(0)
        var yPos = CGFloat(0)
        let width = imageSize.width/CGFloat(rows)
        let height = imageSize.height/CGFloat(columns)
        
        var imgViewArrays : [UIImage] = []
        
        for _ in 0..<columns {
            
            xPos = CGFloat(0)
            
            for _ in 0..<rows {
                
                let rect = CGRect(x: xPos, y: yPos, width: width, height: height)
                
                let cImage = image.cgImage!.cropping(to: rect)
                
                let img = UIImage(cgImage: cImage!)
                
                imgViewArrays.append(img)
                
                xPos += width
                
            }
            
            yPos += height
            
        }
        
        
        imgViewArrays.shuffle()
        
        var  i = 0
        var  j = 0
        
        let imgViewWidth = imageWrapperView.frame.size.width/CGFloat(rows)
        let imgViewHeight = imageWrapperView.frame.size.height/CGFloat(columns)
        
        for img in imgViewArrays {
            
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



