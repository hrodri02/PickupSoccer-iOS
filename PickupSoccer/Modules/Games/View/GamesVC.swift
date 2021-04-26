//
//  GamesVC.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit
import MapKit

class GamesVC: UIViewController
{
    var coordinateToAnnotation: [String: GameAnnotation] = [:]
    // mcdonals by crocker: 37.70720493819644, -122.41545805721627
    let LATITUDINAL_METERS: Double = 3000
    let LONGITUDINAL_METERS: Double = 3000
    let KM_IN_DEGREE: Double = 111
    let userCoordinate = CLLocationCoordinate2D(latitude: 37.70720493819644, longitude: -122.41545805721627)
    var presenter: GamesViewToGamesPresenter?
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        let region = MKCoordinateRegion(center: self.userCoordinate,
                                        latitudinalMeters: LATITUDINAL_METERS,
                                        longitudinalMeters: LONGITUDINAL_METERS)
        mapView.setRegion(region, animated: false)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    lazy var redoSearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Redo Search In This Area", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        button.tintColor = UIColor.black
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 5.0
        button.addTarget(self, action: #selector(redoSearchButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var addGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = UIColor.systemTeal
        button.addTarget(self, action: #selector(addGameButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTopNavigationBar()
        addSubviews()
        setMapViewConstraints()
        setRedoSearchButtonConstriants()
        setAddGameButtonConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("GamesVC viewWillAppear")
        let centerCoordinate = mapView.centerCoordinate
        presenter?.updateGamesView(center: centerCoordinate,
                                   latitudeDelta: (LATITUDINAL_METERS * 2 / 1000) / KM_IN_DEGREE,
                                   longitudeDelta: (LONGITUDINAL_METERS * 2 / 1000) / KM_IN_DEGREE)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        print("Games View \(#function)")
    }
    
    @objc func closeButtonTapped() {
        if let navigationController = navigationController {
            presenter?.closeButtonTapped(navigationController)
        }
    }
    
    @objc func redoSearchButtonTapped() {
        presenter?.updateGamesView(center: mapView.region.center,
                                   latitudeDelta: mapView.region.span.latitudeDelta,
                                   longitudeDelta: mapView.region.span.longitudeDelta)
    }
    
    @objc func addGameButtonTapped() {
        if let navController = navigationController {
            presenter?.addGameButtonTapped(navController)
        }
    }
    
    private func setupTopNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))
    }
    
    private func addSubviews() {
        mapView.addSubview(redoSearchButton)
        mapView.addSubview(addGameButton)
        view.addSubview(mapView)
    }
    
    private func setMapViewConstraints() {
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setRedoSearchButtonConstriants() {
        let padding: CGFloat = 10
        let width = redoSearchButton.titleLabel?.intrinsicContentSize.width ?? 0.0
        let height = redoSearchButton.titleLabel?.intrinsicContentSize.height ?? 0.0
        NSLayoutConstraint.activate([
            redoSearchButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: SCREEN_HEIGHT * 0.05),
            redoSearchButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            redoSearchButton.widthAnchor.constraint(equalToConstant: width + padding),
            redoSearchButton.heightAnchor.constraint(equalToConstant: height + padding),
        ])
    }
    
    private func setAddGameButtonConstraints() {
        NSLayoutConstraint.activate([
            addGameButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -SCREEN_WIDTH * 0.05),
            addGameButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -SCREEN_WIDTH * 0.05),
            addGameButton.widthAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.125),
            addGameButton.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.125)
        ])
    }
}

extension GamesVC: GamesPresenterToGamesView {
    func displayGames(_ coordinateToGame: [String : Game]) {
        // remove old annotations
        for (coordinate, annotation) in coordinateToAnnotation {
            if coordinateToGame[coordinate] == nil {
                mapView.removeAnnotation(annotation)
                coordinateToAnnotation[coordinate] = nil
            }
        }
        
        // add new annotations
        for (coordinate, game) in coordinateToGame {
            if coordinateToAnnotation[coordinate] == nil {
                let annotation = GameAnnotation(coor: game.location)
                mapView.addAnnotation(annotation)
                coordinateToAnnotation[coordinate] = annotation
            }
        }
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        
    }
}

extension GamesVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        else {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "gameAnnotation")
            annotationView.image = UIImage(named: "soccer-ball-50")
            annotationView.canShowCallout = true
            annotationView.bounds = CGRect(x: 0, y: 0, width: SCREEN_WIDTH * 0.10, height: SCREEN_WIDTH * 0.10)
            return annotationView
        }
    }
}
