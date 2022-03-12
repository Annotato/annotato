//
//  ViewController.swift
//  Annotato
//
//  Created by Sivayogasubramanian on 10/3/22.
//

import UIKit
import PDFKit
import UniformTypeIdentifiers

class ViewController: UIViewController {
    let pdfView = PDFView()
    @IBOutlet private var nextButton: UIBarButtonItem!
    @IBOutlet private var annotateButton: UIBarButtonItem!
    @IBOutlet private var importFilesButton: UIBarButtonItem!

    let buttonHeight = 50.0

    var margins: UILayoutGuide {
        view.layoutMarginsGuide
    }

    var frame: CGRect {
        margins.layoutFrame
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPdfView()
        addObservers()
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

    @IBAction private func addAnnotation(_ sender: Any) {
        print("function called")
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

//    private func addAnnotationButton() {
//        let annotateButton = UIButton(frame: CGRect(x: 10, y: 10, width: 100, height: 40))
//        annotateButton.center = .init(x: 55, y: 25)
//
//        annotateButton.setTitle("Annotate last page", for: .normal)
//        annotateButton.configuration = .filled()
//        annotateButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        annotateButton.addTarget(self, action: #selector(addAnnotation), for: .touchUpInside)
//        view.addSubview(annotateButton)
//    }

//    private func addImportFileButton() {
//        let importFileButton = UIButton(frame: .init(x: 120, y: 20, width: 100, height: 40))
//        importFileButton.center = .init(x: 100, y: 25)
//
//        importFileButton.setTitle("Import File", for: .normal)
//        importFileButton.configuration = .filled()
//        importFileButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        importFileButton.addTarget(self, action: #selector(importFiles), for: .touchUpInside)
//        view.addSubview(importFileButton)
//    }

    @IBAction private func importFiles(_ sender: Any) {
        print("importing files")
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }

}

extension ViewController: PDFViewDelegate, UIDocumentPickerDelegate {
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        print(url)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Selected a document")
        guard let selectedFileUrl = urls.first else {
            return
        }
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        print("dir = \(dir)")
        print("selected file url = \(selectedFileUrl)")
    }
}
