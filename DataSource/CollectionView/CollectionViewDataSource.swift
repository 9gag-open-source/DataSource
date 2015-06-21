//
//  CollectionViewDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 10/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa

public class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    @IBOutlet public final var collectionView: UICollectionView?
    
    public final let dataSource = ProxyDataSource()
    
    public final var reuseIdentifierForItem: (NSIndexPath, Any) -> String = {
        _ in "DefaultCell"
    }
    
    public final var reuseIdentifierForSupplementaryItem: (String, Int, Any?) -> String = {
        _ in "DefaultSupplementaryView"
    }
    
    private let disposable = CompositeDisposable()
    
    public override init() {
        super.init()
        self.disposable += self.dataSource.changes.observe(next: {
            [weak self] change in
            if let collectionView = self?.collectionView {
                change.apply(collectionView)
            }
        })
    }
    
    deinit {
        self.disposable.dispose()
    }
    
    public func configureCell(cell: CollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.item.value = self.dataSource.itemAtIndexPath(indexPath)
    }
    
    public func configureCellForItemAtIndexPath(indexPath: NSIndexPath) {
        if let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? CollectionViewCell {
            self.configureCell(cell, forItemAtIndexPath: indexPath)
        }
    }
    
    public func configureVisibleCells() {
        if let indexPaths = self.collectionView?.indexPathsForVisibleItems() as? [NSIndexPath] {
            for indexPath in indexPaths {
                self.configureCellForItemAtIndexPath(indexPath)
            }
        }
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.dataSource.numberOfSections
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.numberOfItemsInSection(section)
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        let item = self.dataSource.supplementaryItemOfKind(kind, inSection: section)
        let reuseIdentifier = self.reuseIdentifierForSupplementaryItem(kind, section, item)
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath) as! CollectionViewReusableView
        view.item.value = item
        return view
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item: Any = self.dataSource.itemAtIndexPath(indexPath)
        let reuseIdentifier = self.reuseIdentifierForItem(indexPath, item)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        self.configureCell(cell, forItemAtIndexPath: indexPath)
        return cell
    }
    
}
