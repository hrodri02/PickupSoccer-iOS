//
//  CreateGameViewController.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/1/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GameTimeVC: UIViewController {
    var presenter: GameTimeViewToCreateGamePresenter?
    
    private let calendar = Calendar(identifier: .gregorian)
    private var selectedDate: Date
    private var calendarVC: UIViewController?
    
    #if DEBUG_GAME_TIME_VC
    let formatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    #endif
    
    lazy var startTimeView: SetTimeView = {
        let setTimeView = SetTimeView(text: "Start time") {[weak self] (startHour, startMin) in
            guard let weakSelf = self else { return }
            let (durHours, durMins) = weakSelf.getDurationInHourMin()
            weakSelf.presenter?.checkIfGameTimeValid(weakSelf.selectedDate,
                                                     startHour: startHour,
                                                     startMin: startMin,
                                                     durHours: durHours,
                                                     durMins: durMins)
        }
        
        setTimeView.translatesAutoresizingMaskIntoConstraints = false
        return setTimeView
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "0 h 00 m"
        label.textColor = Colors.mainTextColor
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var durationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 2.0
        slider.minimumTrackTintColor = UIColor.systemTeal
        slider.addTarget(self, action: #selector(durationSliderValueChanged), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.init(white: 0.95, alpha: 1.0), for: .normal)
        button.backgroundColor = UIColor.systemTeal
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 5.0
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init() {
        self.selectedDate = Date()
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        definesPresentationContext = true
    }
    
    deinit {
        print("GameTimeVC \(#function)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        presenter?.updateGameTimeView()
        setupTopNavigationBar()
    }
    
    private func getDurationInHourMin() -> (Int, Int) {
        let val = durationSlider.value
        let numberOfThirtyMinutes = Int(ceil((val - 0.25) / 0.5))
        let hours = numberOfThirtyMinutes / 2
        let mins = (numberOfThirtyMinutes - hours * 2) * 30
        return (hours, mins)
    }
    
    // MARK: - Objective-C methods
    @objc func durationSliderValueChanged(sender: UISlider) {
        let (durHours, durMins) = getDurationInHourMin()
        let minsStr = (durMins == 0) ? "0\(durMins)" : "\(durMins)"
        durationLabel.text = "\(durHours) h \(minsStr) m"
        
        let (startHour, startMin) = startTimeView.getSelectedTimeInHourMinAmPm()
        presenter?.checkIfGameTimeValid(selectedDate,
                                        startHour: startHour,
                                        startMin: startMin,
                                        durHours: durHours,
                                        durMins: durMins)
    }
    
    @objc func nextButtonTapped() {
        let gameDate = selectedDate
        let (startHour, startMin) = startTimeView.getSelectedTimeInHourMinAmPm()
        let (durHours, durMins) = getDurationInHourMin()
        
        let hourOfStartDate = (startHour < 24 || startHour == 24 && startMin == 0) ? startHour : 0
        
        if let startDate = calendar.date(bySettingHour: hourOfStartDate, minute: startMin, second: 0, of: gameDate),
            let endDateSetHour = calendar.date(byAdding: .hour, value: durHours, to: startDate),
            let endDate = calendar.date(byAdding: .minute, value: durMins, to: endDateSetHour)
        {
            #if DEBUG_GAME_TIME_VC
            print("start date = \(formatter.string(from: startDate)), end date = \(formatter.string(from: endDate))")
            #endif
            presenter?.setDateIntervalOfNewGame(DateInterval(start: startDate, end: endDate))
            presenter?.showLocationVC(with: navigationController!)
        }
        else {
            assertionFailure("Failed to create start date and end date for game")
        }
    }
    
    @objc func cancelButtonTapped() {
        presenter?.cancelCreateGame(navigationController!)
    }
}

// MARK: - CalendarVCDelegate
extension GameTimeVC: CalendarVCDelegate {
    func onUpdatedSelectedDate(_ date: Date) {
        selectedDate = date
        let (durHours, durMins) = getDurationInHourMin()
        let (startHour, startMin) = startTimeView.getSelectedTimeInHourMinAmPm()
        presenter?.checkIfGameTimeValid(selectedDate,
                                        startHour: startHour,
                                        startMin: startMin,
                                        durHours: durHours,
                                        durMins: durMins)
    }
}

// MARK: - PresenterToViewCreateGameProtocol
extension GameTimeVC: CreateGamePresenterToGameTimeView {
    func onBuiltCalendarModule(viewController: UIViewController) {
        calendarVC = viewController
        addChild(viewController)
        addSubviews()
        setContraints()
    }
    
    func onValidatedGameTime(isValid: Bool) {
        nextButton.isEnabled = isValid
        nextButton.alpha = nextButton.isEnabled ? 1.0 : 0.5
    }
}

// MARK: - UI setup
extension GameTimeVC
{
    private func setupTopNavigationBar() {
        title = "Set Time"
        navigationController?.navigationBar.barTintColor = Colors.mainTextColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
    }
    
    private func addSubviews() {
        view.addSubview(calendarVC!.view)
        view.addSubview(startTimeView)
        view.addSubview(durationLabel)
        view.addSubview(durationSlider)
        view.addSubview(nextButton)
    }
    
    private func setContraints() {
        setCalendarViewConstraints()
        setStartTimeViewConstriants()
        setDurationLabelConstriants()
        setDurationSliderConstraints()
        setnextButtonConstraints()
    }
    
    private func setCalendarViewConstraints() {
        calendarVC!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarVC!.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarVC!.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            calendarVC!.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            calendarVC!.view.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.6)
        ])
    }
    
    private func setStartTimeViewConstriants() {
        NSLayoutConstraint.activate([
            startTimeView.topAnchor.constraint(equalTo: calendarVC!.view.bottomAnchor, constant: 10),
            startTimeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            startTimeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            startTimeView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.10)
        ])
    }
    
    private func setDurationLabelConstriants() {
        NSLayoutConstraint.activate([
            durationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            durationLabel.centerYAnchor.constraint(equalTo: durationSlider.centerYAnchor)
        ])
    }
    
    private func setDurationSliderConstraints() {
        NSLayoutConstraint.activate([
            durationSlider.topAnchor.constraint(equalTo: startTimeView.bottomAnchor, constant: 10.0),
            durationSlider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            durationSlider.leadingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: 10),
        ])
    }
    
    private func setnextButtonConstraints() {
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -SCREEN_HEIGHT * 0.05),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            nextButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.125),
        ])
    }
}

