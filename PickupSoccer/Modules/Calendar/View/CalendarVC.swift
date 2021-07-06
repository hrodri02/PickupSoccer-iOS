//
//  CalendarVC.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/15/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

protocol CalendarVCDelegate: AnyObject {
    func onUpdatedSelectedDate(_ selectedDate: Date)
}

class CalendarVC: UIViewController {
    weak var delegate: CalendarVCDelegate?
    var presenter: CalendarViewToCalendarPresenter?
    var days: [Day]?
    var numOfWeeksInMonth: Int?
    private var baseDate: Date
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CalendarDateViewCVCell.self, forCellWithReuseIdentifier: CalendarDateViewCVCell.cellId)
        collectionView.backgroundColor = UIColor.black
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var headerView = CalendarPickerHeaderView()
    private lazy var footerView = CalendarPickerFooterView(delegate: self)
    
    init() {
        self.baseDate = Date()
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("CalendarVC \(#function)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.updateCalendarView()
        headerView.baseDate = baseDate
        footerView.baseDate = baseDate
        
        view.addSubview(headerView)
        view.addSubview(collectionView)
        view.addSubview(footerView)
        setHeaderViewConstraints()
        setCollectionViewConstraints()
        setFooterViewConstraints()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    private func reloadCalendar() {
        collectionView.reloadData()
    }
}

// MARK: - CalendarPresenterToCalendarView
extension CalendarVC: CalendarPresenterToCalendarView {
    func showCalendar(with daysOfMonth: [Day], _ numWeeksInMonth: Int) {
        self.days = daysOfMonth
        self.numOfWeeksInMonth = numWeeksInMonth
        reloadCalendar()
    }
    
    func onUpdatedSelectedDate(_ date: Date) {
        baseDate = date
        headerView.baseDate = date
        footerView.baseDate = date
        delegate?.onUpdatedSelectedDate(date)
    }
}

// MARK: - CalendarPickerFooterViewDelegate
extension CalendarVC: CalendarPickerFooterViewDelegate {
    func didTapPrevOrNextMonthButton(_ newBaseDate: Date) {
        self.baseDate = newBaseDate
        self.headerView.baseDate = newBaseDate
        self.presenter?.updateBaseDate(newBaseDate)
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDateViewCVCell.cellId, for: indexPath) as! CalendarDateViewCVCell
        guard let days = days else {
            fatalError("Failed to unwrap days")
        }
        let day = days[indexPath.row]
        cell.day = day
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let days = days else {
            fatalError("Failed to unwrap days")
        }
        
        let date = days[indexPath.item].date
        presenter?.userTappedADate(date)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / (numOfWeeksInMonth ?? 1)
        return CGSize(width: width, height: height)
    }
}

extension CalendarVC {
    private func setHeaderViewConstraints() {
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.20),
        ])
    }
    
    private func setCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.60),
        ])
    }
    
    private func setFooterViewConstraints() {
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            footerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.20)
        ])
    }
}
