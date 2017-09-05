import Foundation
import AsyncDisplayKit
import Display

private let cancelFont = Font.regular(17.0)

final class ChatTextInputAudioRecordingCancelIndicator: ASDisplayNode {
    private let cancel: () -> Void
    
    private let arrowNode: ASImageNode
    private let labelNode: TextNode
    private let cancelButton: HighlightableButtonNode
    
    private var isDisplayingCancel = false
    
    init(theme: PresentationTheme, strings: PresentationStrings, cancel: @escaping () -> Void) {
        self.cancel = cancel
        
        self.arrowNode = ASImageNode()
        self.arrowNode.isLayerBacked = true
        self.arrowNode.displayWithoutProcessing = true
        self.arrowNode.displaysAsynchronously = false
        self.arrowNode.image = PresentationResourcesChat.chatInputPanelMediaRecordingCancelArrowImage(theme)
        
        self.labelNode = TextNode()
        self.labelNode.isLayerBacked = true
        
        self.cancelButton = HighlightableButtonNode()
        self.cancelButton.setTitle(strings.Common_Cancel, with: cancelFont, with: theme.chat.inputPanel.panelControlAccentColor, for: [])
        self.cancelButton.alpha = 0.0
        
        super.init()
        
        self.addSubnode(self.arrowNode)
        self.addSubnode(self.labelNode)
        self.addSubnode(self.cancelButton)
        
        let makeLayout = TextNode.asyncLayout(self.labelNode)
        let (labelLayout, labelApply) = makeLayout(NSAttributedString(string: strings.Conversation_SlideToCancel, font: Font.regular(14.0), textColor: theme.chat.inputPanel.panelControlColor), nil, 1, .end, CGSize(width: 200.0, height: 100.0), .natural, nil, UIEdgeInsets())
        let _ = labelApply()
        
        let arrowSize = self.arrowNode.image?.size ?? CGSize()
        let height = max(arrowSize.height, labelLayout.size.height)
        self.frame = CGRect(origin: CGPoint(), size: CGSize(width: arrowSize.width + 12.0 + labelLayout.size.width, height: height))
        self.arrowNode.frame = CGRect(origin: CGPoint(x: 0.0, y: floor((height - arrowSize.height) / 2.0)), size: arrowSize)
        self.labelNode.frame = CGRect(origin: CGPoint(x: arrowSize.width + 6.0, y: floor((height - labelLayout.size.height) / 2.0) - UIScreenPixel), size: labelLayout.size)
        
        let cancelSize = self.cancelButton.measure(CGSize(width: 200.0, height: 100.0))
        self.cancelButton.frame = CGRect(origin: CGPoint(x: floor((self.bounds.size.width - cancelSize.width) / 2.0), y: floor((height - cancelSize.height) / 2.0)), size: cancelSize)
        
        self.cancelButton.addTarget(self, action: #selector(self.cancelPressed), forControlEvents: .touchUpInside)
    }
    
    func updateTheme(theme: PresentationTheme) {
        self.arrowNode.image = PresentationResourcesChat.chatInputPanelMediaRecordingCancelArrowImage(theme)
    }
    
    func updateIsDisplayingCancel(_ isDisplayingCancel: Bool, animated: Bool) {
        if self.isDisplayingCancel != isDisplayingCancel {
            self.isDisplayingCancel = isDisplayingCancel
            if isDisplayingCancel {
                self.arrowNode.alpha = 0.0
                self.labelNode.alpha = 0.0
                self.cancelButton.alpha = 1.0
                
                if animated {
                    self.arrowNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.25)
                    self.labelNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.25)
                    self.cancelButton.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
                }
            } else {
                self.arrowNode.alpha = 1.0
                self.labelNode.alpha = 1.0
                self.cancelButton.alpha = 0.0
                
                if animated {
                    self.arrowNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
                    self.labelNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
                    self.cancelButton.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.25)
                }
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.cancelButton.alpha.isZero, self.cancelButton.frame.insetBy(dx: -5.0, dy: -5.0).contains(point) {
            return self.cancelButton.view
        }
        return super.hitTest(point, with: event)
    }
    
    @objc func cancelPressed() {
        self.cancel()
    }
}
