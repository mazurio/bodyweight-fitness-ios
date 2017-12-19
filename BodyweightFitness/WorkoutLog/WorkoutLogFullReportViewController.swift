import SnapKit
import Charts
import RealmSwift

class WorkoutLogFullReportViewController: AbstractViewController {
    var repositoryExercise: RepositoryExercise?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeContent()
    }
    
    override func initializeContent() {
        super.initializeContent()

        self.navigationItem.title = self.repositoryExercise?.title

        if let repositoryExercise = self.repositoryExercise {
            self.addView(self.createFullReportCard(repositoryExercise: repositoryExercise))
        }
    }
    
    func createLabelsView(titleText: String, subtitleText: String, valueText: String) -> UIView {
        let view = UIView()
        
        let title = TitleLabel()
        title.text = titleText
        view.addSubview(title)

        let subtitle = ValueLabel()
        subtitle.text = subtitleText
        view.addSubview(subtitle)
        
        let value = ValueLabel()
        value.text = valueText
        view.addSubview(value)

        title.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }

        subtitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        
        value.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(subtitle.snp.bottom).offset(8)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        return view
    }

    func createFullReportCard(repositoryExercise: RepositoryExercise) -> CardView {
        let card = CardView()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)

        let realm = try! Realm()
        let exercises = realm.objects(RepositoryExercise.self).filter("exerciseId == '\(repositoryExercise.exerciseId)'")

        let repositorySets = Array(exercises).map { $0.sets }.flatMap { $0 }

        for repositorySet in repositorySets {
            if let desc = repositorySet.exercise?.routine?.startTime.description {
                let companion = RepositorySetCompanion(repositorySet)

                if let index = repositorySet.exercise?.sets.index(of: repositorySet) {
                    stackView.addArrangedSubview(
                            createLabelsView(
                                    titleText: "Set \(index + 1)",
                                    subtitleText: "\(companion.setSummaryLabel())",
                                    valueText: "\(desc)"
                            )
                    )
                }
            }
        }

        stackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)
        }
        
        return card
    }
}
