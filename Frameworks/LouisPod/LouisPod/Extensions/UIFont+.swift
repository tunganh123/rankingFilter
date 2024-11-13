//
//  UIFont+.swift
//  BaseProjectFramework
//
//  Created by nguyen.viet.luy on 15/11/2022.
//

import UIKit

extension UIFont {
    public enum SFProWeight: String {
        case regular = "SFProDisplay-Regular"
        case medium = "SFProDisplay-Medium"
        case semibold = "SFProDisplay-Semibold"
        case bold = "SFProDisplay-Bold"
    }
    
    static public func sfproFont(weight: SFProWeight, size: CGFloat) -> UIFont {
        let font = UIFont(name: weight.rawValue, size: size)!
        return Common.getFontForDeviceWithFontDefault(fontDefault: font)
    }
    
    public enum MulishWeight: String {
        case regular = "Mulish-Regular"
        case medium = "Mulish-Medium"
        case semibold = "Mulish-Semibold"
        case bold = "Mulish-Bold"
    }
    
    static public func mulish(weight: MulishWeight, size: CGFloat) -> UIFont {
        let font = UIFont(name: weight.rawValue, size: size)!
        return Common.getFontForDeviceWithFontDefault(fontDefault: font)
    }
}

extension UIFont {
    public class func Averta_Bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvertaStdCY-Bold", size: size)!
    }
    
    public class func Averta_Black(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvertaStdCY-Black", size: size)!
    }
    
    public class func Averta_Regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvertaStdCY-Regular", size: size)!
    }
    
    public class func LibreBaskerville(_ size: CGFloat) -> UIFont {
        return UIFont(name: "LibreBaskerville-Regular", size: size)!
    }
    
    public class func LibreBaskerville_Bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "LibreBaskerville-Bold", size: size)!
    }
    
    public class func Monoton(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Monoton-Regular", size: size)!
    }
    
    public class func Montaga(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Montaga-Regular", size: size)!
    }
    
    public class func Nosifer(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Nosifer-Regular", size: size)!
    }
    
    public class func UTM_Gradoo(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UTM-Gradoo", size: size)!
    }
    
    public class func UTM_Aircona(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UTM-Aircona", size: size)!
    }
    
    public class func Nunito_Regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Nunito-Regular", size: size)!
    }
    
    public class func Inter_Regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Inter-Regular", size: size)!
    }
    
    public class func Inter_SemiBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Inter-SemiBold", size: size)!
    }
    
    public class func Inter_Medium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Inter-Medium", size: size)!
    }
    
    public class func Inter_Bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Inter-Bold", size: size)!
    }
    
    public class func DINCond_Bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "DINCond-Bold", size: size)!
    }
    
    public class func IM_Fell_Greate_Primer(_ size: CGFloat) -> UIFont {
        return UIFont(name: "IM_FELL_Great_Primer_SC", size: size)!
    }
    
    public class func Halloween_Inline(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Halloweninline", size: size)!
    }
    
    public class func Spirax_Regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Spirax-Regular", size: size)!
    }
    
    public class func ChristmasSheep(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Christmas Sheep", size: size)!
    }
    
    public class func NerkoOne(_ size: CGFloat) -> UIFont {
        return UIFont(name: "NerkoOne-Regular", size: size)!
    }
    
    public class func MacondoSwashCaps(_ size: CGFloat) -> UIFont {
        return UIFont(name: "MacondoSwashCaps-Regular", size: size)!
    }
    
    public class func KaushanScript(_ size: CGFloat) -> UIFont {
        return UIFont(name: "KaushanScript-Regular", size: size)!
    }
    
    public class func DancingScript(_ size: CGFloat) -> UIFont {
        return UIFont(name: "DancingScript-Regular", size: size)!
    }
    
    public class func LuckiestGuy(_ size: CGFloat) -> UIFont {
        return UIFont(name: "LuckiestGuy-Regular", size: size)!
    }
    
    public class func Yellowtail(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Yellowtail-Regular", size: size)!
    }
    
    public class func GreatVibes(_ size: CGFloat) -> UIFont {
        return UIFont(name: "GreatVibes-Regular", size: size)!
    }
    
    public class func UTM_Alter_Gothic(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UTM-Alter-Gothic", size: size)!
    }
    
    public class func Gunplay(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Gunplay-Regular", size: size)!
    }
    
    public class func OPTIPrisma_Caps(_ size: CGFloat) -> UIFont {
        return UIFont(name: "OPTIPrisma-Caps", size: size)!
    }
    
    public class func TwCenClassMTStd(_ size: CGFloat) -> UIFont {
        return UIFont(name: "TwCenClassMTStd-Regular", size: size)!
    }
    
    public class func Hurson(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Hurson", size: size)!
    }
    
    public class func Tw_Cen_MT_Condensed(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Tw Cen MT Condensed Extra Bold", size: size)!
    }
    
    public class func Aptima_Bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "VNI-Aptima-Bold", size: size)!
    }
    
    public class func Krunch_Bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Krunch-Bold", size: size)!
    }
    
    public class func Roboto_Medium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Medium", size: size)!
    }
    
    public class func Itim_Regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Itim-Regular", size: size)!
    }
}
