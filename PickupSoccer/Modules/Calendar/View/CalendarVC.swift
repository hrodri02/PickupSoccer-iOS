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
    var numOfWeeksInMonth: Int?
    private var baseDate: Date
    
    private lazy var collectionView: CollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = CollectionView(layout: layout)
        collectionView.register(CalendarDateViewCVCell.self, forCellWithReuseIdentifier: CalendarDateViewCVCell.cellId)
        collectionView.backgroundColor = UIColor.black
        collectionView.isScrollEnabled = false
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
        let viewModels = daysOfMonth.map({ (day) -> DayViewModel in
            let dayViewModel = DayViewModel(day: day, numOfWeeksInMonth: numWeeksInMonth)
            dayViewModel.onSelect { [unowned self] (viewModel) in
                let date = viewModel.model.date
                self.presenter?.userTappedADate(date)
            }
            return dayViewModel
        })
        collectionView.source = Source(viewModels: viewModels)
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
