//
//  ViewController.swift
//  Annotato
//
//  Created by Sivayogasubramanian on 10/3/22.
//

import UIKit
import PDFKit

class ViewController: UIViewController {
    let pdfView = PDFView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)

        guard let url = Bundle.main.url(forResource: "Lab01Qns", withExtension: "pdf") else {
            print("No such pdf")
            return
        }
        guard let document = PDFDocument(url: url) else {
            print("No such document")
            return
        }
        pdfView.document = document

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.frame = view.bounds
    }

}
