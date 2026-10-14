import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #2C241B
    static let bg = Color(red: 0.172549, green: 0.141176, blue: 0.105882)
    static let bgHex = "#2C241B"
    /// #3D3D29
    static let surface = Color(red: 0.239216, green: 0.239216, blue: 0.160784)
    static let surfaceHex = "#3D3D29"
    /// #F4F2F1
    static let ink = Color(red: 0.956863, green: 0.949020, blue: 0.945098)
    static let inkHex = "#F4F2F1"
    /// #E7E75F
    static let accent = Color(red: 0.905882, green: 0.905882, blue: 0.372549)
    static let accentHex = "#E7E75F"
    /// #BFB8B0
    static let muted = Color(red: 0.749020, green: 0.721569, blue: 0.690196)
    static let mutedHex = "#BFB8B0"
    static let fontFamily = "Hoefler Text"
}
