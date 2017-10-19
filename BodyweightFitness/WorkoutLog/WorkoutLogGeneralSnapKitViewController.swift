import SnapKit

class TitleLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.textAlignment = .left
        self.font = UIFont.systemFont(ofSize: 20)
        self.textColor = UIColor.black
    }
}

class DescriptionTextView: UITextView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.textAlignment = .left
        self.font = UIFont.systemFont(ofSize: 17)
        self.textColor = UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 1.00)
        self.isEditable = false
        self.isSelectable = false
    }
}

class CardButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.contentHorizontalAlignment = .left
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.setTitleColor(UIColor.primaryDark(), for: .normal)
    }
}

class WorkoutLogGeneralSnapKitViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    func initializeScrollView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(scrollView)
            make.left.right.equalTo(view)
        }
    }
    
    func createTodaysProgressCard() -> CardView {
        let card = CardView()
        self.contentView.addSubview(card)
        
        let label = TitleLabel()
        label.text = "Today's Progress"
        card.addSubview(label)
        
        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            
            make.height.equalTo(24)
        }
        
        let cardButton = CardButton()
        cardButton.setTitle("Start Workout", for: .normal)
        card.addSubview(cardButton)
        
        cardButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(label.snp.bottom).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)
            
            make.height.equalTo(36)
        }
        
        return card
    }
    
    func createAboutRoutineCard() -> CardView {
        let card = CardView()
        self.contentView.addSubview(card)
        
        let label = TitleLabel()
        label.text = "Bodyweight Fitness"
        card.addSubview(label)
        
        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            
            make.height.equalTo(24)
        }
        
        let textView = DescriptionTextView()
        textView.text = "Many people want to improve overall flexibility, but do not know where to begin. This routine should serve as a general jumping-off point for beginners."
        let sizeThatFits = textView.sizeThatFits(CGSize(width: view.frame.width, height: CGFloat(MAXFLOAT)))
        card.addSubview(textView)
        
        let cardButton = CardButton()
        cardButton.setTitle("Read More", for: .normal)
        card.addSubview(cardButton)
        
        textView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.left.equalTo(card).offset(12)
            make.right.equalTo(card).offset(-12)
            make.bottom.equalTo(cardButton.snp.top).offset(-12)
            
            make.height.equalTo(sizeThatFits)
        }
        
        cardButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)
            
            make.height.equalTo(36)
        }
        
        return card
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.darkGray
        
        self.initializeScrollView()
        
        let card = self.createTodaysProgressCard()
        card.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(contentView).inset(16)
            make.top.equalTo(contentView).offset(16)
        }
        
        let card2 = self.createAboutRoutineCard()
        contentView.addSubview(card2)
        
        card2.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(contentView).inset(16)
            make.top.equalTo(card.snp.bottom).offset(16)
            make.bottom.equalTo(contentView).offset(-16)
        }
    }
}
