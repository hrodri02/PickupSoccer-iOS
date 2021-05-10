//
//  ViewController.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 2/14/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class GameLocationVC: UIViewController, CreateGamePresenterToGameLocationView {
    let FRACTION_OF_SAFE_AREA_HEIGHT: CGFloat = 0.35

    var presenter: GameLocationViewToCreateGamePresenter?
    var gameAnnotation: GameAnnotation?
    var tableViewTopAnchor: NSLayoutConstraint!
    var gameStartDateAndTime: String?
    var gameDuration: String?
    var userCoordinate: CLLocationCoordinate2D!
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let gameImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "soccer-ball-50"), highlightedImage: nil)
        imageView.tintColor = UIColor.black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(Colors.mainTextColor, for: .normal)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 5.0
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = self.gameDetailsFooterView
        tableView.isSpringLoaded = false
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var gameDetailsFooterView = GameDetailsFooterView(frame: CGRect.zero,
    cancelGameLocationButtonTapped: { [weak self] in
        guard let weakSelf = self else { return }
        if let annotation = weakSelf.gameAnnotation {
            weakSelf.mapView.removeAnnotation(annotation)
            weakSelf.zoomOut(annotation)
            weakSelf.hideGameDetails()
        }
    }) { [weak self] in
        guard let weakSelf = self else { return }
        weakSelf.hideGameDetails()
        if let navController = weakSelf.navigationController {
            weakSelf.presenter?.confirmLocationButtonTapped(navController)
        }
    }
    
    deinit {
        print("GameLocationVC \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupTopNavigationBar()
        addSubviews()
        setContraintsForUIComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.updateGameLocationView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gameDetailsFooterView.bounds = CGRect(x: 0, y: 0,
                                              width: safeAreaLayoutFrame.width,
                                              height: tableView.frame.height * 0.80 * 0.25)
    }
    
    func zoomIntoUserLocation(_ location: CLLocationCoordinate2D) {
        userCoordinate = location
        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 400, longitudinalMeters: 400)
        mapView.setRegion(viewRegion, animated: true)
    }
    
    func convertedCoordinateToAddress(_ address: String) {
        if let annotation = gameAnnotation {
            annotation.title = address
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
            zoomIn(annotation)
            tableView.reloadData()
            showGameDetails()
        }
    }
    
    func onFailedToConvertCoordinateToAddress(errorMessage: String) {
        presentErrorMessage(errorMessage)
    }
    
    func setStartDateAndDuration(startDate: String, duration: String) {
        gameStartDateAndTime = startDate
        gameDuration = duration
    }
    
    func onFailedToSaveNewGame(errorMessage: String) {
        presentErrorMessage(errorMessage)
    }
    
    private func zoomIn(_ annotation: GameAnnotation) {
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        mapView.isUserInteractionEnabled = false
    }
    
    private func zoomOut(_ annotation: GameAnnotation) {
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        mapView.setRegion(region, animated: true)
        mapView.isUserInteractionEnabled = true
    }
    
    private func showGameDetails() {
        tableViewTopAnchor.constant -= view.safeAreaLayoutGuide.layoutFrame.height * FRACTION_OF_SAFE_AREA_HEIGHT
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideGameDetails() {
        tableViewTopAnchor.constant += view.safeAreaLayoutGuide.layoutFrame.height * FRACTION_OF_SAFE_AREA_HEIGHT
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func doneButtonTapped() {
        let gameCoordinate = mapView.centerCoordinate
        let gameLocation = CLLocation(latitude: gameCoordinate.latitude, longitude: gameCoordinate.longitude)
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let distanceInMiles = gameLocation.distance(from: userLocation) * MILES_IN_METER
        if distanceInMiles > MAX_DIST_BETWEEN_GAME_AND_USER_IN_MILES {
            presentErrorMessage("Cannot create a game more than \(Int(MAX_DIST_BETWEEN_GAME_AND_USER_IN_MILES)) miles from your location")
            return
        }
        
        createGameAnnotationForCenterOfCurrentRegion()
        presenter?.setLocationOfNewGame(gameCoordinate)
        presenter?.getGameDetails()
    }
    
    @objc func cancelButtonTapped() {
        presenter?.cancelCreateGame(navigationController!)
    }
}

// MARK: - MKMapViewDelegate methods
extension GameLocationVC: MKMapViewDelegate
{
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

// MARK: - adding game annotations to map view
extension GameLocationVC {
    func createGameAnnotationForCenterOfCurrentRegion() {
        let coordinate = mapView.centerCoordinate
        gameAnnotation = GameAnnotation(coor: coordinate)
        presenter?.setLocationOfNewGame(coordinate)
        presenter?.convertCoordinateToAddress(coordinate)
    }
}

// MARK: - UITableViewDataSource
extension GameLocationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") ??
                   UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.imageView?.tintColor = UIColor.black
        
        switch indexPath.row {
        case 0:
            cell.imageView?.image = UIImage(systemName: "mappin.and.ellipse")
            cell.textLabel?.text = "\(gameAnnotation?.title ?? "")"
            break
        case 1:
            cell.imageView?.image = UIImage(systemName: "calendar")
            cell.textLabel?.text = gameStartDateAndTime
            break
        case 2:
            cell.imageView?.image = UIImage(systemName: "hourglass")
            cell.textLabel?.text = gameDuration
            break
        default:
            print("Row not between [0 - 2]")
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GameLocationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Game Details"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.bounds.height * 0.20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height * 0.80 * 0.25
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - adding subviews and setting their constriants
extension GameLocationVC {
    private func setupTopNavigationBar() {
        title = "Set Location"
        navigationController?.navigationBar.barTintColor = Colors.mainTextColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
    }
    
    private func addSubviews() {
        view.addSubview(mapView)
        view.addSubview(gameImageView)
        view.addSubview(doneButton)
        view.addSubview(tableView)
    }
    
    private func setContraintsForUIComponents() {
        setMapViewConstraints()
        setGameImageViewConstraints()
        setDoneButtonConstraints()
        setTableViewConstraints()
    }
    
    private func setMapViewConstraints() {
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setGameImageViewConstraints() {
        NSLayoutConstraint.activate([
            gameImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            gameImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            gameImageView.widthAnchor.constraint(equalToConstant: SCREEN_WIDTH * 0.10),
            gameImageView.heightAnchor.constraint(equalToConstant: SCREEN_WIDTH * 0.10)
        ])
    }
    
    private func setDoneButtonConstraints() {
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -SCREEN_HEIGHT * 0.05),
            doneButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            doneButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.125)
        ])
    }
    
    private func setTableViewConstraints() {
        tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        tableViewTopAnchor.isActive = true
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: FRACTION_OF_SAFE_AREA_HEIGHT)
        ])
    }
}
