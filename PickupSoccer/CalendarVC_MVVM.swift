//
//  CalendarVC_MVC.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/19/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class CalendarVC_MVVM: UIViewController, CalendarPickerFooterViewDelegate {
    func didTapPrevOrNextMonthButton(_ newBaseDate: Date) {
        self.headerView.baseDate = newBaseDate
        self.viewModel.baseDate = newBaseDate
        self.reloadCalendar()
    }
    
    weak var delegate: CalendarVCDelegate?
    var viewModel: CalendarViewModel!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CalendarDateViewCVCell.self, forCellWithReuseIdentifier: CalendarDateViewCVCell.reuseIdentifier)
        collectionView.backgroundColor = UIColor.black
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var headerView = CalendarPickerHeaderView()
    private lazy var footerView = CalendarPickerFooterView(delegate: self)
//    private lazy var footerView = CalendarPickerFooterView(didTapNextOrPrevMonthCompletionHandler: { [weak self] (newBaseDate) in
//        guard let self = self else { return }
//        self.viewModel.baseDate = newBaseDate
//        self.reloadCalendar()
//        self.headerView.baseDate = newBaseDate
//    })
    
    
    init() {
        viewModel = CalendarViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("CalendarVC_MVC \(#function)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.baseDate = viewModel.baseDate
        footerView.baseDate = viewModel.baseDate
        
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

// MARK: - UICollectionViewDataSource
extension CalendarVC_MVVM: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDateViewCVCell.reuseIdentifier, for: indexPath) as! CalendarDateViewCVCell
        let day = viewModel.days[indexPath.item]
        cell.day = day
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarVC_MVVM: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = viewModel.days[indexPath.item].date
        if viewModel.isSelectedDateValid(date) {
            viewModel.selectedDate = date
            reloadCalendar()
            headerView.baseDate = date
            footerView.baseDate = date
            delegate?.onUpdatedSelectedDate(date)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / viewModel.numOfWeeksInMonth
        return CGSize(width: width, height: height)
    }
}

extension CalendarVC_MVVM {
    private func setHeaderViewConstraints() {
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.20),
        ])
    }
    
    private func setCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.60),
        ])
    }
    
    private func setFooterViewConstraints() {
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            footerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.20)
        ])
    }
}

