import UIKit

class DocumentEditViewController: UIViewController, AlertPresentable {
    var documentId: UUID?
    let toolbarHeight = 50.0
    // TODO: Remove the default value once we do not want to fall back on Clean Code when file not found
    var documentViewModel: DocumentViewModel? = DocumentViewModel(document: SampleData.exampleDocument)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("inside contorller, documentId is \(documentId)")

        Task {
            guard let documentId = documentId else {
                return
            }

            print("going to load document with id \(documentId)")

            documentViewModel = await DocumentController.loadDocument(documentId: documentId)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubviews()
    }

    func initializeSubviews() {
        initializeToolbar()

        initializeDocumentView()
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

//    private func initializeDocumentView() {
//        let documentView = DocumentView(
//            frame: self.view.safeAreaLayoutGuide.layoutFrame,
//            documentViewModel: SampleData().exampleDocument()
//        )
//
//        view.addSubview(documentView)
//
//        documentView.translatesAutoresizingMaskIntoConstraints = false
//        documentView.topAnchor.constraint(
//            equalTo: margins.topAnchor, constant: toolbarHeight).isActive = true
//        documentView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
//        documentView.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
//        documentView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
//    }
}

extension DocumentEditViewController: DocumentEditToolbarDelegate, Navigable {
    func didTapBackButton() {
        goBack()
    }
}
