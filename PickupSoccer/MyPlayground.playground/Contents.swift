import UIKit

let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
print(rect.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)))

protocol UserProtocol: Hashable {
    var uid: Int64 {get set}
    var firstName: String? {get set}
    var lastName: String? {get set}
}

struct User: UserProtocol {
    var uid: Int64
    var firstName: String?
    var lastName: String?
    var dummy: Dummy?
}

struct Dummy {
    let someProp: Int
}


func compare(user1: User, user2: User) {
    if user1 == user2 {
        print("users are equal")
    }
    else {
        print("users are not equal")
    }
}

let user1 = User(uid: 0, firstName: "Bert", lastName: "Rod")
let user2 = User(uid: 1, firstName: "Berto", lastName: "Rod")
compare(user1: user1, user2: user2)

class MyObj
{
    var prop1: String
    
    init(prop1: String) {
        self.prop1 = prop1
    }
}

protocol MyObjProtocol
{
    var prop1: String {get set}
}

extension MyObj: MyObjProtocol { }

func someFunc(_ obj: MyObjProtocol) {
    print(obj.prop1)
}

let obj = MyObj(prop1: "prop1")
someFunc(obj)

// my location
//37.70676399399633, -122.41537376707768

// ocean view park
//37.71590334951762, -122.45735797571214

import CoreLocation

let mcdonals = CLLocation(latitude: 37.70676399399633, longitude: -122.41537376707768)
var dict: [CLLocationCoordinate2D : Bool] = [:]
dict[mcdonals] = true
print(dict)


let arr = [5,1,7,2,3]

for i in arr where i > 2 {
    print(i)
}



let MILES_IN_METER = 0.000621371

let oceanViewPark = CLLocation(latitude: 37.71590334951762, longitude: -122.45735797571214)
let distance = mcdonals.distance(from: oceanViewPark) * MILES_IN_METER

class MyPoint {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        print("init new point")
        self.x = x
        self.y = y
    }
}

class MyClass {
    static func createPoint(x: Int, y: Int) -> MyPoint {
        return MyPoint(x: x, y: y)
    }
}

let point1 = MyClass.createPoint(x: 0, y: 0)
let point2 = MyClass.createPoint(x: 0, y: 1)

//import Foundation
//
//class BasicCoffeMachine
//{
//    let configMap: [CoffeeSelection : Configuration]
//    let groundCoffee: [CoffeeSelection : GroundCoffee]
//    let brewingUnit: BrewingUnit
//    
//    
//}


/*
0.0    0.5     1.0     1.5     2.0

 0.25 < x <= 0.75  -> 0 h 30 m
 0.75 < x <= 1.25  -> 1 h 0 m
 1.25 < x <= 1.75  -> 1 h 30 m
 1.75 < x <= 2  -> 2 h 0 m

f(x) = # of 30 mins = ceil((x - 0.25) / 0.5)


let formatter = DateFormatter()
formatter.dateFormat = "MMM d, h:mm a"

let calendar = Calendar(identifier: .gregorian)
let today = Date()
guard let startDate = calendar.date(bySettingHour: 2, minute: 24, second: 0, of: today) else {
    fatalError("Failed to unwrap start date")
}
print(formatter.string(from: startDate))

let gameDay = calendar.component(.day, from: startDate) + 1
guard let startDatePlusOneDay = calendar.date(bySetting: .day, value: gameDay, of: startDate) else {
    fatalError("Failed to unwrap start date")
}
print(formatter.string(from: startDatePlusOneDay))

let numOfThirtyMinutes = Int(ceil((1.26 - 0.25) / 0.5))
let hours = numOfThirtyMinutes / 2
let mins = (numOfThirtyMinutes - hours * 2) * 30


let dateFormatter: DateFormatter = {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "d"
  return dateFormatter
}()



// Get days in a month as ints

let gameDay = calendar.component(.day, from: today) + 1
var gameDate = calendar.date(bySetting: .day, value: gameDay, of: today)
gameDate = calendar.date(bySettingHour: 0, minute: 24, second: 0, of: gameDate!)



let today2 = Date()

//if let daysRange = calendar.range(of: .day, in: .month, for: today) {
//    for day in daysRange {
//        print(day)
//    }
//}

let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))
let yesterday  = calendar.date(byAdding: .day, value: -1, to: today)
print(dateFormatter.string(from: today))
print(dateFormatter.string(from: yesterday!))

//let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth!)
//print(firstDayWeekday)
*/
