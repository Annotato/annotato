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
    @IBOutlet var nextButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)
        addObservers()
        guard let url = Bundle.main.url(forResource: "Lab01Qns", withExtension: "pdf") else {
            print("No such pdf")
            return
        }
        guard let document = PDFDocument(url: url) else {
            print("No such document")
            return
        }
        pdfView.document = document
        pdfView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.frame = view.bounds
    }

    @IBAction private func handleNextButtonTapped(_ sender: Any) {
        pdfView.goToNextPage(nil)
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePageChange(notification:)),
                                               name: Notification.Name.PDFViewPageChanged, object: nil)
    }

    @objc private func handlePageChange(notification: Notification) {
        print("changed pages")
        nextButton.isEnabled = pdfView.canGoToNextPage
    }

}

extension ViewController: PDFViewDelegate {
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        print(url)
    }
}
