//
//  UIView+.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

extension UIView {
    
    // X/Y Anchor
    
    enum AnchorAxis {
        case vertical
        case horizontal
    }
    
    func centerInSuperview(point: CGPoint = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: point.x).isActive = true
        centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: point.y).isActive = true
    }
    
    func alignAxis(_ axis: AnchorAxis, of: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        switch axis {
        case .horizontal:
            centerYAnchor.constraint(equalTo: of.centerYAnchor, constant: constant).isActive = true
        case .vertical:
            centerXAnchor.constraint(equalTo: of.centerXAnchor, constant: constant).isActive = true
        }
    }
    
    // width/height Anchor
    
    enum AnchorDimension {
        case width
        case height
    }
    
    func setDimensions(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
    
    func setDimensions(dimension: AnchorDimension, constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        switch dimension {
        case .width:
            widthAnchor.constraint(equalToConstant: constant).isActive = true
        case .height:
            heightAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }
    
    // top/trailing/bottom/leading Anchor
    
    enum AnchorEdge {
        case top
        case trailing
        case bottom
        case leading
    }
    
    func pinEdge(_ edge: AnchorEdge, to: AnchorEdge, of: UIView, constant: CGFloat = 0) {
        switch to {
        case .top:
            pinEdge(edge, yAnchor: of.topAnchor, constant: constant)
        case .trailing:
            pinEdge(edge, xAnchor: of.trailingAnchor, constant: constant)
        case .bottom:
            pinEdge(edge, yAnchor: of.bottomAnchor, constant: constant)
        case .leading:
            pinEdge(edge, xAnchor: of.leadingAnchor, constant: constant)
        }
    }
    
    func pinEdge(_ edge: AnchorEdge, xAnchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        switch edge {
        case .trailing:
            trailingAnchor.constraint(equalTo: xAnchor, constant: constant).isActive = true
        case .leading:
            leadingAnchor.constraint(equalTo: xAnchor, constant: constant).isActive = true
        default: break
        }
    }
    
    func pinEdge(_ edge: AnchorEdge, yAnchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        switch edge {
        case .top:
            topAnchor.constraint(equalTo: yAnchor, constant: constant).isActive = true
        case .bottom:
            bottomAnchor.constraint(equalTo: yAnchor, constant: constant).isActive = true
        default: break
        }
    }
    
    func pinEdgesToSuperviewEdges() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
    }
}
