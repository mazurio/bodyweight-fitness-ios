import Foundation
import RealmSwift

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
    
    func repositoryRoutineForTodayExists() -> Bool {
        let startOfDay = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        
        let components = NSDateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endOfDay = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions(rawValue: 0))
        let predicate = NSPredicate(format: "startTime > %@ AND startTime < %@", startOfDay, endOfDay!)
        
        if let _ = getRealm().objects(RepositoryRoutine).filter(predicate).first {
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
        let predicate = NSPredicate(format: "startTime > %@ AND startTime < %@", startOfDay, endOfDay!)
  
        if let firstRoutine = getRealm()
            .objects(RepositoryRoutine)
            .filter(predicate)
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
    
    func getRepositoryRoutineForDate(date: NSDate) -> RepositoryRoutine? {
        // If you want to get objects after a date, use greater-than (>), for dates before, use less-than (<).
        let startOfDay = NSCalendar.currentCalendar().startOfDayForDate(date)
        
        let components = NSDateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endOfDay = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions(rawValue: 0))
        let predicate = NSPredicate(format: "startTime > %@ AND startTime < %@", startOfDay, endOfDay!)
        
        return getRealm().objects(RepositoryRoutine).filter(predicate).first
    }
    
    func buildRoutine(routine: Routine) -> RepositoryRoutine {
        let repositoryRoutine = RepositoryRoutine()
        
        repositoryRoutine.routineId = routine.routineId
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
















