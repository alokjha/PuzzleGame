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


extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}


//extension Array {
//    mutating func shuffle() {
//        for _ in 0..<((count>0) ? (count-1) : 0) {
//            sort { (_,_) in arc4random() < arc4random() }
//        }
//    }
//}
