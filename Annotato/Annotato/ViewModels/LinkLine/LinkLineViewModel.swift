// import CoreGraphics
// import Combine
// import Foundation
//
// class LinkLineViewModel: ObservableObject {
//    private(set) var id: UUID
//    private var cancellables: Set<AnyCancellable> = []
//
//    @Published var selectionBoxPoint: CGPoint
//    @Published var annotationPoint: CGPoint
//    @Published var isRemoved = false
//
//    unowned var annotationViewModel: AnnotationViewModel? {
//        didSet {
//            guard let annotationViewModel = annotationViewModel else {
//                return
//            }
//            setUpSubscribers()
//            self.annotationPoint = annotationViewModel.origin
//        }
//    }
//    unowned var selectionBoxViewModel: SelectionBoxViewModel? {
//        didSet {
//            guard let selectionBoxViewModel = selectionBoxViewModel else {
//                return
//            }
//            setUpSubscribers()
//            self.selectionBoxPoint = selectionBoxViewModel.endPoint
//        }
//    }
//
//    init(id: UUID, selectionBoxPoint: CGPoint = .zero, annotationPoint: CGPoint = .zero) {
//        self.id = id
//        self.selectionBoxPoint = selectionBoxPoint
//        self.annotationPoint = annotationPoint
//        setUpSubscribers()
//    }
//
//    private func setUpSubscribers() {
//        annotationViewModel?.$positionDidChange.sink(receiveValue: { [weak self] _ in
//            guard let annotationViewModel = self?.annotationViewModel else {
//                return
//            }
//            self?.annotationPoint = annotationViewModel.origin
//        }).store(in: &cancellables)
//
//        selectionBoxViewModel?.$endPointDidChange.sink(receiveValue: { [weak self] _ in
//            guard let newEndPoint = self?.selectionBoxViewModel?.endPoint else {
//                return
//            }
//            self?.selectionBoxPoint = newEndPoint
//        }).store(in: &cancellables)
//    }
//
//    func didDelete() {
//        self.isRemoved = true
//    }
// }
//
// extension LinkLineViewModel {
//    private var minX: CGFloat {
//        min(selectionBoxPoint.x, annotationPoint.x)
//    }
//
//    private var minY: CGFloat {
//        min(selectionBoxPoint.y, annotationPoint.y)
//    }
//
//    private var maxX: CGFloat {
//        max(selectionBoxPoint.x, annotationPoint.x)
//    }
//
//    private var maxY: CGFloat {
//        max(selectionBoxPoint.y, annotationPoint.y)
//    }
//
//    private var width: CGFloat {
//        abs(annotationPoint.x - selectionBoxPoint.x)
//    }
//
//    private var height: CGFloat {
//        abs(annotationPoint.y - selectionBoxPoint.y)
//    }
//
//    var frame: CGRect {
//        CGRect(x: minX, y: minY, width: width, height: height)
//    }
// }
