//
//  CollectionViewCell.swift
//  DataSource
//
//  Created by Vadim Yelagin on 10/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import UIKit
import ReactiveCocoa

public class CollectionViewCell: UICollectionViewCell {

	public final let item = MutableProperty<Any?>(nil)

}
