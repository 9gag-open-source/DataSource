//
//  TableViewDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 04/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa

/// An object that implements `UITableViewDataSource` protocol
/// by returning the data from an associated dataSource.
///
/// The number of section and numbers of rows in sections
/// are taken directly from the dataSource.
///
/// The cells are dequeued from a tableView
/// by reuseIdentifiers returned by `reuseIdentifierForItem` function.
///
/// If a cell implements the `DataSourceItemReceiver` protocol
/// (e.g. by subclassing the `TableViewCell` class),
/// the item at the indexPath is passed to it via `ds_setItem` method.
///
/// A tableViewDataSource observes changes of the associated dataSource
/// and applies those changes to the associated tableView.
public class TableViewDataSource: NSObject, UITableViewDataSource {

	@IBOutlet public final var tableView: UITableView?

	public final let dataSource = ProxyDataSource()

	public final var reuseIdentifierForItem: (NSIndexPath, Any) -> String = {
		_ in "DefaultCell"
	}

	private let disposable = CompositeDisposable()

	public override init() {
		super.init()
		self.disposable += self.dataSource.changes.observeNext {
			[weak self] change in
			if let tableView = self?.tableView {
				change.apply(tableView)
			}
		}
	}

	deinit {
		self.disposable.dispose()
	}

	public func configureCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		let item = self.dataSource.itemAtIndexPath(indexPath)
		configureReceiver(cell, withItem: item)
	}

	public func configureCellForRowAtIndexPath(indexPath: NSIndexPath) {
		if let cell = self.tableView?.cellForRowAtIndexPath(indexPath) {
			self.configureCell(cell, forRowAtIndexPath: indexPath)
		}
	}

	public func configureVisibleCells() {
		if let indexPaths = self.tableView?.indexPathsForVisibleRows {
			for indexPath in indexPaths {
				self.configureCellForRowAtIndexPath(indexPath)
			}
		}
	}

	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return self.dataSource.numberOfSections
	}

	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.numberOfItemsInSection(section)
	}

	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let item: Any = self.dataSource.itemAtIndexPath(indexPath)
		let reuseIdentifier = self.reuseIdentifierForItem(indexPath, item)
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
		self.configureCell(cell, forRowAtIndexPath: indexPath)
		return cell
	}

}
