import AppKit

// Compose store-sized graphics from the existing app icon; no simulated UI.
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let output = root.appendingPathComponent("store_assets/2.0.1")
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
let icon = NSImage(contentsOf: root.appendingPathComponent("assets/icon/icon.png"))!

func render(_ name: String, width: Int, height: Int, draw: () -> Void) throws {
    let context = CGContext(data: nil, width: width, height: height,
        bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    draw()
    NSGraphicsContext.restoreGraphicsState()
    let bitmap = NSBitmapImageRep(cgImage: context.makeImage()!)
    try bitmap.representation(using: .png, properties: [:])!.write(to: output.appendingPathComponent(name))
}

func text(_ value: String, x: CGFloat, y: CGFloat, size: CGFloat, color: NSColor, weight: NSFont.Weight = .semibold) {
    (value as NSString).draw(at: NSPoint(x: x, y: y), withAttributes: [
        .font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color
    ])
}

try render("google-play-icon.png", width: 512, height: 512) {
    NSColor.white.setFill()
    NSRect(x: 0, y: 0, width: 512, height: 512).fill()
    icon.draw(in: NSRect(x: 0, y: 0, width: 512, height: 512))
}

try render("google-play-feature.png", width: 1024, height: 500) {
    let background = NSGradient(starting: NSColor(red: 0.025, green: 0.055, blue: 0.13, alpha: 1),
        ending: NSColor(red: 0.035, green: 0.23, blue: 0.30, alpha: 1))!
    background.draw(in: NSRect(x: 0, y: 0, width: 1024, height: 500), angle: 25)
    NSColor(red: 0.92, green: 0.72, blue: 0.29, alpha: 1).setFill()
    NSRect(x: 52, y: 68, width: 920, height: 3).fill()
    icon.draw(in: NSRect(x: 52, y: 138, width: 256, height: 256))
    let gold = NSColor(red: 1, green: 0.81, blue: 0.35, alpha: 1)
    text("MM PROPERTY", x: 350, y: 307, size: 46, color: gold, weight: .heavy)
    text("TYCOON", x: 350, y: 246, size: 58, color: .white, weight: .heavy)
    text("Game night. A whole new dimension.", x: 352, y: 197, size: 23, color: .white)
    text("3D CITY BOARDS  •  2–4 PLAYERS  •  OFFLINE", x: 54, y: 96, size: 21,
         color: NSColor(red: 0.70, green: 0.92, blue: 0.92, alpha: 1))
}
