//
//  Daisy.swift
//  Yoda (iOS)
//
//  Created by Titouan Van Belle on 19.01.21.
//

import SwiftUI

enum FontFamily: String {
    case poppinsBlack = "Poppins-Black"
    case poppinsBlackItalic = "Poppins-BlackItalic"
    case poppinsBold = "Poppins-Bold"
    case poppinsBoldItalic = "Poppins-BoldItalic"
    case poppinsExtraBold = "Poppins-ExtraBold"
    case poppinsExtraBoldItalic = "Poppins-ExtraBoldItalic"
    case poppinsExtraLight = "Poppins-ExtraLight"
    case poppinsExtraLightItalic = "Poppins-ExtraLightItalic"
    case poppinsItalic = "Poppins-Italic"
    case poppinsLight = "Poppins-Light"
    case poppinsLightItalic = "Poppins-LightItalic"
    case poppinsMedium = "Poppins-Medium"
    case poppinsMediumItalic = "Poppins-MediumItalic"
    case poppinsRegular = "Poppins-Regular"
    case poppinsSemiBold = "Poppins-SemiBold"
    case poppinsSemiBoldItalic = "Poppins-SemiBoldItalic"
    case poppinsThin = "Poppins-Thin"
    case poppinsThinItalic = "Poppins-ThinItalic"

    case interBlack = "Inter-Black"
    case interBold = "Inter-Bold"
    case interExtraBold = "Inter-ExtraBold"
    case interExtraLight = "Inter-ExtraLight"
    case interLight = "Inter-Light"
    case interMedium = "Inter-Medium"
    case interRegular = "Inter-Regular"
    case interSemiBold = "Inter-SemiBold"
    case interThin = "Inter-Thin"
}

fileprivate extension Font {
    init(_ fontFamily: FontFamily, size: CGFloat) {
        self = Font.custom(fontFamily.rawValue, size: size)
    }
}

fileprivate extension UIFont {
    convenience init(_ fontFamily: FontFamily, size: CGFloat) {
        self.init(name: fontFamily.rawValue, size: size)!
    }
}

struct Daisy {

    struct Typography {
        let h0 = Font(.poppinsSemiBold, size: 60)
        let h1 = Font(.poppinsSemiBold, size: 48)
        let h2 = Font(.poppinsSemiBold, size: 40)
        let h3 = Font(.poppinsSemiBold, size: 36)
        let h4 = Font(.poppinsSemiBold, size: 32)
        let h5 = Font(.poppinsSemiBold, size: 24)
        let h6 = Font(.poppinsSemiBold, size: 20)
        let h7 = Font(.poppinsSemiBold, size: 16)

        let largeTitle = Font(.interSemiBold, size: 16)
        let smallTitle = Font(.interSemiBold, size: 14)
        let largeButton = Font(.interBold, size: 16)
        let smallButton = Font(.interBold, size: 14)
        let tab = Font(.interSemiBold, size: 14)
        let largeBody = Font(.interMedium, size: 14)
        let smallBody = Font(.interMedium, size: 13)
        let smallBodyBold = Font(.interBold, size: 13)
        let smallBodyRegular = Font(.interRegular, size: 13)
        let largeCaption = Font(.interMedium, size: 12)
        let smallCaption = Font(.interMedium, size: 11)
        let chip = Font(.interBold, size: 10)
    }

    struct UITypography {
        let h0 = UIFont(.poppinsSemiBold, size: 60)
        let h1 = UIFont(.poppinsSemiBold, size: 48)
        let h2 = UIFont(.poppinsSemiBold, size: 40)
        let h3 = UIFont(.poppinsSemiBold, size: 36)
        let h4 = UIFont(.poppinsSemiBold, size: 32)
        let h5 = UIFont(.poppinsSemiBold, size: 24)
        let h6 = UIFont(.poppinsSemiBold, size: 20)
        let h7 = UIFont(.poppinsSemiBold, size: 16)

        let largeTitle = UIFont(.interSemiBold, size: 16)
        let smallTitle = UIFont(.interSemiBold, size: 14)
        let largeButton = UIFont(.interBold, size: 16)
        let smallButton = UIFont(.interBold, size: 14)
        let tab = UIFont(.interSemiBold, size: 14)
        let largeBody = UIFont(.interMedium, size: 14)
        let smallBody = UIFont(.interMedium, size: 13)
        let smallBodyBold = UIFont(.interBold, size: 13)
        let smallBodyRegular = UIFont(.interRegular, size: 13)
        let largeCaption = UIFont(.interMedium, size: 12)
        let smallCaption = UIFont(.interMedium, size: 11)
        let chip = UIFont(.interBold, size: 10)
    }

    struct Palette {
        let white = Color.white
        let black = Color.black
        let error = Color("Error")
        let primaryForeground = Color("PrimaryForeground")
        let secondaryForeground = Color("SecondaryForeground")
        let primaryBackground = Color("PrimaryBackground")
        let secondaryBackground = Color("SecondaryBackground")
        let tertiaryForeground = Color("TertiaryForeground")
        let quartiaryForeground = Color("QuartiaryForeground")
    }

    struct UIPalette {
        let white = UIColor.white
        let black = UIColor.black
        let primaryForeground = UIColor(named: "PrimaryForeground")!
        let secondaryForeground = UIColor(named: "SecondaryForeground")!
        let primaryBackground = UIColor(named: "PrimaryBackground")!
        let secondaryBackground = UIColor(named: "SecondaryBackground")!
        let tertiaryForeground = UIColor(named: "TertiaryForeground")!
        let quartiaryForeground = UIColor(named: "QuartiaryForeground")!
    }

    static let font = Typography()
    static let uiFont = UITypography()
    static let color = Palette()
    static let uiColor = UIPalette()
}
