import SnapKit

class AbstractViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let contentStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeScrollView(attachToView: mainView())
    }

    func mainView() -> UIView {
        return self.view
    }
    
    func initializeScrollView(attachToView: UIView) {
        attachToView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.97, alpha:1.00)
        attachToView.addSubview(self.scrollView)

        self.scrollView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(attachToView)
        }
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(self.scrollView)
            make.left.right.equalTo(attachToView)
        }
        
        self.createBackgroundView()
        
        self.contentStackView.axis = .vertical
        self.contentStackView.distribution = .fill
        self.contentStackView.alignment = .fill
        self.contentStackView.spacing = 16
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.contentStackView)
        
        self.contentStackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView).offset(8)
            make.left.equalTo(contentView).offset(8)
            make.right.equalTo(contentView).offset(-8)
            make.bottom.equalTo(contentView).offset(-8)
        }
    }

    func initializeContent() {
        self.removeAllViews()
    }
    
    func createBackgroundView(height: Int = 50) {
        let view = UIView()
        view.backgroundColor = UIColor.primary()
        
        self.contentView.addSubview(view)
        
        view.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(height)
        }
    }
    
    func addView(_ view: UIView) {
        self.contentStackView.addArrangedSubview(view)
    }
    
    func removeAllViews() {
        for view in self.contentStackView.subviews {
            view.removeFromSuperview()
        }
    }
}
