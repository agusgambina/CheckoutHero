//
//  ViewsScannerLabelCameraView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 7/3/26.
//

import SwiftUI
import AVFoundation
import UIKit

/// Full-screen camera view with a bounding-box guide for aligning a price label.
/// Captures a still photo and returns it via `onCapture`.
struct LabelCameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> LabelCameraViewController {
        let controller = LabelCameraViewController()
        controller.onCapture = onCapture
        controller.onCancel = onCancel
        return controller
    }

    func updateUIViewController(_ uiViewController: LabelCameraViewController, context: Context) {}
}

final class LabelCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var onCapture: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "checkouthero.label-camera.session")

    private lazy var boundingBox: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemTeal.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 12
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString(
            "scanner_align_price_tag",
            value: "Align the price tag inside the frame",
            comment: ""
        )
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.6
        label.layer.shadowRadius = 3
        label.layer.shadowOffset = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 36
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.systemTeal
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCapture), for: .touchUpInside)
        button.accessibilityLabel = NSLocalizedString("scanner_capture", value: "Capture", comment: "")
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("cancel", value: "Cancel", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        configureOverlay()

        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    // MARK: - Setup

    private func configureOverlay() {
        view.addSubview(boundingBox)
        view.addSubview(instructionsLabel)
        view.addSubview(captureButton)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            boundingBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            boundingBox.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            boundingBox.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            boundingBox.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),

            instructionsLabel.bottomAnchor.constraint(equalTo: boundingBox.topAnchor, constant: -16),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            captureButton.widthAnchor.constraint(equalToConstant: 72),
            captureButton.heightAnchor.constraint(equalToConstant: 72),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let layer = AVCaptureVideoPreviewLayer(session: self.session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = self.view.bounds
            self.view.layer.insertSublayer(layer, at: 0)
            self.previewLayer = layer
        }

        session.startRunning()
    }

    // MARK: - Actions

    @objc private func handleCapture() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc private func handleCancel() {
        onCancel?()
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.onCapture?(image)
        }
    }
}
