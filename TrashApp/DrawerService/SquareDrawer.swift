//
//  SquareDrawer.swift
//  TrashApp
//
//  Created by Volodymyr Nazarkevych on 13.06.2022.
//

import UIKit

enum DrawingMode {
    case noEdit
    case topRightEdit
    case topLeftRdit
    case bottomLeftEdit
    case bottomRightEdit
    case move
}

class SquareDrawer {
    private var startCircle = CAShapeLayer()
    private var topLeftCircle = CAShapeLayer()
    private var topRightCircle = CAShapeLayer()
    private var bottomLeftCircle = CAShapeLayer()


    private var currentShapeLayer: CAShapeLayer?
    private var currentLayer = CAShapeLayer()
    private var videoView: UIImageView

    private var pointA: CGPoint = CGPoint.zero
    private var pointB: CGPoint = CGPoint.zero
    private var lastPoint: CGPoint = CGPoint.zero
    private var mode: DrawingMode = .noEdit

    init(videoView: UIImageView, center: CGPoint, photoViewFrame: CGRect) {
        self.videoView = videoView
        pointA = CGPoint(x: center.x - 50, y: center.y - 50)
        pointB = CGPoint(x: center.x + 50, y: center.y + 50)
        
        if center.x - 50 < 0 {
            pointA = CGPoint(x: (center.x - 50) - (center.x - 55), y: pointA.y)
            pointB = CGPoint(x: (center.x + 50) - (center.x - 55), y: pointB.y)
        }
        if center.y - 50 < 0 {
            pointA = CGPoint(x: pointA.x, y: (center.y - 50) - (center.y - 55))
            pointB = CGPoint(x: pointB.x, y: (center.y + 50) - (center.y - 55))
        }
        if center.y + 50 > photoViewFrame.maxY {
            pointA = CGPoint(x: pointA.x, y: (center.y - 50) - (center.y + 55 - photoViewFrame.maxY))
            pointB = CGPoint(x: pointB.x, y: (center.y + 50) - (center.y + 55 - photoViewFrame.maxY))
        }
        if center.x + 50 > photoViewFrame.maxX {
            pointA = CGPoint(x: (center.x - 50) - (center.x + 55 - photoViewFrame.maxX), y: pointA.y)
            pointB = CGPoint(x: (center.x + 50) - (center.x + 55 - photoViewFrame.maxX), y: pointB.y)
        }
        currentLayer = DrawerHelper.drawSquare(from: pointA, to: pointB, with: .red, lineWidth: 3)
        videoView.layer.addSublayer(currentLayer)
        addCircles()
    }

    func handleLongPressGesture(longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            touchesBegan(longPress: longPress)
        case .changed:
            touchesMoved(longPress: longPress)
        case .ended:
            touchesEnded(longPress: longPress)
        default: break
        }
    }

    func getPointA() -> CGPoint {
        pointA
    }
    
    func getCenter() -> CGPoint {
        currentLayer.path?.findCenter() ?? CGPoint()
    }

    func addTag(tag: String) {
        guard let points = currentLayer.path?.points else { return }

        let myAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12) ,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        let myAttributedString = NSAttributedString(string: tag, attributes: myAttributes )

        let label = CATextLayer()
        label.frame = CGRect(x: points[3].x, y: points[3].y + 5, width: 100, height: 15)
//        label.foregroundColor = UIColor.red.cgColor
        label.string = myAttributedString
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        label.cornerRadius = 3
        currentLayer.addSublayer(label)
    }
}

private extension SquareDrawer {
    func addCircles() {
        startCircle.removeFromSuperlayer()
        let startCircle = DrawerHelper.drawCircleForLine(atPoint: pointB,  withColor: .red,   lineWidth: 3)
        self.startCircle = startCircle
        videoView.layer.addSublayer(startCircle)
        
        topRightCircle.removeFromSuperlayer()
        self.topRightCircle = DrawerHelper.drawCircleForLine(atPoint: CGPoint(x: pointB.x, y: pointA.y), withColor: .clear, lineWidth: 3)
        videoView.layer.addSublayer(topRightCircle)
        
        topLeftCircle.removeFromSuperlayer()
        self.topLeftCircle = DrawerHelper.drawCircleForLine(atPoint: pointA, withColor: .clear, lineWidth: 3)
        videoView.layer.addSublayer(topLeftCircle)
        
        bottomLeftCircle.removeFromSuperlayer()
        self.bottomLeftCircle = DrawerHelper.drawCircleForLine(atPoint: CGPoint(x: pointA.x, y: pointB.y), withColor: .clear, lineWidth: 3)
        videoView.layer.addSublayer(bottomLeftCircle)
    }

    func touchesBegan(longPress: UILongPressGestureRecognizer) {
        let point = longPress.location(in: videoView)

        if let path = isTouchIsInCircle(circle: startCircle, longPress: longPress) {
            startCircle.path = DrawerHelper.translate(path: path, by: point)
            resizeSquareBottomRigh(point: point)
            mode = .bottomRightEdit
        } else if let path = isTouchIsInCircle(circle: topRightCircle, longPress: longPress) {
            topRightCircle.path = DrawerHelper.translate(path: path, by: point)
            resizeSquareTopRight(point: point)
            mode = .topRightEdit
        } else if let path = isTouchIsInCircle(circle: topLeftCircle, longPress: longPress) {
            startCircle.path = DrawerHelper.translate(path: path, by: point)
            resizeSquareTopLeft(point: point)
            mode = .topLeftRdit
        } else if let path = isTouchIsInCircle(circle: bottomLeftCircle, longPress: longPress) {
            startCircle.path = DrawerHelper.translate(path: path, by: point)
            resizeSquareBottomLeft(point: point)
            mode = .bottomLeftEdit
        } else if isTouchIsInSquare(longPress: longPress) {
            mode = .move
            lastPoint = point
        }
    }

    func touchesMoved(longPress: UILongPressGestureRecognizer) {
        let point = longPress.location(in: videoView)
        
        switch mode {
        case .move:
            moveShape(to: point)
            lastPoint = point
        case .bottomRightEdit:
            resizeSquareBottomRigh(point: point)
        case .topRightEdit:
            resizeSquareTopRight(point: point)
        case .topLeftRdit:
            resizeSquareTopLeft(point: point)
        case .bottomLeftEdit:
            resizeSquareBottomLeft(point: point)
        case .noEdit:
            break
        }

//        if mode == .move {
//
//        } else if mode == .bottomRightEdit {
////            let path = isTouchIsInCircle(longPress: longPress)
////            let newPath = DrawerHelper.translate2(path: path, by: point)
////            startCircle.path = newPath
//            resizeSquare2(point: point)
//        }
    }

    func touchesEnded(longPress: UILongPressGestureRecognizer) {
        mode = .noEdit
    }

    func isTouchIsInCircle(circle: CAShapeLayer, longPress: UILongPressGestureRecognizer) -> CGPath? {
        let newPoint = longPress.location(in: self.videoView)
        if let path = circle.path {
            if path.contains(newPoint) {
                return path
            }

            let outline = path.copy(strokingWithWidth: 15 * 1.5,
                                    lineCap: .butt,
                                    lineJoin: .round,
                                    miterLimit: 0)
            if outline.contains(newPoint) {
                return path
            }
        }

        return nil
    }

    func isTouchIsInSquare(longPress: UILongPressGestureRecognizer) -> Bool {
        let newPoint = longPress.location(in: self.videoView)

        guard
            let arrayX = currentLayer.path?.points.map(\.x),
            let arrayY = currentLayer.path?.points.map(\.y),
            let minX = arrayX.min(),
            let maxX = arrayX.max(),
            let minY = arrayY.min(),
            let maxY = arrayY.max()
        else { return false}

        if minX < newPoint.x &&
            minY < newPoint.y &&
            maxX > newPoint.x &&
            maxY > newPoint.y {
            return true
        }

        return false
    }

    func resizeSquareBottomRigh(point: CGPoint) {
        guard (point.x - pointA.x) * (point.y - pointA.y) > 3000 && point.y > pointA.y && point.x > pointA.x && point.y < videoView.frame.maxY - 5 else { return }
        currentLayer.removeFromSuperlayer()
        let lineShape = DrawerHelper.drawSquare(from: pointA, to: point, with: .red, lineWidth: 3)
        currentLayer = lineShape
        pointB = point
        videoView.layer.addSublayer(lineShape)
        addCircles()
    }
    
    func resizeSquareTopRight(point: CGPoint) {
        guard (point.x - pointA.x) * (pointB.y - point.y) > 3000 && point.y < pointB.y && point.x > pointA.x && point.y > videoView.frame.minY + 5 else { return }
        currentLayer.removeFromSuperlayer()
        let lineShape = DrawerHelper.drawSquare(from: CGPoint(x: pointA.x, y: point.y), to: CGPoint(x: point.x, y: pointB.y), with: .red, lineWidth: 3)
        currentLayer = lineShape
        pointA = CGPoint(x: pointA.x, y: point.y)
        pointB = CGPoint(x: point.x, y: pointB.y)
        videoView.layer.addSublayer(lineShape)
        addCircles()
    }
    
    func resizeSquareTopLeft(point: CGPoint) {
        guard (pointB.x - point.x) * (pointB.y - point.y) > 3000 && point.y < pointB.y && point.x < pointB.x && point.y > videoView.frame.minY + 5 else { return }
        currentLayer.removeFromSuperlayer()
        let lineShape = DrawerHelper.drawSquare(from: point, to: pointB, with: .red, lineWidth: 3)
        currentLayer = lineShape
        pointA = point
//        pointB = CGPoint(x: point.x, y: pointB.y)
        videoView.layer.addSublayer(lineShape)
        addCircles()
    }
    
    func resizeSquareBottomLeft(point: CGPoint) {
        guard (pointB.x - point.x) * (point.y - pointA.y) > 3000 && point.y > pointA.y && point.x < pointB.x && point.y < videoView.frame.maxY - 5 else { return }
        currentLayer.removeFromSuperlayer()
        let lineShape = DrawerHelper.drawSquare(from: CGPoint(x: point.x, y: pointA.y), to: CGPoint(x: pointB.x, y: point.y), with: .red, lineWidth: 3)
        currentLayer = lineShape
        pointA = CGPoint(x: point.x, y: pointA.y)
        pointB = CGPoint(x: pointB.x, y: point.y)
        videoView.layer.addSublayer(lineShape)
        addCircles()
    }

    func moveShape(to point: CGPoint) {
        let newPath = DrawerHelper.translateSquare2(path: currentLayer.path, by: point, lastPoint: lastPoint)
        if var startEnd = newPath?.getStartMoreDistantsEnd() {
            let saveAreaHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
            if startEnd.start.y < saveAreaHeight {
                startEnd.start = CGPoint(x: startEnd.start.x, y: saveAreaHeight)
                startEnd.end.y = pointB.y
            }
            if startEnd.start.x < 5 {
                startEnd.start = CGPoint(x: 5, y: startEnd.start.y)
                startEnd.end.x = pointB.x
            }
            if startEnd.end.y > videoView.frame.maxY - 5 {
                startEnd.end = CGPoint(x: startEnd.end.x, y: videoView.frame.maxY - 5)
                startEnd.start.y = pointA.y
            }
            if startEnd.end.x > videoView.frame.maxX - 5  {
                startEnd.end = CGPoint(x: videoView.frame.maxX - 5, y: startEnd.end.y)
                startEnd.start.x = pointA.x
            }
            currentLayer.removeFromSuperlayer()
            currentLayer = DrawerHelper.drawSquare(from: startEnd.start, to: startEnd.end, with: .red, lineWidth: 3)
            pointA = startEnd.start
            pointB = startEnd.end
            videoView.layer.addSublayer(currentLayer)
        }
        addCircles()
    }
}
