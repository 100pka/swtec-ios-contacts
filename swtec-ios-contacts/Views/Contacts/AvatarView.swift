//
//  AvatarView.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 4/5/21.
//

import Foundation
import UIKit

@IBDesignable
class AvatarView: UIView {
    
    var text = ""
    private let avatarColor = UIColor.random
    private var isScaled = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                touchGesture.numberOfTapsRequired = 1
                self.addGestureRecognizer(touchGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let windowWidth = self.window?.frame.size.width else {
            return
        }

        let scale = windowWidth / self.bounds.width
        if !self.isScaled {
            UIView.animate(withDuration: 2, animations: {
                let grow = CGAffineTransform(scaleX: scale, y: scale)
                let move = CGAffineTransform(translationX: windowWidth/2.5, y: 0)
                self.transform = grow.concatenating(move)
            })
            
        } else {
            UIView.animate(withDuration: 2, animations: {
                let grow = CGAffineTransform(scaleX: 1, y: 1)
                let move = CGAffineTransform(translationX: 0, y: 0)
                self.transform = grow.concatenating(move)
            })
        }
        self.isScaled = !self.isScaled
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.width/2, y: rect.height/2)
        let circle = UIBezierPath(arcCenter: center, radius: rect.height/2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        avatarColor.setFill()
        circle.fill()
        let text = NSAttributedString(string: self.text)
        text.draw(at: CGPoint(x: center.x-text.size().width/2, y: center.y-text.size().height/2))
        
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
