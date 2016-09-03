import Foundation
import RealmSwift

extension NSDate {
    static func changeDaysBy(days : Int) -> NSDate {
        let startOfDay = NSCalendar.currentCalendar().startOfDayForDate(NSDate())

        let components = NSDateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59

        let currentDate = NSCalendar.currentCalendar().dateByAddingComponents(
                components,
                toDate: startOfDay,
                options: NSCalendarOptions(rawValue: 0))!

        let dateComponents = NSDateComponents()
        dateComponents.day = days
        return NSCalendar.currentCalendar().dateByAddingComponents(
                dateComponents, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
    }

    static func timeAgoSince(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let unitFlags: NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfYear, .Month, .Year]
        let components = calendar.components(unitFlags, fromDate: date, toDate: now, options: [])

        if components.year >= 2 {
            return "\(components.year) years ago"
        }

        if components.year >= 1 {
            return "Last year"
        }

        if components.month >= 2 {
            return "\(components.month) months ago"
        }

        if components.month >= 1 {
            return "Last month"
        }

        if components.weekOfYear >= 2 {
            return "\(components.weekOfYear) weeks ago"
        }

        if components.weekOfYear >= 1 {
            return "Last week"
        }

        if components.day >= 2 {
            return "\(components.day) days ago"
        }

        if components.day >= 1 {
            return "Yesterday"
        }

        if components.hour >= 2 {
            return "\(components.hour) hours ago"
        }

        if components.hour >= 1 {
            return "An hour ago"
        }

        if components.minute >= 2 {
            return "\(components.minute) minutes ago"
        }

        if components.minute >= 1 {
            return "A minute ago"
        }

        if components.second >= 3 {
            return "\(components.second) seconds ago"
        }

        return "Just now"

    }
}

class RepositoryStream {
    class var sharedInstance: RepositoryStream {
        struct Static {
            static var instance: RepositoryStream?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = RepositoryStream()
        }
        
        return Static.instance!
    }

    init() {
        
    }
    
    func getRealm() -> Realm {
        let realm = try! Realm()
        
        return realm
    }

    func getNumberOfWorkouts() -> Int {
        return getRealm().objects(RepositoryRoutine).count
    }

    func getNumberOfWorkouts(days: Int) -> Int {
        let predicate = NSPredicate(format: "startTime > %@ AND startTime < %@", NSDate.changeDaysBy(-7), NSDate())

        return getRealm()
            .objects(RepositoryRoutine)
            .filter(predicate)
            .count
    }

    func getLastWorkout() -> RepositoryRoutine? {
        let date = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        let predicate = NSPredicate(format: "startTime < %@", date)

        return getRealm()
            .objects(RepositoryRoutine)
            .filter(predicate)
            .last
    }

    func repositoryRoutineForTodayExists() -> Bool {
        let startOfDay = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        
        let components = NSDateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endOfDay = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions(rawValue: 0))
      
        if let _ = getRealm()
            .objects(RepositoryRoutine)
            .filter(NSPredicate(format: "startTime > %@ AND startTime < %@", startOfDay, endOfDay!))
            .filter(NSPredicate(format: "routineId == %@", RoutineStream.sharedInstance.routine.routineId))
            .first {
            return true
        } else {
            return false
        }
    }
    
    func getRepositoryRoutineForToday() -> RepositoryRoutine {
        // If you want to get objects after a date, use greater-than (>), for dates before, use less-than (<).
        let startOfDay = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        
        let components = NSDateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endOfDay = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions(rawValue: 0))

        if let firstRoutine = getRealm()
            .objects(RepositoryRoutine)
            .filter(NSPredicate(format: "startTime > %@ AND startTime < %@", startOfDay, endOfDay!))
            .filter(NSPredicate(format: "routineId == %@", RoutineStream.sharedInstance.routine.routineId))
            .first {
                return firstRoutine
        } else {
            return buildRoutine(RoutineStream.sharedInstance.routine)
        }
    }
    
    func getRoutinesForDate(date: NSDate) -> Results<RepositoryRoutine> {
        let startOfDay = NSCalendar.currentCalendar().startOfDayForDate(date)
        
        let components = NSDateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endOfDay = NSCalendar.currentCalendar().dateByAddingComponents(
            components,
            toDate: startOfDay,
            options: NSCalendarOptions(rawValue: 0))
        
        let predicate = NSPredicate(format: "startTime > %@ AND startTime < %@", startOfDay, endOfDay!)
        
        return getRealm().objects(RepositoryRoutine).filter(predicate)
    }
    
    func buildRoutine(routine: Routine) -> RepositoryRoutine {
        let repositoryRoutine = RepositoryRoutine()
        
        repositoryRoutine.routineId = routine.routineId
        repositoryRoutine.title = routine.title
        repositoryRoutine.subtitle = routine.subtitle
        repositoryRoutine.startTime = NSDate()
        repositoryRoutine.lastUpdatedTime = NSDate()
        
        var repositoryCategory: RepositoryCategory?
        var repositorySection: RepositorySection?
        
        for exercise in routine.exercises {
            if let exercise = exercise as? Exercise {
                
                let repositoryExercise = RepositoryExercise()
                repositoryExercise.exerciseId = exercise.exerciseId
                repositoryExercise.title = exercise.title
                repositoryExercise.desc = exercise.desc
                repositoryExercise.defaultSet = exercise.defaultSet
                
                let repositorySet = RepositorySet()
                repositorySet.exercise = repositoryExercise
                
                if(repositoryExercise.defaultSet == "weighted") {
                    repositorySet.isTimed = false
                } else {
                    repositorySet.isTimed = true
                }
                
                repositoryExercise.sets.append(repositorySet)
                
                if((repositoryCategory == nil) || !(repositoryCategory?.categoryId == exercise.category?.categoryId)) {
                    let category = exercise.category!
                    
                    repositoryCategory = RepositoryCategory()
                    repositoryCategory?.categoryId = category.categoryId
                    repositoryCategory?.title = category.title
                    repositoryCategory?.routine = repositoryRoutine
                    
                    repositoryRoutine.categories.append(repositoryCategory!)
                }
                
                if((repositorySection == nil) || !(repositorySection?.sectionId == exercise.section?.sectionId)) {
                    let section = exercise.section!
                    
                    repositorySection = RepositorySection()
                    repositorySection?.sectionId = section.sectionId
                    repositorySection?.title = section.title
                    
                    if (section.mode == SectionMode.All) {
                        repositorySection?.mode = "all"
                    } else if (section.mode == SectionMode.Pick) {
                        repositorySection?.mode = "pick"
                    } else {
                        repositorySection?.mode = "levels"
                    }
                    
                    repositorySection?.routine = repositoryRoutine
                    repositorySection?.category = repositoryCategory!
                    
                    repositoryRoutine.sections.append(repositorySection!)
                    repositoryCategory?.sections.append(repositorySection!)
                }
                
                repositoryExercise.routine = repositoryRoutine
                repositoryExercise.category = repositoryCategory!
                repositoryExercise.section = repositorySection!
                
                if(exercise.section?.mode == SectionMode.All) {
                    repositoryExercise.visible = true
                } else {
                    if let currentExercise = exercise.section?.currentExercise {
                        if exercise === currentExercise {
                            repositoryExercise.visible = true
                        } else {
                            repositoryExercise.visible = false
                        }
                    } else {
                        repositoryExercise.visible = false
                    }
                }
                
                repositoryRoutine.exercises.append(repositoryExercise)
                repositoryCategory?.exercises.append(repositoryExercise)
                repositorySection?.exercises.append(repositoryExercise)
            }
        }
        
        return repositoryRoutine
    }
}
















