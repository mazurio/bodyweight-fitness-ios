import UIKit

/// The JTAppleDayCell class defines the attributes and behavior of the cells that appear in JTAppleCalendarView objects.
public class JTAppleDayCell: UICollectionViewCell, JTAppleReusableViewProtocolTrait {
	var view: JTAppleDayCellView?
    func updateCellView(cellInsetX: CGFloat, cellInsetY: CGFloat) {
        let vFrame = CGRectInset(self.frame, cellInsetX, cellInsetY)
        view!.frame = vFrame
        view!.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	/// Returns an object initialized from data in a given unarchiver.
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
