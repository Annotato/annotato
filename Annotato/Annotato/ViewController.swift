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
    var pdfTapGestures: [UITapGestureRecognizer] = []
    var tripleTapAnnotateGesture = UITapGestureRecognizer()
    @IBOutlet private var nextButton: UIBarButtonItem!
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
        addTripleTapGestureAddAnnotation()
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
        pdfView.autoScales = true
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

    private func addAnnotationAtLocation(location: CGPoint, text: String) {
        print("add annotation at location")
        guard let currentPage = pdfView.currentPage else {
            return
        }
        let textAnnotation = PDFAnnotation(
            bounds: CGRect(x: location.x, y: location.y, width: 20, height: 20),
            forType: .text, withProperties: nil
        )
        textAnnotation.contents = text
        textAnnotation.color = .clear
        currentPage.addAnnotation(textAnnotation)
    }

    @IBAction private func importFiles(_ sender: Any) {
        print("importing files")
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }

    private func addTripleTapGestureAddAnnotation() {
        guard let pdfDefaultGestures = pdfView.gestureRecognizers else {
            print("no gestures in pdfview")
            return
        }
        for gesture in pdfDefaultGestures where gesture is UITapGestureRecognizer {
            if let gesture = gesture as? UITapGestureRecognizer {
                self.pdfTapGestures.append(gesture)
            }
        }
        let tripleTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didTripleTap))
        tripleTapGestureRecognizer.numberOfTapsRequired = 3
        tripleTapGestureRecognizer.delegate = self
        pdfView.addGestureRecognizer(tripleTapGestureRecognizer)
        self.tripleTapAnnotateGesture = tripleTapGestureRecognizer
    }

    @objc func didTripleTap(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .ended else {
            return
        }
        print("triple tapped")
        let tapLocation = sender.location(in: pdfView)
        print(tapLocation)
        print(pdfView.scaleFactor)
        print(pdfView.autoScales)
        print(pdfView.scaleFactorForSizeToFit)
        print(pdfView.currentDestination)

        let newX = tapLocation.x / pdfView.scaleFactor
        let newY = (pdfView.bounds.height - tapLocation.y) / pdfView.scaleFactor
        let annotateLocation = CGPoint(x: newX, y: newY)
        print(annotateLocation)
        addAnnotationAtLocation(location: annotateLocation, text: "Hi everybody")
    }
}

// MARK: Extension
extension ViewController: PDFViewDelegate, UIDocumentPickerDelegate, UIGestureRecognizerDelegate {
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
        guard let document = PDFDocument(url: selectedFileUrl) else {
            print("No such document")
            return
        }
        pdfView.document = document
    }

    func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard let gestureRecognizer: UITapGestureRecognizer = gestureRecognizer as? UITapGestureRecognizer else {
            return false
        }
        guard let otherGestureRecognizer: UITapGestureRecognizer = otherGestureRecognizer as? UITapGestureRecognizer
        else {
            return false
        }
        if gestureRecognizer == tripleTapAnnotateGesture &&
            self.pdfTapGestures.contains(otherGestureRecognizer) {
            return true
        }
        return false
    }
}
