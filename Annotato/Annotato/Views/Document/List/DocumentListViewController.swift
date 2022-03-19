import UIKit

class DocumentListViewController: UIViewController, AlertPresentable {
    private var documents: [DocumentListViewModel]?
    let toolbarHeight = 50.0

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubviews()
    }

    private func initializeSubviews() {
        initializeToolbar()

        Task {
            guard let userId = AnnotatoAuth().currentUser?.uid else {
                AnnotatoLogger.info("Could not get current user, sample documents will be used",
                                    context: "DocumentListViewController::initializeSubviews")

                documents = SampleData.exampleDocumentsInList
                initializeDocumentsCollectionView()
                return
            }

            documents = await DocumentController.loadAllDocuments(userId: userId)
            initializeDocumentsCollectionView()
        }
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
        guard let documents = documents else {
            presentErrorAlert(errorMessage: "Failed to load documents.")
            return
        }

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

        AnnotatoPdfStorageManager().uploadPdf(fileSystemUrl: selectedFileUrl,
                                              withName: selectedFileUrl.lastPathComponent) { [weak self] document in
            // TODO: Remove force-unwrapping once id is no longer optional
            DispatchQueue.main.sync {
                self?.goToDocumentEdit(documentId: document.id!)
            }
        }
    }

    func didSelectCellView(document: DocumentListViewModel) {
        goToDocumentEdit(documentId: document.id)
    }
}
