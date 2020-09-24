//
//  ViewController.swift
//  MeasuringObjectUsingARKit
//
//  Created by Hassan on 16.9.2020.
//  Copyright © 2020 Hassan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    //MARK:- Variable
    var lines: [Line] = []
    var isMeasuring = false
    var vectorZero = SCNVector3()
    var startValue = SCNVector3()
    var endValue = SCNVector3()
    var currentLine: Line?
    var unit: DistanceUnit = .centimeter
    
    //MARK:- Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var imgTarget: UIImageView!
    @IBOutlet weak var lblMsg: UILabel!
    
    //MARK:- Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        btnAdd.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        btnAdd.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    //MARK:- Actions
    @IBAction func btnResetAction(_ sender: UIButton) {
        for line in lines {
            line.removeFromParentNode()
        }
        lines.removeAll()
    }
    
    @objc func buttonDown(_ sender: UIButton) {
        resetValues()
        isMeasuring = true
        imgTarget.tintColor = UIColor.green
       }

       @objc func buttonUp(_ sender: UIButton) {
        
        isMeasuring = false
        imgTarget.tintColor = UIColor.white
        if let line = currentLine {
            lines.append(line)
            currentLine = nil
        }
       }
    @IBAction func btnChangeUnitAcion(_ sender: UIButton) {
        
        let alertVC = UIAlertController(title: "Settings", message: "Please select distance unit options", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: DistanceUnit.centimeter.title, style: .default) { [weak self] _ in
            self?.unit = .centimeter
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.inch.title, style: .default) { [weak self] _ in
            self?.unit = .inch
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.meter.title, style: .default) { [weak self] _ in
            self?.unit = .meter
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    //MARK:- Functions
    fileprivate func detectObjects() {
        guard let worldPosition = sceneView.realWorldVector(screenPosition: view.center) else { return }
        if lines.isEmpty {
            lblMsg.text = "Press and hold the button and move the screen."
        }
        if isMeasuring {
        
            if startValue == vectorZero {
                startValue = worldPosition
                currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
            }
            endValue = worldPosition
            currentLine?.update(to: endValue)
            lblMsg.text = currentLine?.distance(to: endValue) ?? "Calculating…"
        }
    }
    
    fileprivate func resetValues() {
        isMeasuring = false
        startValue = SCNVector3()
        endValue =  SCNVector3()
    }
}

extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.detectObjects()
        }
    }
}

