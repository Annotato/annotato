import UIKit

class DocumentEditViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubviews()
    }

    func initializeSubviews() {
        initializeDocumentView()
    }

    private func initializeDocumentView() {
        let documentView = DocumentView(
            frame: self.view.safeAreaLayoutGuide.layoutFrame,
            documentViewModel: SampleData().exampleDocument()
        )

        view.addSubview(documentView)

        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        documentView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        documentView.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
        documentView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
    }
}
