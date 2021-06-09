//  CoreDataStore.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/10/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation
import CoreData
import UIKit

class CoreDataStore: DataStore
{
    let managedObjectContext: NSManagedObjectContext!
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Failed to get reference to AppDelegate")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    deinit {
        print("CoreDataStore deinit")
    }
    
    // MARK: - methods for saving, updating, deleting, and fetching a user
    func fetchUser(with uid: String, completion: (Result<User, Error>) -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "uid == %@", uid)
        
        do {
            let users = try managedObjectContext.fetch(fetchRequest) as! [UserMO]
            if let userMO = users.first {
                let user = User(userMO: userMO)
                completion(.success(user))
            }
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func fetchUsers(for game: Game,
                    completion: (Result<[String: PlayerInfo], Error>) -> Void)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlayerInfo")
        fetchRequest.predicate = NSPredicate(format: "game.id == %@", game.id ?? "")
        
        do {
            let playerInfoArr = try managedObjectContext.fetch(fetchRequest) as! [PlayerInfo]
            var uidToPlayerInfo = [String : PlayerInfo]()
            for playerInfo in playerInfoArr {
                if let uid = playerInfo.player?.uid {
                    uidToPlayerInfo[uid] = playerInfo
                }
            }
            completion(.success(uidToPlayerInfo))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func saveUser(firstName: String, lastName: String, completion: (Result<User, Error>) -> Void) {
        guard let userEntity = NSEntityDescription.entity(forEntityName: "User", in: managedObjectContext) else {
            fatalError("Failed to create entity description User.")
        }
        
        let userMO = NSManagedObject(entity: userEntity, insertInto: managedObjectContext) as! UserMO
        userMO.uid = UUID().uuidString
        userMO.firstName = firstName
        userMO.lastName = lastName
        
        do {
            try managedObjectContext.save()
            let user = User(userMO: userMO)
            completion(.success(user))
            
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func deleteAllUsers() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequest.includesPropertyValues = false
        
        do {
            let users: [NSManagedObject] = try managedObjectContext.fetch(fetchRequest)
            
            for user in users {
                managedObjectContext.delete(user)
            }
            
            try managedObjectContext.save()
            print("Users deleted successfully")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - methods for saving, updating, deleting, and fetching a game
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[Game], Error>) -> Void)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Game")
        let predicateFormat = "location.latitude > %f AND location.latitude < %f AND location.longitude > %f AND location.longitude < %f"
        fetchRequest.predicate = NSPredicate(format: predicateFormat,
                                             center.latitude - latitudeDelta / 2,
                                             center.latitude + latitudeDelta / 2,
                                             center.longitude - longitudeDelta / 2,
                                             center.longitude + longitudeDelta / 2)
        do {
            let gamesInRegion: [GameMO] = try managedObjectContext.fetch(fetchRequest) as! [GameMO]
            for game in gamesInRegion {
                if let players = game.players, let address = game.address {
                    print("game at \(address) has \(players.count) players")
                }
                else {
                    print("players set is null")
                }
            }
            completion(Result.success(gamesInRegion))
        }
        catch {
            completion(Result.failure(error))
        }
    }
    
    func saveGame(_ address: String,
                  _ location: CLLocationCoordinate2D,
                  _ dateInterval: DateInterval,
                  completion: @escaping (Error?) -> Void)
    {
        // 3. create a game entity
        guard let gameEntity = NSEntityDescription.entity(forEntityName: "Game", in: managedObjectContext),
            let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectContext),
            let dateIntervalEntity = NSEntityDescription.entity(forEntityName: "DateInterval", in: managedObjectContext) else
        {
            fatalError("Failed to create entity descriptions for Game, Location, and DateInterval entities.")
        }
        
        // 4. create managed objects
        let gameMO = NSManagedObject(entity: gameEntity, insertInto: managedObjectContext) as! GameMO
        let locationMO = NSManagedObject(entity: locationEntity, insertInto: managedObjectContext) as! LocationMO
        let dateIntervalMO = NSManagedObject(entity: dateIntervalEntity, insertInto: managedObjectContext) as! DateIntervalMO
        
        // 5. set properties of game entity
        locationMO.latitude = location.latitude
        locationMO.longitude = location.longitude
        dateIntervalMO.start = dateInterval.start
        dateIntervalMO.end = dateInterval.end
        gameMO.id = UUID().uuidString
        gameMO.address = address
        gameMO.location = locationMO
        gameMO.dateInterval = dateIntervalMO
        
        // 6. save managed object context
        do {
            try managedObjectContext.save()
        }
        catch {
            completion(error)
        }
    }
    
    // MARK: - methods for saving, updating, deleting, and fetching player information
    func addUserToGame(uid: String,
                       gameId: String,
                       position: Position,
                       isWithHomeTeam: Bool,
                       completion: (Result<PlayerInfo, Error>) -> Void)
    {
        let userFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        userFetchRequest.predicate = NSPredicate(format: "uid == %@", uid)
        let gameFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Game")
        gameFetchRequest.predicate = NSPredicate(format: "id == %@", gameId)
        
        do {
            let users = try managedObjectContext.fetch(userFetchRequest) as! [UserMO]
            let games = try managedObjectContext.fetch(gameFetchRequest) as! [GameMO]
            if let user = users.first, let game = games.first {
                guard let playerInfoEntity = NSEntityDescription.entity(forEntityName: "PlayerInfo", in: managedObjectContext) else {
                    fatalError("Failed to get playerInfo entity.")
                }
                
                let playerInfo = NSManagedObject(entity: playerInfoEntity, insertInto: managedObjectContext) as! PlayerInfo
                playerInfo.player = user
                playerInfo.game = game
                playerInfo.positionEnum = position
                playerInfo.isWithHomeTeam = isWithHomeTeam
                try managedObjectContext.save()
                completion(.success(playerInfo))
            }
            else {
                print("Failed to get user or game")
            }
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func updateUserInfoForGame(uid: String,
                               gameId: String,
                               position: Position,
                               isWithHomeTeam: Bool,
                               completion: (Result<PlayerInfo, Error>) -> Void)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlayerInfo")
        fetchRequest.predicate = NSPredicate(format: "player.uid == %@ AND game.id == %@", uid, gameId)
        
        do {
            let playerInfoArr = try managedObjectContext.fetch(fetchRequest) as! [PlayerInfo]
            if let oldPlayerInfo = playerInfoArr.first {
                oldPlayerInfo.isWithHomeTeam = isWithHomeTeam
                oldPlayerInfo.positionEnum = position
                try managedObjectContext.save()
                completion(.success(oldPlayerInfo))
            }
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func removeUserFromGame(uid: String, gameId: String, completion: (Result<PlayerInfo, Error>) -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlayerInfo")
        fetchRequest.predicate = NSPredicate(format: "player.uid == %@ AND game.id == %@", uid, gameId)
        
        do {
            let playerInfoArr = try managedObjectContext.fetch(fetchRequest) as! [PlayerInfo]
            if let playerInfo = playerInfoArr.first {
                managedObjectContext.delete(playerInfo)
                try managedObjectContext.save()
                completion(.success(playerInfo))
            }
        }
        catch {
            completion(.failure(error))
        }
    }
}
