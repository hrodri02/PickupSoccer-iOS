//
//  GamesVC.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class GamesVC: UIViewController
{
    let NUM_ANNOTATIONS_DATA_SETS = 1000
    let MAX_LATITUDINAL_METERS: Double = 10_000
    let INIT_LATITUDINAL_METERS: Double = 5000
    let INIT_LONGITUDINAL_METERS: Double = 5000
    let KM_IN_DEGREE: Double = 111
    let userLocationService: UserLocationServiceProtocol
    var userCoordinate: CLLocationCoordinate2D?
    var viewModels: [GameViewModel] = []
    var coordinateToAnnotation: [CLLocationCoordinate2D: GameAnnotation] = [:]
    var selectedItem: Int = 0
    var presenter: GamesViewToGamesPresenter?
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.showsUserLocation = true
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
    
    lazy var collectionView: CollectionView = {
        let collectionView = CollectionView(layout: CarouselLayout())
        collectionView.register(GameCVCell.self, forCellWithReuseIdentifier: GameCVCell.cellId)
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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
    
    init(userLocationService: UserLocationServiceProtocol) {
        self.userLocationService = userLocationService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTopNavigationBar()
        addSubviews()
        setMapViewConstraints()
        setRedoSearchButtonConstriants()
        setCollectionViewContraints()
        setAddGameButtonConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGamesNearUsersLocation()
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
        let latitudinalMeters = mapView.region.span.latitudeDelta * (KM_IN_DEGREE * 1000)
        var latitudeDelta = mapView.region.span.latitudeDelta
        var longitudeDelta = mapView.region.span.longitudeDelta
        // if region is too big, zoom into a smaller region
        if latitudinalMeters > MAX_LATITUDINAL_METERS {
            let heightWidthRatioOfSafeArea: Double = Double(self.safeAreaLayoutFrame.height /
                                                            self.safeAreaLayoutFrame.width)
            let region = MKCoordinateRegion(center: mapView.region.center,
                                            latitudinalMeters: MAX_LATITUDINAL_METERS,
                                            longitudinalMeters: MAX_LATITUDINAL_METERS * heightWidthRatioOfSafeArea)
            latitudeDelta = region.span.latitudeDelta
            longitudeDelta = region.span.longitudeDelta
            mapView.setRegion(region, animated: true)
        }
        
        fetchGames(coordinate: mapView.region.center,
                   latitudeDelta: latitudeDelta,
                   longitudeDelta: longitudeDelta)
    }
    
    @objc func addGameButtonTapped() {
        if let navController = navigationController {
            presenter?.addGameButtonTapped(navController)
        }
    }
    
    func fetchGamesNearUsersLocation() {
        if let userCoordinate = self.userCoordinate {
            let degrees = (INIT_LATITUDINAL_METERS * 2 / 1000) / KM_IN_DEGREE
            fetchGames(coordinate: userCoordinate,
                       latitudeDelta: degrees,
                       longitudeDelta: degrees)
        }
        else {
            fetchUsersLocation()
        }
    }
    
    func fetchUsersLocation() {
        userLocationService.generateUsersLocation { [unowned self] (result) in
            switch result {
            case .success(let userCoordinate):
                self.userCoordinate = userCoordinate
                let heightWidthRatioOfSafeArea: Double = Double(self.safeAreaLayoutFrame.height /
                                                          self.safeAreaLayoutFrame.width)
                let region = MKCoordinateRegion(center: userCoordinate,
                                                latitudinalMeters: self.INIT_LONGITUDINAL_METERS * heightWidthRatioOfSafeArea,
                                                longitudinalMeters: self.INIT_LONGITUDINAL_METERS)
                self.mapView.setRegion(region, animated: false)
                let latitudeDelta = region.span.latitudeDelta
                let longitudeDelta = region.span.longitudeDelta
                
                self.fetchGames(coordinate: userCoordinate,
                                latitudeDelta: latitudeDelta,
                                longitudeDelta: longitudeDelta)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchGames(coordinate: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees)
    {
        presenter?.updateGamesView(center: coordinate,
                                   latitudeDelta: latitudeDelta,
                                   longitudeDelta: longitudeDelta)
    }
    
    /*
        Note: This method is only called if collectionView delegate is set and GamesVC adopts the delegate
        midX = collectionView.bounds.midX
        midX = item * (minCellWidth + minLineSpacing) + minCellWidth / 2
        item = (midX - minCellWidth / 2) / (minCellWidth + minLineSpacing)
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let maxZoom: CGFloat = CarouselLayoutConstants.maxCellHeight / CarouselLayoutConstants.minCellHeight
        let deltaWidth = CarouselLayoutConstants.minCellWidth * (maxZoom - 1.0)
        let minLineSpacing = CarouselLayoutConstants.horizontalSpaceBetweenCells + (deltaWidth / 2.0)
        let item = (collectionView.bounds.midX - CarouselLayoutConstants.minCellWidth / 2.0) / (CarouselLayoutConstants.minCellWidth + minLineSpacing)
        selectedItem = Int(round(item))
    }
}

extension GamesVC: GamesPresenterToGamesView {
    func displayGames(_ coordinateToGame: [CLLocationCoordinate2D : Game]) {
        removeAnnotationsNotInRegion(coordinateToGame)
        addNewAnnotations(coordinateToGame)
        createViewModels(from: coordinateToGame)
        reloadGamesView()
    }
    
    private func removeAnnotationsNotInRegion(_ coordinateToGame: [CLLocationCoordinate2D : Game]) {
        for (coordinate, annotation) in coordinateToAnnotation {
            if coordinateToGame[coordinate] == nil {
                mapView.removeAnnotation(annotation)
                coordinateToAnnotation[coordinate] = nil
            }
        }
    }
    
    private func addNewAnnotations(_ coordinateToGame: [CLLocationCoordinate2D : Game]) {
        for (coordinate, game) in coordinateToGame {
            if coordinateToAnnotation[coordinate] == nil {
                let annotation = GameAnnotation(game: game)
                mapView.addAnnotation(annotation)
                coordinateToAnnotation[coordinate] = annotation
            }
        }
    }
    
    private func createViewModels(from coordinateToGame: [CLLocationCoordinate2D : Game]) {
        viewModels.removeAll()
        for (_, game) in coordinateToGame {
            let viewModel = GameViewModel(game: game)
            viewModel.onSelect { [unowned self] (viewModel) in
                guard let navController = self.navigationController else {
                    fatalError("Failed to unwrap navigationController")
                }
                self.presenter?.gameCellTapped(game: viewModel.model, navController)
            }
            viewModels.append(viewModel)
        }
        
        viewModels = viewModels.sorted(by: { (viewModel1, viewModel2) -> Bool in
            return viewModel1.id < viewModel2.id
        })
        
        collectionView.source = Source(viewModels: viewModels, isInfiniteCollectionView: true)
    }
    
    private func reloadGamesView() {
        collectionView.reloadData()
        // calculate new selectedItem, then scroll to it
        if viewModels.count > 0 {
            selectedItem = (NUM_ANNOTATIONS_DATA_SETS / 2) * viewModels.count
            collectionView.scrollToItem(at: IndexPath(item: selectedItem, section: 0),
                                        at: .centeredHorizontally,
                                        animated: false)
        }
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        presentErrorMessage(errorMessage)
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let coordinate = view.annotation?.coordinate {
            if let annotation = coordinateToAnnotation[coordinate]
            {
                let targetItem = indexOfFirstViewModelThatMatches(annotation)
                
                let numGames = viewModels.count
                let currItem = selectedItem % numGames
                if currItem == targetItem {
                    return
                }
                
                let stepsToRight = (currItem > targetItem) ? numGames - (currItem) + targetItem : targetItem - currItem
                let right = (selectedItem + stepsToRight >= numGames * NUM_ANNOTATIONS_DATA_SETS) ? Int.max : stepsToRight
                
                let stepsToLeft = (currItem > targetItem) ? currItem - targetItem : numGames - targetItem + (currItem)
                let left = (selectedItem - stepsToLeft < 0) ? Int.max : stepsToLeft
                
                selectedItem += (left <= right) ? -left : right
                collectionView.scrollToItem(at: IndexPath(item: selectedItem, section: 0),
                                            at: .centeredHorizontally,
                                            animated: true)
            }
        }
    }
    
    private func indexOfFirstViewModelThatMatches(_ annotation: GameAnnotation) -> Int {
        var index = 0
        for i in 0 ..< viewModels.count {
            let viewModel = viewModels[i]
            if viewModel.id == annotation.id {
                index = i
                break
            }
        }
        return index
    }
}

// MARK: - set up UI
extension GamesVC {
    private func setupTopNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))
    }
    
    private func addSubviews() {
        mapView.addSubview(redoSearchButton)
        mapView.addSubview(collectionView)
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
    
    private func setCollectionViewContraints() {
        NSLayoutConstraint.activate([
            collectionView.bottomAnchor.constraint(equalTo: addGameButton.topAnchor, constant: -10),
            collectionView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: SCREEN_HEIGHT * 0.25)
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
