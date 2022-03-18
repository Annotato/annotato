import UIKit

class DocumentEditViewController: UIViewController {
    let toolbarHeight = 50.0
    var currentDocumentViewModel: DocumentViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubviews()
    }

    func initializeSubviews() {
        initializeToolbar()

        if let currentDocumentViewModel = currentDocumentViewModel {
            initializeDocumentView(documentViewModel: currentDocumentViewModel)
        } else {
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

    private func initializeDocumentView(documentViewModel: DocumentViewModel) {
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

    private func initializeDocumentView() {
        let documentView = DocumentView(
            frame: self.view.safeAreaLayoutGuide.layoutFrame,
            documentViewModel: SampleData().exampleDocument()
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
