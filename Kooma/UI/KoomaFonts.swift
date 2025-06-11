
import Foundation
import SwiftUI

private enum FontsName: String {
	case plusJakartaItalic = " PlusJakartaSans-Italic"
	case plusJakarta = "PlusJakartaSans-VariableFont_wght"
	case plusJakarteBold = "PlusJakartaSans-Regular_Bold"
	case plusJakarteExtraBold = "PlusJakartaSans-Regular_ExtraBold"
	case plusJakarteSemiBold = " PlusJakartaSans-Regular_SemiBold"
	case plusJakarteBody = "PlusJakartaSans-Regular"

}


extension Font {
	static let heading800 = Font.custom(FontsName.plusJakarteBold.rawValue, size: 28)
	static let heading600: Font = Font.custom(FontsName.plusJakarteBold.rawValue, size: 22)
	static let heading400: Font = Font.custom(FontsName.plusJakarteBold.rawValue, size: 18)
	static let heading200: Font = Font.custom(FontsName.plusJakarteBold.rawValue, size: 16)
	static let bodyLarge: Font = Font.custom(FontsName.plusJakarteBody.rawValue, size: 16)
	static let bodyMedium: Font = Font.custom(FontsName.plusJakarteBody.rawValue, size: 14)

}

/*

 PlusJakartaSans-Italic
 PlusJakartaSans-Italic_Bold-Italic
 PlusJakartaSans-Italic_ExtraBold-Italic
 PlusJakartaSans-Italic_ExtraLight-Italic
 PlusJakartaSans-Italic_Light-Italic
 PlusJakartaSans-Italic_Medium-Italic
 PlusJakartaSans-Italic_SemiBold-Italic
 PlusJakartaSans-Regular
 PlusJakartaSans-Regular_Bold
 PlusJakartaSans-Regular_ExtraBold
 PlusJakartaSans-Regular_ExtraLight
 PlusJakartaSans-Regular_Light
 PlusJakartaSans-Regular_Medium
 PlusJakartaSans-Regular_SemiBold


 */
