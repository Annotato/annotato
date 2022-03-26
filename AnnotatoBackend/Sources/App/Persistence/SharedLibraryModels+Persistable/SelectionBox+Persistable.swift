import CoreGraphics
import Foundation
import AnnotatoSharedLibrary

extension SelectionBox: Persistable {
    static func fromManagedEntity(_ managedEntity: SelectionBoxEntity) -> Self {
        Self(
            startPoint: CGPoint(x: managedEntity.startPointX, y: managedEntity.startPointY),
            endPoint: CGPoint(x: managedEntity.endPointX, y: managedEntity.endPointY),
            id: managedEntity.id
        )
    }
}
