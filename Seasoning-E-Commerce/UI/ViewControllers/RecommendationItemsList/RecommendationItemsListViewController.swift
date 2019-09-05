//
//  RecommendationItemsListViewController.swift
//  Seasoning-E-Commerce
//
//  Created by iniad on 2019/08/15.
//

import RxSwift
import SnapKit
import UIKit

protocol RecommendationItemsListView {
    func showErrorMessage(text: String)
}

class RecommendationItemsListViewController: UIViewController, RecommendationItemsListView {
    var store: RecommendationItemsListStoreImpl!

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 35, right: 0)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.register(UINib(nibName: "RecommendedListCell", bundle: nil), forCellWithReuseIdentifier: "recommendedlist")
        view.register(UINib(nibName: "HotRankingCell", bundle: nil), forCellWithReuseIdentifier: "hotranking")
        view.register(UINib(nibName: "ListHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "listheader")
        return view
    }()
    private let errorView = ErrorMessageView()

    let disposeBag = DisposeBag()

    override func loadView() {
        let backView = UIView(frame: UIScreen.main.bounds)
        backView.backgroundColor = UIColor.white
        self.view = backView
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.errorView)
        self.collectionView.snp.makeConstraints { maker in
            maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            maker.leading.equalToSuperview()
            maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            maker.trailing.equalToSuperview()
        }
        self.errorView.snp.makeConstraints { maker in
            maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            maker.leading.equalToSuperview()
            maker.trailing.equalToSuperview()
            maker.height.equalTo(50)
        }
        self.errorView.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.store?.shouldRealoadData
            .subscribe(onNext: { [weak self] section in
                self?.collectionView.reloadSections(IndexSet(arrayLiteral: section))
            })
            .disposed(by: disposeBag)
    }

    func showErrorMessage(text: String) {
        guard self.errorView.isHidden else {
            return
        }
        self.errorView.label.text = text
        self.errorView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.errorView.isHidden = true
        }
    }
}

extension RecommendationItemsListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return store.recommendedItem.count
        } else {
            return store.hotrankingItem.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendedlist", for: indexPath) as? RecommendedListCell else {
                fatalError()
            }
            cell.update(item: store.recommendedItem[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotranking", for: indexPath) as? HotRankingCell else {
                fatalError()
            }
            cell.update(item: store.hotrankingItem[indexPath.item])
            return cell
        }
    }
}

extension RecommendationItemsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 20
        let contentWidth = collectionView.frame.width - margin * 2
        if indexPath.section == 0 {
            return CGSize(width: contentWidth, height: contentWidth * RecommendedListCell.cellHeightRatio)
        } else {
            let contentMargin: CGFloat = 20
            let width = (contentWidth - contentMargin) / 2
            return CGSize(width: width, height: width * HotRankingCell.cellHeightRatio)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "listheader",
                for: indexPath
                ) as? ListHeaderView else {
                    fatalError()
            }
            if indexPath.section == 0 {
                header.update(title: "Daily choice")
            } else {
                header.update(title: "Weekly Ranking")
            }
            return header
        } else {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
}

extension RecommendationItemsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.store?.selectRecommendedItem(index: indexPath.item)
        } else {
            self.store?.selectHotRankingItem(index: indexPath.item)
        }
    }
}
