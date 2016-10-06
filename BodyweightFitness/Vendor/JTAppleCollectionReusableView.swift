import UIKit

public class JTAppleCollectionReusableView: UICollectionReusableView, JTAppleReusableViewProtocolTrait {
    var view: JTAppleHeaderView?
    func update() {
        view!.frame = self.frame
        view!.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
