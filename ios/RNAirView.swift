import Foundation
import UIKit
import AVFoundation
import AVKit

@objc(RNAirView) 
public class RNAirView: UIView {
    var routePickerView: AVRoutePickerView?
    var source: Dictionary<String, String>?
    
    // Track the parent size to know when to resize
    private var lastSize: CGSize = .zero

    @objc public func setSource(_ source: Dictionary<String, String>) {
        self.source = source
        
        configureRoutePickerView(tintColor: UIColor.white)
    }
    
    // Configure the AVRoutePickerView
    private func configureRoutePickerView(tintColor: UIColor) {
        if #available(iOS 11.0, *), let picker = routePickerView {
            picker.tintColor = tintColor
            picker.activeTintColor = UIColor.systemBlue
            
            // Force layout and then resize icon
            layoutIfNeeded()
        }
    }
    
    // Recursively find the UIButton in subviews
    private func findButton(in view: UIView) -> UIButton? {
        if let button = view as? UIButton {
            return button
        }
        
        for subview in view.subviews {
            if let button = findButton(in: subview) {
                return button
            }
        }
        
        return nil
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let currentSize = self.bounds.size
        
        // Only update if this is first layout or size changed
        if routePickerView == nil {
            // Setup audio session for AirPlay
            setupAudioSession()
            setupRoutePickerView()
            lastSize = currentSize
        } else if currentSize != lastSize {
            // Update the view frame when parent size changes
            updateViewFrame()
            lastSize = currentSize
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            print("Error activating audio session: \(error)")
        }
    }
    
    private func updateViewFrame() {
        if #available(iOS 11.0, *), let picker = routePickerView {
            picker.frame = self.bounds
            picker.setNeedsLayout()
            picker.layoutIfNeeded()
        }
    }
    
    private func getViewFrame() -> CGRect {
        // AVRoutePickerView will fill the parent view
        if self.bounds.size.width > 0 && self.bounds.size.height > 0 {
            return self.bounds
        } else {
            // Use a reasonable default size if parent has no size yet
            let minSize = CGSize(width: 44, height: 44)
            let frame = CGRect(origin: .zero, size: minSize)
            self.frame = frame
            return frame
        }
    }

    private func setupRoutePickerView() {
        if #available(iOS 11.0, *) {
            let viewFrame = getViewFrame()
            let picker = AVRoutePickerView(frame: viewFrame)
            
            // Set defaults
            picker.backgroundColor = UIColor.clear
            
            self.routePickerView = picker
            addSubview(picker)
            
            // If user provided a custom tint color
            if let source = self.source {
                setSource(source)
            } else {
                // Default tint
                picker.tintColor = UIColor.white
                picker.activeTintColor = UIColor.systemBlue
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set background color to transparent
        self.backgroundColor = UIColor.clear
        
        // Setup audio session for AirPlay
        setupAudioSession()
    }

    required init?(coder aDecoder: NSCoder) { 
        fatalError("init(coder:) has not been implemented") 
    }
}
