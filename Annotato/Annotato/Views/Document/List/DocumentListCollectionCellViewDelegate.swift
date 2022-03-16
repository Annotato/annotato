//
//  DocumentListCollectionCellViewDelegate.swift
//  Annotato
//
//  Created by Darren Heng on 14/3/22.
//

protocol DocumentListCollectionCellViewDelegate: AnyObject {
    func didSelectCellView(document: DocumentListViewModel)
}
