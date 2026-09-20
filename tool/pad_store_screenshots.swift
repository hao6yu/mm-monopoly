import AppKit

// Preserve every source pixel and its aspect ratio; add a plain navy border.
// Usage: swift tool/pad_store_screenshots.swift <originals> <output> [iphone|play-phone|play-tablet]
guard (3...4).contains(CommandLine.arguments.count) else { fatalError("Expected source and output directories") }
let source = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
let isPhone = CommandLine.arguments.last == "iphone"
let isPlayPhone = CommandLine.arguments.last == "play-phone"
let isPlayTablet = CommandLine.arguments.last == "play-tablet"
let filenames = try FileManager.default.contentsOfDirectory(atPath: source.path).filter { $0.hasSuffix(".png") }.sorted()
for filename in filenames {
    let image = NSImage(contentsOf: source.appendingPathComponent(filename))!
    let original = NSBitmapImageRep(data: try Data(contentsOf: source.appendingPathComponent(filename)))!
    let portrait = original.pixelsHigh > original.pixelsWide
    let shortSide = isPlayPhone ? 1620 : isPlayTablet ? 1908 : isPhone ? 1284 : 2064
    let longSide = isPlayPhone ? 2880 : isPlayTablet ? 3392 : isPhone ? 2778 : 2752
    let width = portrait ? shortSide : longSide
    let height = portrait ? longSide : shortSide
    let cgContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
        bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    let context = NSGraphicsContext(cgContext: cgContext, flipped: false)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    NSColor(srgbRed: 0.025, green: 0.065, blue: 0.12, alpha: 1).setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()
    // These originals fit inside the target canvas, so no scaling is needed.
    precondition(original.pixelsWide <= width && original.pixelsHigh <= height)
    image.draw(in: NSRect(x: (width - original.pixelsWide) / 2,
                         y: (height - original.pixelsHigh) / 2,
                         width: original.pixelsWide, height: original.pixelsHigh),
               from: .zero, operation: .copy, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()
    let bitmap = NSBitmapImageRep(cgImage: cgContext.makeImage()!)
    let destination = output.appendingPathComponent(filename)
    try bitmap.representation(using: .png, properties: [:])!.write(to: destination)
    print("\(filename): \(original.pixelsWide)×\(original.pixelsHigh) → \(width)×\(height), padding only")
}
