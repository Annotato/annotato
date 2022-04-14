import UIKit
import Combine

class DocumentEditViewController: UIViewController, AlertPresentable, SpinnerPresentable {
    private var documentController: DocumentController?
    var webSocketManager: WebSocketManager?

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
        setUpSubscribers()
        self.documentController = DocumentController(webSocketManager: webSocketManager)
    }

    private func setUpSubscribers() {
        NetworkMonitor.shared.$isConnected.sink(receiveValue: { [weak self] _ in
            guard let self = self else {
                return
            }

            DispatchQueue.main.async {
                self.viewWillAppear(true)
            }
        }).store(in: &cancellables)
    }

    func initializeSubviews() {
        initializeSpinner()

        initializeToolbar()

        Task {
            guard let documentId = documentId else {
                return
            }

            startSpinner()
            documentViewModel = await documentController?.loadDocumentWithDeleted(documentId: documentId)
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

            await documentController?.updateDocumentWithDeleted(document: documentViewModel)
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
