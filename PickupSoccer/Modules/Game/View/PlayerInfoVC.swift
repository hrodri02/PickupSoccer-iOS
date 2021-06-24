//
//  PlayerInfoVC.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/18/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

protocol PlayerInfoVCDelegate: AnyObject {
    func selectedPosition(position: Position, isWithHomeTeam: Bool)
}

class PlayerInfoVC: UIViewController
{
    let sectionTitles = ["Select Team", "Select Position"]
    let positionNames: [String] = ["Goal keeper",
                                   "Left full back",
                                   "Left center back",
                                   "Right center back",
                                   "Right full back",
                                   "Left side midfielder",
                                   "Left center midfield",
                                   "Right center midfield",
                                   "Right side midfielder",
                                   "Left center forward",
                                   "Right center forward"]
    var homeTeam = [Position]()
    var awayTeam = [Position]()
    var selectedIndexPathAndTeam: (indexPath: IndexPath, isWithHomeTeam: Bool)?
    var presenter: PlayerInfoVCToGamePresenter?
    weak var delegate: PlayerInfoVCDelegate?
    
    let teamSwitch: UISwitch = {
        let teamSwitch = UISwitch()
        teamSwitch.onTintColor = .systemTeal
        teamSwitch.isOn = true
        teamSwitch.addTarget(self, action: #selector(teamSwitchValueChanged), for: .valueChanged)
        teamSwitch.translatesAutoresizingMaskIntoConstraints = false
        return teamSwitch
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(PositionTVCell.self, forCellReuseIdentifier: "positionCellId")
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
        view.addSubview(tableView)
        setTableViewConstraints()
        setupTopNavigationBar()
        presenter?.updatePlayerInfoVC()
    }
    
    @objc func doneButtonTapped() {
        var selectedPosition: Position = .none
        var isWithHomeTeam = false
        
        if let (indexPath, isUserInHomeTeam) = selectedIndexPathAndTeam
        {
            let index = indexPath.item
            let position = isUserInHomeTeam ? homeTeam[index] : awayTeam[index]
            isWithHomeTeam = isUserInHomeTeam
            selectedPosition = position
        }
        
        delegate?.selectedPosition(position: selectedPosition, isWithHomeTeam: isWithHomeTeam)
        if let navController = navigationController {
            presenter?.doneButtonTapped(navController)
        }
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func teamSwitchValueChanged(_ sender: UISwitch) {
        tableView.reloadData()
    }
    
    private func setupTopNavigationBar() {
        title = "Player Info"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(doneButtonTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(closeButtonTapped))
        navigationController?.navigationBar.tintColor = UIColor.systemTeal
        navigationController?.navigationBar.barTintColor = UIColor.init(white: 0.15, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.init(white: 0.9, alpha: 1.0)]
    }
    
    private func setTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension PlayerInfoVC: GamePresenterToPlayerInfoVC {
    func displayFreePositions(_ homeTeam: [Position], _ awayTeam: [Position], isWithHomeTeam: Bool) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.teamSwitch.isOn = isWithHomeTeam
    }
}

extension PlayerInfoVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return (teamSwitch.isOn) ? homeTeam.count : awayTeam.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
            cell.backgroundColor = UIColor.init(white: 0.15, alpha: 1.0)
            cell.textLabel?.textColor = UIColor.init(white: 0.9, alpha: 1.0)
            cell.textLabel?.text = (teamSwitch.isOn) ? "Home Team" : "Away Team"
            cell.addSubview(teamSwitch)
            NSLayoutConstraint.activate([
                teamSwitch.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                teamSwitch.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10.0)
            ])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "positionCellId", for: indexPath) as! PositionTVCell
            let positionName = getPositionName(for: indexPath)
            let isSelected = isPositionSelected(at: indexPath)
            cell.configure(with: positionName, isSelected: isSelected)
            return cell
        }
    }
    
    private func getPositionName(for indexPath: IndexPath) -> String {
        let team = (teamSwitch.isOn) ? homeTeam : awayTeam
        let index = Int(team[indexPath.item].rawValue)
        return positionNames[index]
    }
    
    private func isPositionSelected(at indexPath: IndexPath) -> Bool {
        if let (selectedIndexPath, isWithHomeTeam) = selectedIndexPathAndTeam,
            teamSwitch.isOn == isWithHomeTeam
        {
            return selectedIndexPath == indexPath
        }
        return false
    }
}

extension PlayerInfoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = PaddingLabel(withInsets: 0, 0, 10.0, 0)
        label.text = sectionTitles[section]
        label.textColor = .lightGray
        label.backgroundColor = .black
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // unselect previous position
        if let indexPathAndTeam = selectedIndexPathAndTeam,
            indexPathAndTeam.isWithHomeTeam == teamSwitch.isOn
        {
            if let cell = tableView.cellForRow(at: indexPathAndTeam.indexPath) as? PositionTVCell {
                cell.checkmarkImageView.isHidden = true
            }
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! PositionTVCell
        cell.checkmarkImageView.isHidden = false
        
        selectedIndexPathAndTeam = (indexPath, teamSwitch.isOn)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}
