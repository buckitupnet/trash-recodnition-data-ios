//
//  DrawerHelper.swift
//  TrashApp
//
//  Created by Volodymyr Nazarkevych on 13.06.2022.
//

import UIKit


class DrawerHelper {
    static func drawSquare(from start: CGPoint,
                           to end: CGPoint,
                           with color: UIColor,
                           lineWidth: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: start.x, y: start.y))
        path.addLine(to: CGPoint(x: end.x, y: start.y))
        path.addLine(to: CGPoint(x: end.x, y: end.y))
        path.addLine(to: CGPoint(x: start.x, y: end.y))
        path.addLine(to: CGPoint(x: start.x, y: start.y - 1))

        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth

        shapeLayer.lineJoin = CAShapeLayerLineJoin.miter
        return shapeLayer
    }

    static func drawCircleForLine(atPoint point: CGPoint,
                                  withColor color: UIColor,
                                  lineWidth: CGFloat,
                                  radius: CGFloat = 7) -> CAShapeLayer {
        let path = UIBezierPath(arcCenter: point,
                                radius: radius,
                                startAngle: 0.0,
                                endAngle: .pi * 2,
                                clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = color.cgColor

        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = path.cgPath

        return shapeLayer
    }

    static func translate(path: CGPath?, by point: CGPoint) -> CGPath? {
        guard let prevPath = path else { return nil }
        let bezeirPath = UIBezierPath()
        bezeirPath.cgPath = prevPath
        let xDelta = prevPath.findCenter().x
        let yDelta = prevPath.findCenter().y
  
        bezeirPath.apply(CGAffineTransform(translationX: point.x - xDelta, y: point.y - yDelta))

        return bezeirPath.cgPath
    }
    
    static func translateSquare2(path: CGPath?, by point: CGPoint, lastPoint: CGPoint) -> CGPath? {
        guard let prevPath = path else { return nil }
        let bezeirPath = UIBezierPath()
        bezeirPath.cgPath = prevPath
        let x = point.x - lastPoint.x
        let y = point.y - lastPoint.y
        bezeirPath.apply(CGAffineTransform(translationX: x, y: y))

        return bezeirPath.cgPath
    }

    static func translateSquare(path: CGPath?, by point: CGPoint, lastPoint: CGPoint) -> CGPath? {
        guard let prevPath = path else { return nil }
        let bezeirPath = UIBezierPath()

        let (startPoint, endPoint) = prevPath.getStartEndLessDistance(to: lastPoint)

        let pointX = endPoint.x - startPoint.x
        let pointY = endPoint.y - startPoint.y

        let sum = (pow(pointX, 2) + pow(pointY, 2))
        if sum == 0.0 { return nil }
        let total = (pointX * lastPoint.x + pointY * lastPoint.y - pointX * startPoint.x - pointY * startPoint.y) / sum

        bezeirPath.cgPath = prevPath

        let xDelta = pointX * total + startPoint.x
        let yDelta = pointY * total + startPoint.y

        bezeirPath.apply(CGAffineTransform(translationX: point.x - xDelta, y: point.y - yDelta))

        return bezeirPath.cgPath
    }

    static func translate2(path: CGPath?, by point: CGPoint) -> CGPath? {
        guard let prevPath = path else { return nil }
        let bezeirPath = UIBezierPath()
        bezeirPath.cgPath = prevPath
        let closest = prevPath.getClosesPoint(to: point)
        let xDelta = closest.x
        let yDelta = closest.y
        bezeirPath.apply(CGAffineTransform(translationX: point.x - xDelta, y: point.y - yDelta))

        return bezeirPath.cgPath
    }
}





extension CGPath {
    var points: [CGPoint] {

        /// this is a local transient container where we will store our CGPoints
        var arrPoints: [CGPoint] = []

        // applyWithBlock lets us examine each element of the CGPath, and decide what to do
        self.applyWithBlock { element in

            switch element.pointee.type {
            case .moveToPoint, .addLineToPoint:
                arrPoints.append(element.pointee.points.pointee)

            case .addQuadCurveToPoint:
                arrPoints.append(element.pointee.points.pointee)
                arrPoints.append(element.pointee.points.advanced(by: 1).pointee)

            case .addCurveToPoint:
                arrPoints.append(element.pointee.points.pointee)
                arrPoints.append(element.pointee.points.advanced(by: 1).pointee)
                arrPoints.append(element.pointee.points.advanced(by: 2).pointee)

            default:
                break
            }
        }

        // We are now done collecting our CGPoints and so we can return the result
        return arrPoints
    }

    func findCenter() -> CGPoint {
        class Context {
            var sumX: CGFloat = 0
            var sumY: CGFloat = 0
            var points = 0
        }

        var context = Context()

        apply(info: &context) { (context, element) in
            guard let context = context?.assumingMemoryBound(to: Context.self).pointee else {
                return
            }
            switch element.pointee.type {
            case .moveToPoint, .addLineToPoint:
                let point = element.pointee.points[0]
                context.sumX += point.x
                context.sumY += point.y
                context.points += 1
            case .addQuadCurveToPoint:
                let controlPoint = element.pointee.points[0]
                let point = element.pointee.points[1]
                context.sumX += point.x + controlPoint.x
                context.sumY += point.y + controlPoint.y
                context.points += 2
            case .addCurveToPoint:
                let controlPoint1 = element.pointee.points[0]
                let controlPoint2 = element.pointee.points[1]
                let point = element.pointee.points[2]
                context.sumX += point.x + controlPoint1.x + controlPoint2.x
                context.sumY += point.y + controlPoint1.y + controlPoint2.y
                context.points += 3
            case .closeSubpath: break
            default: break
            }
        }

        return CGPoint(x: context.sumX / CGFloat(context.points),
                       y: context.sumY / CGFloat(context.points))
    }

    func getStartEndLessDistance(to point: CGPoint) -> (start: CGPoint, end: CGPoint) {
        let points = points
        guard let start = points.first else { return (start: .zero, end: .zero) }
        var end = points[1] // else { return (start: .zero, end: .zero) }

        var distanceStart = start.distance(to: point)
        var distance = start.distance(to: point)
        var startPoint = start
        var endPoint = end
        points.forEach { element in
            let newDistance = element.distance(to: point)
            if newDistance < distanceStart {
                distanceStart = newDistance
                startPoint = element
            }
        }

        if distance == end.distance(to: point) {
            end = points[points.count - 2]
            distance = end.distance(to: point)
        } else {
            distance = end.distance(to: point)
        }

        points.forEach { element in
            let newDistance = element.distance(to: point)
            if newDistance < distance && startPoint != element && distance != distance {
                distance = newDistance
                endPoint = element
            }
        }

        return (start: startPoint, end: endPoint)
    }

    func getStartMoreDistantsEnd() -> (start: CGPoint, end: CGPoint)? {
        let points = points
        guard let start = points.first,
              var end = points.last else { return nil }

        var distance = start.distance(to: end)
        points.forEach { point in
            let newDistance = start.distance(to: point)
            if distance < newDistance {
                distance = newDistance
                end = point
            }
        }
        return (start: start, end: end)
    }

    func getClosesPoint(to point: CGPoint) -> CGPoint {
        let points = points
        guard let start = points.first else { return .zero }

        var distance = start.distance(to: point)
        var closesPoint = start
        points.forEach { element in
            let newDistance = element.distance(to: point)
            if newDistance < distance {
                distance = newDistance
                closesPoint = element
            }
        }

        return closesPoint
    }

}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }
}
