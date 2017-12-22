import Foundation
import SwiftyJSON

enum RoutineType: Int {
    case category
    case section
    case exercise
}

enum SectionMode: Int {
    case all
    case pick
    case levels
}

protocol LinkedRoutine: class {
    func getType() -> RoutineType
}

class Category: LinkedRoutine {
    let categoryId: String
    let type: RoutineType = RoutineType.category
    let title: String
    var sections: NSMutableArray = []
    
    init(categoryId: String, title: String) {
        self.categoryId = categoryId
        self.title = title
    }
    
    func getType() -> RoutineType {
        return type
    }
    
    func insertSection(_ section: Section) {
        sections.add(section)
    }
}

class Section: LinkedRoutine {
    let sectionId: String
    let type: RoutineType = RoutineType.section
    let mode: SectionMode
    let title: String
    let desc: String
    var category: Category?
    var currentExercise: Exercise?
    var exercises: NSMutableArray = []
    
    init(sectionId: String, title: String, desc: String, mode: SectionMode) {
        self.sectionId = sectionId
        self.title = title
        self.desc = desc
        self.mode = mode
    }
    
    func getType() -> RoutineType {
        return type
    }
    
    func insertExercise(_ exercise: Exercise) {
        exercises.add(exercise)
    }
}

class Exercise: LinkedRoutine {
    let type: RoutineType = RoutineType.exercise
    let exerciseId: String
    let level: String
    let title: String
    let desc: String
    let youTubeId: String
    let videoId: String
    let defaultSet: String
    var category: Category?
    var section: Section?
    var previous: Exercise?
    var next: Exercise?
    
    init(exerciseId: String, level: String, title: String, desc: String, youTubeId: String, videoId: String, defaultSet: String) {
        self.exerciseId = exerciseId
        self.level = level
        self.title = title
        self.desc = desc
        self.youTubeId = youTubeId
        self.videoId = videoId
        self.defaultSet = defaultSet
    }
    
    func getType() -> RoutineType {
        return type
    }
    
    func isTimed() -> Bool {
        return self.defaultSet == "timed"
    }
}

class Routine {
    var routineId: String = "routine0"
    var title: String = ""
    var subtitle: String = ""
    var shortDescription: String = ""
    var url: String = ""
    
    var categories: NSMutableArray = []
    var sections: NSMutableArray = []
    var exercises: NSMutableArray = []
    var categoriesAndSections: NSMutableArray = []
    var linkedExercises: NSMutableArray = []
    var linkedRoutine: NSMutableArray = []
    
    init() {}
    
    init(fileName: String) {
        let json = try! JSON(data: loadRoutineFromFile(fileName))
        
        self.routineId = json["routineId"].stringValue
        self.title = json["title"].stringValue
        self.subtitle = json["subtitle"].stringValue
        self.shortDescription = json["shortDescription"].stringValue
        self.url = json["url"].stringValue
        
        self.build(json)
    }
    
    init(fileName: String, dictionary: Dictionary<String, String>) {
        let json = try! JSON(data: loadRoutineFromFile(fileName))
        
        self.routineId = json["routineId"].stringValue
        self.title = json["title"].stringValue
        self.subtitle = json["subtitle"].stringValue
        self.shortDescription = json["shortDescription"].stringValue
        self.url = json["url"].stringValue
        
        self.build(json, dictionary: dictionary)
    }
    
    func build(_ json: JSON, dictionary: Dictionary<String, String> = Dictionary<String, String>()) {
        var currentCategory: Category?
        var currentSection: Section?
        var currentExercise: Exercise?
        
        for(_, item):(String, JSON) in json["routine"] {
            switch item["type"] {
            case "category":
                let category = Category(
                    categoryId: item["categoryId"].stringValue,
                    title: item["title"].stringValue)
                
                categories.add(category)
                categoriesAndSections.add(category)
                linkedRoutine.add(category)
                
                currentCategory = category
            case "section":
                let section = Section(
                    sectionId: item["sectionId"].stringValue,
                    title: item["title"].stringValue,
                    desc: item["description"].stringValue,
                    mode: getMode(item["mode"].stringValue))
                
                section.category = currentCategory
                
                sections.add(section)
                categoriesAndSections.add(section)
                linkedRoutine.add(section)
                
                currentSection = section
            case "exercise":
                let exercise = Exercise(
                    exerciseId: item["exerciseId"].stringValue,
                    level: item["level"].stringValue,
                    title: item["title"].stringValue,
                    desc: item["description"].stringValue,
                    youTubeId: item["youTubeId"].stringValue,
                    videoId: item["videoId"].stringValue,
                    defaultSet: item["defaultSet"].stringValue)
                
                exercise.category = currentCategory
                exercise.section = currentSection
                
                currentSection?.exercises.add(exercise)
                exercises.add(exercise)
                
                if(currentSection?.mode == SectionMode.levels || currentSection?.mode == SectionMode.pick) {
                    if let currentExerciseSaved = dictionary[currentSection!.sectionId] as String? {
                        if(exercise.exerciseId == currentExerciseSaved) {
                            linkedExercises.add(exercise)
                            exercise.previous = currentExercise
                            currentExercise?.next = exercise
                            currentExercise = exercise
                            
                            currentSection?.currentExercise = exercise
                        }
                    } else {
                        if(currentSection?.exercises.count == 1) {
                            linkedExercises.add(exercise)
                            exercise.previous = currentExercise
                            currentExercise?.next = exercise
                            currentExercise = exercise
                            
                            currentSection?.currentExercise = exercise
                        }
                    }
                } else {
                    linkedExercises.add(exercise)
                    exercise.previous = currentExercise
                    currentExercise?.next = exercise
                    currentExercise = exercise
                }
                
                linkedRoutine.add(exercise)
            default:
                print("Unknown item in JSON File.")
            }
        }
    }
    
    func getMode(_ mode: String) -> SectionMode {
        if(mode == "pick") {
            return SectionMode.pick
        } else if(mode == "levels") {
            return SectionMode.levels
        } else {
            return SectionMode.all
        }
    }
    
    func getFirstExercise() -> Exercise {
        return linkedExercises[0] as! Exercise
    }

    func setProgression(_ exercise: Exercise) {
        let currentSectionExercise = exercise.section?.currentExercise
        
        currentSectionExercise?.previous?.next = exercise
        currentSectionExercise?.next?.previous = exercise
        
        exercise.previous = currentSectionExercise?.previous
        exercise.next = currentSectionExercise?.next
        
        exercise.section?.currentExercise = exercise
    }
    
    func loadRoutineFromFile(_ fileName: String) -> Data {
        let fileRoot = Bundle.main.path(forResource: fileName, ofType: "json")!

        do {
            return try Data(contentsOf: URL(fileURLWithPath: fileRoot), options: .mappedIfSafe)
        } catch _ {
            return Data()
        }
    }
}
