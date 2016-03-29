//
//  CompositeDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 04/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

/// `DataSource` implementation that is composed of an array
/// of other dataSources (called inner dataSources).
///
/// Sections of inner dataSources become the sections of the compositeDataSource
/// in the following order: first all the sections of the first inner dataSource,
/// then all the sections of the second inner dataSource, and so on.
///
/// CompositeDataSource listens to dataChanges in all of its inner dataSources
/// and emits them as its own changes, after mapping section indices in them
/// to correspond to the structure of the compositeDataSource.
public final class CompositeDataSource: DataSource {

	public let changes: Signal<DataChange, NoError>
	private let observer: Signal<DataChange, NoError>.Observer
	private let disposable = CompositeDisposable()

	public let innerDataSources: [DataSource]

	public init(_ inner: [DataSource]) {
		(self.changes, self.observer) = Signal<DataChange, NoError>.pipe()
		self.innerDataSources = inner
		for (index, dataSource) in inner.enumerate() {
			self.disposable += dataSource.changes.observeNext {
				[weak self] change in
				if let this = self {
					let map = mapOutside(this.innerDataSources, index)
					let mapped = change.mapSections(map)
					this.observer.sendNext(mapped)
				}
			}
		}
	}

	deinit {
		self.observer.sendCompleted()
		self.disposable.dispose()
	}

	public var numberOfSections: Int {
		return self.innerDataSources.reduce(0) {
			subtotal, dataSource in
			return subtotal + dataSource.numberOfSections
		}
	}

	public func numberOfItemsInSection(section: Int) -> Int {
		let (index, innerSection) = mapInside(self.innerDataSources, section)
		return self.innerDataSources[index].numberOfItemsInSection(innerSection)
	}

	public func supplementaryItemOfKind(kind: String, inSection section: Int) -> Any? {
		let (index, innerSection) = mapInside(self.innerDataSources, section)
		return self.innerDataSources[index].supplementaryItemOfKind(kind, inSection: innerSection)
	}

	public func itemAtIndexPath(indexPath: NSIndexPath) -> Any {
		let (index, innerSection) = mapInside(self.innerDataSources, indexPath.section)
		let innerPath = indexPath.ds_setSection(innerSection)
		return self.innerDataSources[index].itemAtIndexPath(innerPath)
	}

	public func leafDataSourceAtIndexPath(indexPath: NSIndexPath) -> (DataSource, NSIndexPath) {
		let (index, innerSection) = mapInside(self.innerDataSources, indexPath.section)
		let innerPath = indexPath.ds_setSection(innerSection)
		return self.innerDataSources[index].leafDataSourceAtIndexPath(innerPath)
	}

}

func mapInside(inner: [DataSource], _ outerSection: Int) -> (Int, Int) {
	var innerSection = outerSection
	var index = 0
	while innerSection >= inner[index].numberOfSections {
		innerSection -= inner[index].numberOfSections
		index += 1
	}
	return (index, innerSection)
}

func mapOutside(inner: [DataSource], _ index: Int) -> Int -> Int {
	return { innerSection in
		var outerSection = innerSection
		for i in 0 ..< index {
			outerSection += inner[i].numberOfSections
		}
		return outerSection
	}
}
