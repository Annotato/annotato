//
//  DocumentPdfViewModel.swift
//  Annotato
//
//  Created by Darren Heng on 13/3/22.
//

import UIKit
import PDFKit

class DocumentPdfViewModel {

    let autoScales = true
    let document: PDFDocument

    init(url: URL) {
        guard let document = PDFDocument(url: url) else {
            fatalError("No such document")
        }
        self.document = document
    }
}
