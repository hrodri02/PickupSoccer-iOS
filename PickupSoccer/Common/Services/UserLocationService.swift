//
//  UserLocationService.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/17/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation

protocol UserLocationServiceProtocol {
    func generateUsersLocation(completionHandler: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
}

class UserLocationService: NSObject, UserLocationServiceProtocol {
    private var userLocation: CLLocationCoordinate2D?
    private var locationManager: CLLocationManager?
    private var completionHandler: ((Result<CLLocationCoordinate2D, Error>) -> Void)?
    
    private enum UserLocationError: LocalizedError {
        case deniedSharingLocation
    }
    
    func generateUsersLocation(completionHandler: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        if let location = userLocation {
            completionHandler(Result.success(location))
        }
        else {
            self.completionHandler = completionHandler
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
        }
    }
}

// MARK: - CLLocationManagerDelegate methods
extension UserLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager?.desiredAccuracy = .greatestFiniteMagnitude
            locationManager?.startUpdatingLocation()
        case .authorizedAlways:
            locationManager?.desiredAccuracy = .greatestFiniteMagnitude
            locationManager?.startUpdatingLocation()
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
            print(CLAuthorizationStatus.notDetermined)
        case .denied:
            if let completionHandler = self.completionHandler {
                completionHandler(Result.failure(UserLocationError.deniedSharingLocation))
            }
            print(CLAuthorizationStatus.denied)
        default:
            print("denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        if userLocation == nil, let completionHandler = self.completionHandler {
            userLocation = location
            completionHandler(Result.success(location))
        }
    }
}
