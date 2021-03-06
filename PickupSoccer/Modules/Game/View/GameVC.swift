//
//  GameVC.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GameVC: UIViewController {
    var presenter: GameViewToGamePresenter?
    var homeTeam = [String : Position]()
    var awayTeam = [String : Position]()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .brown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var collectionView: CollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = CollectionView(layout: layout)
        collectionView.register(TeamCVCell.self, forCellWithReuseIdentifier:TeamCVCell.cellId)
        collectionView.isPagingEnabled = true
        collectionView.backgroundView = self.soccerFieldView
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let soccerFieldView: SoccerFieldView = {
        let view = SoccerFieldView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    deinit {
        print("GameVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.addSubview(soccerFieldView)
        view.addSubview(collectionView)
        setupTopNavigationBar()
        setSoccerFieldViewConstraints()
        setCollectionViewConstraints()
        presenter?.updateGameView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        soccerFieldView.draw()
    }
    
    @objc func menuButtonTapped() {
        presenter?.menuButtonTapped()
    }
    
    private func setupTopNavigationBar() {
        title = "Home Team"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.init(white: 0.8, alpha: 1.0)]
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .init(white: 0.8, alpha: 1.0)
        navigationController?.navigationBar.barStyle = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(menuButtonTapped))
    }
    
    private func setSoccerFieldViewConstraints() {
        NSLayoutConstraint.activate([
            soccerFieldView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            soccerFieldView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            soccerFieldView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            soccerFieldView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
        ])
    }
    
    private func setImageViewConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension GameVC: PlayerInfoVCDelegate {
    func selectedPosition(position: Position, isWithHomeTeam: Bool) {
        if position != .none {
            presenter?.didSelectNewPosition(position, isWithHomeTeam: isWithHomeTeam)
        }
    }
}

extension GameVC: GamePresenterToGameView {
    func displayPlayers(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        
        let homeTeamViewModel = TeamViewModel(model: homeTeam)
        let awayTeamViewModel = TeamViewModel(model: awayTeam)
        collectionView.source = Source(viewModels: [homeTeamViewModel, awayTeamViewModel], didEndDecelerating: { [unowned self] (scrollView) in
            let x = scrollView.contentOffset.x
            let item = Int(x / self.safeAreaLayoutFrame.width)
            self.title = (item == 0) ? "Home Team" : "Away Team"
        })
        
        collectionView.reloadData()
    }
    
    func displayMenuAlert(_ didUserCreateGame: Bool, _ didUserJoinGame: Bool) {
        var actions = [UIAlertAction]()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actions.append(cancelAction)
        
        if didUserJoinGame {
            let changePositionAction = UIAlertAction(title: "Change Position", style: .default, handler: { _ in
                self.presenter?.changePositionButtonTapped(self)
            })
            actions.append(changePositionAction)
            
            let exitAction = UIAlertAction(title: "Exit Game", style: .default, handler: { _ in
                self.presenter?.exitGameButtonTapped()
            })
            actions.append(exitAction)
        }
        else {
            let joinAction = UIAlertAction(title: "Join", style: .default) { (_) in
                self.presenter?.joinGameButtonTapped(self)
            }
            actions.append(joinAction)
        }
        
        if didUserCreateGame {
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                if let navController = self.navigationController {
                    self.presenter?.deleteGameButtonTapped(navController)
                }
            })
            actions.append(deleteAction)
        }
        
        presentAlertActionSheet(actions: actions)
    }
    
    func displayConfirmationAlert() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to exit this game?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            self.presenter?.confirmButtonTapped()
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        presentErrorMessage(errorMessage)
    }
}
