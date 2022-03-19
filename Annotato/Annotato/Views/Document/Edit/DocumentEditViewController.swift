import UIKit

class DocumentEditViewController: UIViewController, AlertPresentable, SpinnerPresentable {
    let spinner = UIActivityIndicatorView(style: .large)
    var documentId: UUID?
    let toolbarHeight = 50.0
    var documentViewModel: DocumentViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubviews()
    }

    func initializeSubviews() {
        initializeSpinner()

        initializeToolbar()

        Task {
            guard let documentId = documentId else {
                AnnotatoLogger.info("Could not get current user, sample document will be used",
                                    context: "DocumentEditViewController::initializeSubviews")
                documentViewModel = DocumentViewModel(document: SampleData.exampleDocument)
                initializeDocumentView()
                return
            }

            startSpinner()
            documentViewModel = await DocumentController.loadDocument(documentId: documentId)
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
}

extension DocumentEditViewController: DocumentEditToolbarDelegate, Navigable {
    func didTapBackButton() {
        goBack()
    }
}
