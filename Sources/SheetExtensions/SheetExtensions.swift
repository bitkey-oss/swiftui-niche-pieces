import SwiftUI
import UIKit
import CasePaths
import SwiftUINavigation

@available(iOS 15.0, *)
extension View {
    
    /// Presents a sheet included Detent using the given item as a data source for the sheet’s content.
    /// - Parameters:
    ///   - item: A binding to an optional source of truth for the sheet. When item is non-nil, the system passes the item’s content to the modifier’s closure. You display this content in a sheet that you create that the system displays to the user. If item changes, the system dismisses the sheet and replaces it with a new one using the same process.
    ///   - detents: An object that represents a height where a sheet naturally rests.
    ///   - onDismiss: The closure to execute when dismissing the sheet.
    ///   - content: A closure returning the content of the sheet.
    @available(iOS, introduced: 15.0, deprecated: 10000.0, message: "use sheet(isPresented:) with .presentationDetents(_:) instead")
    public func sheet<Value, InnerView: View>(
        item: Binding<Value?>,
        detents: [UISheetPresentationController.Detent],
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Binding<Value>) -> InnerView
    ) -> some View {
        self.background {
            DetentSheetView(isPresented: item.isPresent(), detents: detents, onDismiss: onDismiss) {
                Binding(unwrapping: item).map(content)
            }
        }
    }
    
    /// Presents a sheet included Detent using the given item as a data source for the sheet’s content.
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether to present the sheet that you create in the modifier’s content closure.
    ///   - detents: An object that represents a height where a sheet naturally rests.
    ///   - onDismiss: The closure to execute when dismissing the sheet.
    ///   - content: A closure returning the content of the sheet.
    @available(iOS, introduced: 15.0, deprecated: 10000.0, message: "use sheet(isPresented:) with .presentationDetents(_:) instead")
    public func sheet<InnerView: View>(
        isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent],
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> InnerView
    ) -> some View {
        self.background {
            DetentSheetView(isPresented: isPresented, detents: detents, onDismiss: onDismiss, content: content)
        }
    }
    
#if canImport(CasePaths)
    /// Presents a sheet included Detent using the given item as a data source for the sheet’s content.
    /// - Parameters:
    ///   - unwrapping: A binding of the sheet's options to the truth source; if it matches case, the system passes the contents of unwrapping to the modifier's closure. This content will appear in the sheet that the system displays to the user; if case changes, the system destroys the sheet and replaces it with a new sheet in the same process.
    ///   - case: Destination with the same enum as unwrapping if associated value is exists.
    ///   - detents: An object that represents a height where a sheet naturally rests.
    ///   - onDismiss: The closure to execute when dismissing the sheet.
    ///   - content: A closure returning the content of the sheet.
    @available(iOS, introduced: 15.0, deprecated: 10000.0, message: "use sheet(isPresented:) with .presentationDetents(_:) instead")
    public func sheet<Enum, Value, InnerView: View>(
        unwrapping `enum`: Binding<Enum?>,
        case casePath: CasePath<Enum, Value>,
        detents: [UISheetPresentationController.Detent],
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Binding<Value>) -> InnerView
    ) -> some View {
        self.sheet(
            item: `enum`.case(casePath),
            detents: detents,
            onDismiss: onDismiss,
            content: content
        )
    }
    
    /// Presents a sheet included Detent using the given item as a data source for the sheet’s content.
    /// - Parameters:
    ///   - unwrapping: A binding of the sheet's options to the truth source. if a match is found with case and no value exists for that case, the system passes the match to the modifier's closure. no value is passed to View and the system displays the sheet. if case is changed, the system discards the sheet and replaces it with a new sheet using the same process.
    ///   - case: Destination with the same enum as unwrapping if associated value is void.
    ///   - detents: An object that represents a height where a sheet naturally rests.
    ///   - onDismiss: The closure to execute when dismissing the sheet.
    ///   - content: A closure returning the content of the sheet.
    @available(iOS, introduced: 15.0, deprecated: 10000.0, message: "use sheet(isPresented:) with .presentationDetents(_:) instead")
    public func sheet<Enum, InnerView: View>(
        unwrapping `enum`: Binding<Enum?>,
        case casePath: CasePath<Enum, Void>,
        detents: [UISheetPresentationController.Detent],
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> InnerView
    ) -> some View {
        self.sheet(
            isPresented: `enum`.isPresent(casePath),
            detents: detents,
            onDismiss: onDismiss,
            content: content
        )
    }
#endif
}

@available(iOS 15.0, *)
private struct DetentSheetView<InnerView: View>: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    let detents: [UISheetPresentationController.Detent]
    let content: () -> InnerView
    let onDismiss: () -> Void
    
    init(isPresented: Binding<Bool>, detents: [UISheetPresentationController.Detent], onDismiss: @escaping () -> Void, content: @escaping () -> InnerView) {
        self._isPresented = isPresented
        self.detents = detents
        self.content = content
        self.onDismiss = onDismiss
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(
        _ viewController: UIViewController,
        context: Context
    ) {
        switch (isPresented, viewController.presentedViewController) {
        case (true, nil):
            let sheetController = context.coordinator.controller
            sheetController.presentationController!.delegate = context.coordinator
            viewController.present(sheetController, animated: true) {
                context.coordinator.presenting = true
            }
        case (false, .some):
            if context.coordinator.presenting {
                context.coordinator.presenting = false
                viewController.dismiss(animated: true, completion: onDismiss)
            }
        default:
            break
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            parent: self,
            presenting: false,
            controller: CustomHostingController(rootView: content(), detents: detents)
        )
    }
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: DetentSheetView
        var presenting: Bool
        var controller: CustomHostingController<InnerView>
        
        init(parent: DetentSheetView, presenting: Bool, controller: CustomHostingController<InnerView>) {
            self.parent = parent
            self.presenting = presenting
            self.controller = controller
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.isPresented = false
            presenting = false
            parent.onDismiss()
        }
    }
    
    class CustomHostingController<HostingView: View>: UIHostingController<HostingView> {
        
        init(rootView: HostingView, detents: [UISheetPresentationController.Detent]) {
            self.detents = detents
            super.init(rootView: rootView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("don't use coder initialize")
        }
        
        var detents: [UISheetPresentationController.Detent]
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let sheet = self.sheetPresentationController {
                sheet.detents = detents
                sheet.prefersGrabberVisible = true
            }
        }
    }
}
