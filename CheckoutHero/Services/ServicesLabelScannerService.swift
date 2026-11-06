//
//  ServicesLabelScannerService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 7/3/26.
//

import Foundation
import Vision
import UIKit

struct LabelScannerService {

    struct ParsedLabel {
        var productName: String?
        var price: Decimal?
        var currencySymbol: String?
        var rawText: String
    }

    /// Recognize text in an image using Vision, then parse it as a supermarket label.
    static func scan(image: UIImage) async -> ParsedLabel {
        let recognized = await recognizeText(in: image)
        return parse(lines: recognized)
    }

    /// Recognize text lines from a UIImage using VNRecognizeTextRequest.
    static func recognizeText(in image: UIImage) async -> [String] {
        guard let cgImage = image.cgImage else { return [] }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: lines)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Vision recognition error: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }

    /// Parse recognized text lines to extract product name and price.
    static func parse(lines: [String]) -> ParsedLabel {
        let joined = lines.joined(separator: "\n")

        let (price, symbol, priceLineIndex) = extractPrice(from: lines)
        let productName = extractProductName(from: lines, excluding: priceLineIndex)

        return ParsedLabel(
            productName: productName,
            price: price,
            currencySymbol: symbol,
            rawText: joined
        )
    }

    // MARK: - Private parsing helpers

    /// Match common currency price patterns. Captures the numeric value and a symbol when present.
    /// Supports $X.XX, £X.XX, €X.XX, X,XX€, X.XX£, R$X.XX, etc.
    private static let priceRegex: NSRegularExpression = {
        // Group 1: leading symbol; Group 2: number; Group 3: trailing symbol
        let pattern = #"(?<leading>[$£€¥₪₽₹R\$]{1,2})?\s*(?<num>\d{1,4}(?:[.,]\d{2}))\s*(?<trailing>[$£€¥₪₽₹]{1,2})?"#
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    private static func extractPrice(from lines: [String]) -> (Decimal?, String?, Int?) {
        var bestPrice: Decimal?
        var bestSymbol: String?
        var bestIndex: Int?

        for (index, line) in lines.enumerated() {
            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            guard let match = priceRegex.firstMatch(in: line, options: [], range: range) else { continue }

            let numRange = match.range(withName: "num")
            guard numRange.location != NSNotFound,
                  let swiftRange = Range(numRange, in: line) else { continue }

            let numString = String(line[swiftRange]).replacingOccurrences(of: ",", with: ".")
            guard let value = Decimal(string: numString) else { continue }

            var symbol: String?
            let leadingRange = match.range(withName: "leading")
            if leadingRange.location != NSNotFound, let r = Range(leadingRange, in: line) {
                symbol = String(line[r])
            }
            let trailingRange = match.range(withName: "trailing")
            if symbol == nil, trailingRange.location != NSNotFound, let r = Range(trailingRange, in: line) {
                symbol = String(line[r])
            }

            // Prefer the largest price found — supermarket labels usually make the main price largest,
            // and Vision returns lines roughly in reading order regardless of font size.
            if bestPrice == nil || (value > (bestPrice ?? 0)) {
                bestPrice = value
                bestSymbol = symbol
                bestIndex = index
            }
        }

        return (bestPrice, bestSymbol, bestIndex)
    }

    /// Pick the longest alphabetic line (not the price line) as the product name.
    private static func extractProductName(from lines: [String], excluding priceLineIndex: Int?) -> String? {
        let candidates = lines.enumerated().compactMap { (index, line) -> String? in
            if index == priceLineIndex { return nil }
            let letters = line.filter { $0.isLetter }
            guard letters.count >= 3 else { return nil }
            return line.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return candidates.max(by: { $0.count < $1.count })
    }
}
