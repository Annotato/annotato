import UIKit

class DocumentListViewController: UIViewController {
    private var documents = SampleData().exampleDocumentsInList()
    let toolbarHeight = 50.0

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubviews()
    }

    private func initializeSubviews() {
        initializeToolbar()
        initializeDocumentsCollectionView()
    }

    private func initializeToolbar() {
        let toolbar = DocumentListToolbarView(
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

    private func initializeDocumentsCollectionView() {
        let collectionView = DocumentListCollectionView(
            documents: documents,
            frame: .zero,
            documentListCollectionCellViewDelegate: self
        )

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.widthAnchor.constraint(equalToConstant: frame.width * 0.9).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: frame.height * 0.9).isActive = true
        collectionView.topAnchor.constraint(equalTo: margins.topAnchor, constant: toolbarHeight + 10.0).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    }
}

extension DocumentListViewController: DocumentListToolbarDelegate,
        UIDocumentPickerDelegate,
        DocumentListCollectionCellViewDelegate,
        Navigable {

    func didTapImportFileButton() {
        goToImportingFiles()
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt baseFileUrls: [URL]) {
        guard let selectedFileUrl = baseFileUrls.first else {
            return
        }
        guard FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil else {
            return
        }
        let newDocumentViewModel = DocumentViewModel(
            annotations: [],
            pdfDocument: PdfViewModel(baseFileUrl: selectedFileUrl)
        )
        goToDocumentEdit(documentViewModel: newDocumentViewModel)
    }

    func didSelectCellView(document: DocumentListViewModel) {
        // Note: this is supposed to be an api call to fetch the documentViewModel
        // based on the id of documentListViewModel once integration is done
        // The document list view model in this pr does not have id yet

        goToDocumentEdit(documentViewModel: SampleData().exampleDocument(from: document))
    }
}
