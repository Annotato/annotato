import UIKit
import Combine

class DocumentEditViewController: UIViewController, AlertPresentable, SpinnerPresentable {
    let spinner = UIActivityIndicatorView(style: .large)
    var documentId: UUID?
    let toolbarHeight = 50.0
    var documentViewModel: DocumentViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initializeSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpWebSocketSubscribers()
    }

    func initializeSubviews() {
        initializeSpinner()

        initializeToolbar()

        Task {
            guard let documentId = documentId else {
                AnnotatoLogger.info("Document ID not passed to DocumentEditViewController. " +
                                    "Sample document will be used.",
                                    context: "DocumentEditViewController::initializeSubviews")
                documentViewModel = DocumentViewModel(model: SampleData.exampleDocument)
                initializeDocumentView()
                return
            }

            startSpinner()
            documentViewModel = await DocumentController.loadDocumentWithDeleted(documentId: documentId)
            stopSpinner()

            initializeDocumentView()
        }
    }

    private func initializeToolbar() {
        let toolbar = DocumentEditToolbarView(
            frame: CGRect(x: .zero, y: .zero, width: frame.width, height: toolbarHeight)
        )
        toolbar.actionDelegate = self

        view.addSubview(toolbar)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight).isActive = true
        toolbar.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        toolbar.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    }

    private func initializeDocumentView() {
        guard let documentViewModel = documentViewModel else {
            presentErrorAlert(errorMessage: "Failed to load document.")
            return
        }

        let documentView = DocumentView(
            frame: self.view.safeAreaLayoutGuide.layoutFrame,
            documentViewModel: documentViewModel
        )

        view.addSubview(documentView)

        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.topAnchor.constraint(
            equalTo: margins.topAnchor, constant: toolbarHeight).isActive = true
        documentView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        documentView.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
        documentView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
    }

    private func saveDocument() {
        Task {
            guard let documentViewModel = documentViewModel else {
                return
            }

            await DocumentController.updateDocumentWithDeleted(document: documentViewModel)
        }
    }
}

extension DocumentEditViewController: DocumentEditToolbarDelegate, Navigable {
    func didTapBackButton() {
        saveDocument()
        goBack()
    }

    func didTapShareButton() {
        guard let documentId = documentId else {
            return
        }
        goToShare(documentId: documentId)
    }
}

// MARK: Websocket
extension DocumentEditViewController {
    func setUpWebSocketSubscribers() {
        WebSocketManager.shared.annotationManager.$newAnnotation.sink { [weak self] newAnnotation in
            guard let newAnnotation = newAnnotation,
                  newAnnotation.documentId == self?.documentId else {
                return
            }

            self?.documentViewModel?.receiveNewAnnotation(newAnnotation: newAnnotation)
        }.store(in: &cancellables)

        WebSocketManager.shared.annotationManager.$updatedAnnotation.sink { [weak self] updatedAnnotation in
            guard let updatedAnnotation = updatedAnnotation,
                  updatedAnnotation.documentId == self?.documentId else {
                return
            }

            self?.documentViewModel?.receiveUpdateAnnotation(updatedAnnotation: updatedAnnotation)
        }.store(in: &cancellables)

        WebSocketManager.shared.annotationManager.$deletedAnnotation.sink { [weak self] deletedAnnotation in
            guard let deletedAnnotation = deletedAnnotation,
                  deletedAnnotation.documentId == self?.documentId else {
                return
            }

            self?.documentViewModel?.receiveDeleteAnnotation(deletedAnnotation: deletedAnnotation)
        }.store(in: &cancellables)
    }
}
