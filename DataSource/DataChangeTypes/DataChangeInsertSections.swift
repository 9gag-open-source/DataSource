//
//  DataChangeInsertSections.swift
//  DataSource
//
//  Created by Vadim Yelagin on 09/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public struct DataChangeInsertSections: DataChange {

	public let sections: NSIndexSet

	public init(_ sections: NSIndexSet) {
		self.sections = sections
	}

	public init(_ sections: Range<Int>) {
		self.init(NSIndexSet(ds_range: sections))
	}

	public init (_ section: Int) {
		self.init(NSIndexSet(index: section))
	}

	public func apply(target: DataChangeTarget) {
		target.ds_insertSections(sections)
	}

	public func mapSections(map: Int -> Int) -> DataChangeInsertSections {
		return DataChangeInsertSections(sections.ds_map(map))
	}

}
