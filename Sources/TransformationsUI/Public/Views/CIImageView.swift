//
//  CIImageView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 22/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import MetalKit
import CoreImage

public class CIImageView: MTKView {
    // MARK: - Public Properties

    @objc public dynamic weak var image: CIImage? {
        didSet {
            guard let image = image else { return }

            bounds = CGRect(origin: .zero, size: image.extent.size)
            frame = CGRect(origin: .zero, size: frame.size)

            if drawableSize != image.extent.size {
                drawableSize = image.extent.size
            }

            setNeedsDisplay()
        }
    }

    // MARK: - Private Properties

    private lazy var commandQueue: MTLCommandQueue? = {
        return device!.makeCommandQueue()
    }()

    private lazy var ciContext: CIContext = {
        let contextOptions: [CIContextOption : Any] = [.workingFormat : CIFormat.RGBA8]

        if #available(iOS 13.0, *) {
            return CIContext(mtlCommandQueue: commandQueue!, options: contextOptions)
        } else {
            return CIContext(mtlDevice: device!, options: contextOptions)
        }
    }()

    // MARK: - Lifecycle

    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)

        guard super.device != nil else {
            fatalError("Device doesn't support Metal")
        }

        contentScaleFactor = 1
        autoResizeDrawable = false
        isPaused = true
        enableSetNeedsDisplay = true
        framebufferOnly = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Draw Overrides

    public override func draw(_ rect: CGRect) {
        guard
            drawableSize.width > 0, drawableSize.height > 0,
            let image = image,
            let commandBuffer = commandQueue?.makeCommandBuffer(),
            let currentDrawable = currentDrawable
        else {
            return
        }

        let destination = CIRenderDestination(mtlTexture: currentDrawable.texture, commandBuffer: commandBuffer)

        destination.isFlipped = true

        _ = try? ciContext.startTask(toRender: image, from: image.extent, to: destination, at: .zero)

        #if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
        commandBuffer.present(currentDrawable)
        #else
        commandBuffer.present(currentDrawable, afterMinimumDuration: 1 / CFTimeInterval(preferredFramesPerSecond))
        #endif

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
