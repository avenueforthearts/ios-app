import Foundation
import UIKit

extension UIView {
    func center<T: UIView>(in view: T) {
        self.centerVertically(in: view)
        self.centerHorizontally(in: view)
    }

    func centerVertically<T: UIView>(in view: T) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if self.superview != view {
            view.addSubview(self)
        }

        let centerVertical = NSLayoutConstraint(
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )

        view.addConstraints([centerVertical])
    }

    func centerHorizontally<T: UIView>(in view: T) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if self.superview != view {
            view.addSubview(self)
        }

        let centerHorizontal = NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )

        view.addConstraints([centerHorizontal])
    }

    func pinToEdges<T: UIView>(of view: T) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if self.superview != view {
            view.addSubview(self)
        }

        let leading = NSLayoutConstraint(
            item: view,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        let trailing = NSLayoutConstraint(
            item: view,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        let top = NSLayoutConstraint(
            item: view,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        let bottom = NSLayoutConstraint(
            item: view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        view.addConstraints([leading, trailing, top, bottom])
    }
}
