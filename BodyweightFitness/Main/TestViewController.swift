import SnapKit
import Charts
import RealmSwift

class CardSegmentedControl: UISegmentedControl {
    var buttonBar: UIView? = nil
}

class TestViewController: AbstractViewController {
    var widthConstraint: Constraint? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeContent()
    }

    override func initializeContent() {
        super.initializeContent()

        self.navigationItem.title = "Test"

        self.addView(self.createTestCard())
    }

    func createTestCard() -> CardView {
        let card = CardView()

        let segmentedControl = CardSegmentedControl()
        segmentedControl.insertSegment(withTitle: "1W", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "1M", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "3M", at: 2, animated: true)
        segmentedControl.insertSegment(withTitle: "6M", at: 3, animated: true)
        segmentedControl.insertSegment(withTitle: "1Y", at: 4, animated: true)
        segmentedControl.insertSegment(withTitle: "ALL", at: 5, animated: true)

        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        segmentedControl.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.lightGray
        ], for: .normal)

        segmentedControl.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.primary()
        ], for: .selected)

        let buttonBar = UIView()
        buttonBar.backgroundColor = UIColor.primary()

        card.addSubview(segmentedControl)
        card.addSubview(buttonBar)

        segmentedControl.buttonBar = buttonBar
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: UIControlEvents.valueChanged)

        segmentedControl.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)

            make.height.equalTo(36)
        }

        buttonBar.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.left.equalTo(segmentedControl.snp.left)
            make.bottom.equalTo(card).offset(-8)

            make.width.equalTo(segmentedControl.snp.width).multipliedBy(1 / CGFloat(segmentedControl.numberOfSegments)).constraint

            make.height.equalTo(3)
        }

        return card
    }

    func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if let cardSegmentedControl = sender as? CardSegmentedControl {
            UIView.animate(withDuration: 0.2) {
                let offset = ((cardSegmentedControl.frame.width) / CGFloat(cardSegmentedControl.numberOfSegments)) * CGFloat(cardSegmentedControl.selectedSegmentIndex)

                cardSegmentedControl.buttonBar?.frame.origin.x = offset + 16
            }
        }
    }
}
