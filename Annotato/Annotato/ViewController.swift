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
    @IBOutlet private var nextButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        addPdfView()
        addObservers()
        addAnnotationButton()
    }

    private func addPdfView() {
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

    @objc private func addAnnotation() {
        guard let document = pdfView.document else {
            return
        }
        let lastPage = document.page(at: document.pageCount - 1)
        let annotation = PDFAnnotation(
            bounds: CGRect(x: 100, y: 100, width: 100, height: 20),
            forType: .freeText, withProperties: nil)
        annotation.contents = "Hello, world!"
        annotation.font = UIFont.systemFont(ofSize: 15.0)
        annotation.fontColor = .blue
        annotation.color = .clear
        lastPage?.addAnnotation(annotation)
    }

    private func addAnnotationButton() {
        let annotateButton = UIButton(frame: CGRect(x: .zero, y: .zero, width: 240, height: 40))
        annotateButton.setTitle("Annotate last page", for: .normal)
        annotateButton.configuration = .filled()
        annotateButton.titleLabel?.adjustsFontSizeToFitWidth = true
        annotateButton.center = view.center
        annotateButton.addTarget(self, action: #selector(addAnnotation), for: .touchUpInside)
        view.addSubview(annotateButton)
    }

}

extension ViewController: PDFViewDelegate {
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        print(url)
    }
}
