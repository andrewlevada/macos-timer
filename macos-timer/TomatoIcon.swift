import SwiftUI

struct TomatoIcon: View {
    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let color = Color(nsColor: .labelColor)

            var body = Path()
            body.addEllipse(in: CGRect(x: width * 0.14, y: height * 0.28, width: width * 0.72, height: height * 0.64))
            context.fill(body, with: .color(color))

            var stem = Path()
            stem.move(to: CGPoint(x: width * 0.5, y: height * 0.3))
            stem.addLine(to: CGPoint(x: width * 0.5, y: height * 0.12))
            context.stroke(stem, with: .color(color), lineWidth: max(1, width * 0.1))

            var leftLeaf = Path()
            leftLeaf.move(to: CGPoint(x: width * 0.5, y: height * 0.18))
            leftLeaf.addQuadCurve(
                to: CGPoint(x: width * 0.24, y: height * 0.08),
                control: CGPoint(x: width * 0.3, y: height * 0.22)
            )
            leftLeaf.addQuadCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.16),
                control: CGPoint(x: width * 0.34, y: height * 0.1)
            )
            context.fill(leftLeaf, with: .color(color))

            var rightLeaf = Path()
            rightLeaf.move(to: CGPoint(x: width * 0.5, y: height * 0.18))
            rightLeaf.addQuadCurve(
                to: CGPoint(x: width * 0.76, y: height * 0.08),
                control: CGPoint(x: width * 0.7, y: height * 0.22)
            )
            rightLeaf.addQuadCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.16),
                control: CGPoint(x: width * 0.66, y: height * 0.1)
            )
            context.fill(rightLeaf, with: .color(color))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
