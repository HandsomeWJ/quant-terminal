// Draws the app icon (the page's favicon: a rising line on a blue tile) into an .iconset folder
// for iconutil. Usage: make-icon <folder>.iconset
import AppKit

let folder = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
for (name, pixels) in [
  ("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64), ("128x128", 128),
  ("128x128@2x", 256), ("256x256", 256), ("256x256@2x", 512), ("512x512", 512), ("512x512@2x", 1024),
] {
  let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8, samplesPerPixel: 4,
    hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  let scale = CGFloat(pixels) / 1024
  // Apple's icon grid: an 824-point tile with rounded corners, centred on a 1024-point canvas.
  let tile = NSRect(x: 100 * scale, y: 100 * scale, width: 824 * scale, height: 824 * scale)
  let shape = NSBezierPath(roundedRect: tile, xRadius: 185 * scale, yRadius: 185 * scale)
  NSGradient(
    starting: NSColor(srgbRed: 0.27, green: 0.49, blue: 1, alpha: 1),
    ending: NSColor(srgbRed: 0.10, green: 0.31, blue: 0.86, alpha: 1))!.draw(in: shape, angle: -90)
  // The favicon's line, 7,21 13,14 18,18 25,9 on its 32-unit grid (y runs down there).
  let points = [(7.0, 21.0), (13.0, 14.0), (18.0, 18.0), (25.0, 9.0)].map {
    NSPoint(x: tile.minX + $0.0 / 32 * tile.width, y: tile.maxY - $0.1 / 32 * tile.height)
  }
  let line = NSBezierPath()
  line.move(to: points[0])
  points.dropFirst().forEach { line.line(to: $0) }
  line.lineWidth = 3 / 32 * tile.width
  line.lineCapStyle = .round
  line.lineJoinStyle = .round
  NSColor.white.setStroke()
  line.stroke()
  NSGraphicsContext.restoreGraphicsState()
  try rep.representation(using: .png, properties: [:])!.write(to: folder.appendingPathComponent("icon_\(name).png"))
}
