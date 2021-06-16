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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomeTeamCVCell.self, forCellWithReuseIdentifier: "HomeCellId")
        collectionView.register(AwayTeamCVCell.self, forCellWithReuseIdentifier: "AwayCellId")
        collectionView.isPagingEnabled = true
        collectionView.backgroundView = self.imageView
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    deinit {
        print("GameVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.addSubview(collectionView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(menuButtonTapped))
        setImageViewConstraints()
        setCollectionViewConstraints()
        setBackgroundImage()
        presenter?.updateGameView()
    }
    
    @objc func menuButtonTapped() {
        presenter?.menuButtonTapped()
    }
    
    private func setBackgroundImage() {
        if let imageURL = Bundle.main.url(forResource: "pexels-photo-2291006", withExtension: "jpeg") {
            do {
                let imageData = try Data(contentsOf: imageURL)
                imageView.image = UIImage(data: imageData)
            }
            catch {
                print(error.localizedDescription)
            }
        }
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

extension GameVC: GamePresenterToGameView {
    func displayPlayers(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        collectionView.reloadData()
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        presentErrorMessage(errorMessage)
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
    
    func displayMenuAlert(_ didUserCreateGame: Bool) {
        let exitAction = UIAlertAction(title: "Exit", style: .default, handler: { _ in
            self.presenter?.exitGameButtonTapped()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        var actions = [exitAction, cancelAction]
        
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
}

extension GameVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCellId", for: indexPath) as! HomeTeamCVCell
            cell.configure(with: homeTeam) { [unowned self] (newPosition) in
                self.presenter?.didSelectNewPosition(newPosition, isHomeTeam: true)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AwayCellId", for: indexPath) as! AwayTeamCVCell
        cell.configure(with: awayTeam) { [unowned self] (newPosition) in
            self.presenter?.didSelectNewPosition(newPosition, isHomeTeam: false)
        }
        return cell
    }
}

extension GameVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
