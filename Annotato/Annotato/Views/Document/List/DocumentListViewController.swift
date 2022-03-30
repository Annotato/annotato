import UIKit

class DocumentListViewController: UIViewController, AlertPresentable, SpinnerPresentable {
    let spinner = UIActivityIndicatorView(style: .large)
    private var toolbar = DocumentListToolbarView()
    private var importMenu = DocumentListImportMenu()
    private var documents: [DocumentListViewModel]?
    let toolbarHeight = 50.0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initializeDocumentsCollectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSpinner()
        initializeToolbar()
        initializeImportMenu()
        view.bringSubviewToFront(importMenu)
    }

    private func initializeToolbar() {
        toolbar = DocumentListToolbarView(
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

    private func initializeImportMenu() {
        let width = 120.0
        let height = 80.0
        importMenu = DocumentListImportMenu(frame: .zero)

        view.addSubview(importMenu)

        importMenu.translatesAutoresizingMaskIntoConstraints = false
        importMenu.topAnchor.constraint(equalTo: toolbar.bottomAnchor).isActive = true
        importMenu.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        importMenu.widthAnchor.constraint(equalToConstant: width).isActive = true
        importMenu.heightAnchor.constraint(equalToConstant: height).isActive = true

        importMenu.isHidden = true
        importMenu.actionDelegate = self
    }

    private func initializeDocumentsCollectionView() {
        Task {
            guard let userId = AnnotatoAuth().currentUser?.uid else {
                AnnotatoLogger.info("Could not get current user.",
                                    context: "DocumentListViewController::initializeSubviews")

                documents = []
                addDocumentsSubview()
                return
            }

            startSpinner()
            documents = await DocumentController.loadAllDocuments(userId: userId)
            stopSpinner()

            addDocumentsSubview()
        }
    }

    private func addDocumentsSubview() {
        guard let documents = documents else {
            presentErrorAlert(errorMessage: "Failed to load documents.")
            return
        }

        let collectionView = DocumentListCollectionView(
            documents: documents,
            frame: .zero,
            documentListCollectionCellViewDelegate: self
        )

        view.replaceSubview(newSubview: collectionView)

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

    func didTapLogOutButton() {
        presentWarningAlert(alertTitle: "Log Out",
                            warningMessage: "Are you sure you want to log out?", confirmHandler: { [weak self] in
            AnnotatoAuth().logOut()
            self?.goToAuth(asNewRootViewController: true)
        })
    }

    func didTapImportFileButton() {
        importMenu.isHidden.toggle()

        if !importMenu.isHidden {
            view.bringSubviewToFront(importMenu)
        }
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
            DispatchQueue.main.async {
                self?.goToDocumentEdit(documentId: document.id)
            }
        }
    }

    func didSelectCellView(document: DocumentListViewModel) {
        goToDocumentEdit(documentId: document.id)
    }
}

extension DocumentListViewController: DocumentListImportMenuDelegate {
    func didTapFromIpadButton() {
        goToImportingFiles()
    }

    func didTapFromCodeButton() {
        goToImportByCode()
    }
}
