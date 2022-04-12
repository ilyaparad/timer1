//
//  ViewController.swift
//  timer1
//
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties -
    private lazy var shapeLayer = CAShapeLayer()
    private lazy var trackLayer = CAShapeLayer()
    private lazy var timer = Timer()
    private lazy var durationTimer = constants.workCount * constants.valueForConvert
    private lazy var isStarted = false
    private lazy var isWorkTime = true
    private lazy var currentOtherColor = constants.workOtherColor
    private lazy var currentTrackLayerColor = constants.workTrackLayerColor
    private lazy var currentShapeLayerColor = constants.workShapeLayerColor
    private lazy var firstStart = true

    private lazy var buttonStartStop: UIButton = {
        var buttonStartStop = UIButton(type: .system)
        buttonStartStop.addTarget(self, action: #selector(buttonStartStopAction), for: .touchUpInside)
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 70)
        let image = UIImage(systemName: "play", withConfiguration: symbolConfiguration)
        if image != nil {
            buttonStartStop.setImage(image?.withTintColor(constants.workOtherColor, renderingMode: .alwaysOriginal), for: .normal)
        }
        buttonStartStop.isEnabled = true

        return buttonStartStop
    }()

    private lazy var labelTimer: UILabel = {
        var labelTimer = UILabel()
        labelTimer.text = timerLabelText(time: Double(constants.workCount * constants.valueForConvert))
        labelTimer.textColor = constants.workOtherColor
        labelTimer.font = labelTimer.font.withSize(90)
        labelTimer.sizeToFit()
        return labelTimer
    }()

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHyerarchy()
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createCircleWithAnimation()
    }

    // MARK: - Settings

    private func setupHyerarchy() {
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
        view.addSubview(buttonStartStop)
        view.addSubview(labelTimer)
    }

    private func setupLayout() {
        labelTimer.translatesAutoresizingMaskIntoConstraints = false
        labelTimer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelTimer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30).isActive = true

        buttonStartStop.translatesAutoresizingMaskIntoConstraints = false
        buttonStartStop.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonStartStop.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80).isActive = true
    }

    private func createCircleWithAnimation() {
        let center = view.center
        let radius = min(view.frame.width, view.frame.height) / 2.2
        let startAngle = 3 / 2 * CGFloat.pi
        let endAngle = startAngle - (2 * CGFloat.pi)

        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = currentTrackLayerColor.cgColor
        trackLayer.lineWidth = constants.lineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round

        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = currentShapeLayerColor.cgColor
        shapeLayer.lineWidth = constants.lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeEnd = 1
    }

    private func timerLabelText(time: Double) -> String {
        let convertedTime = Int(time / constants.valueForConvert) + (firstStart ? 0 : 1)
        firstStart = false
        let minutes = Int(convertedTime) / 60 % 60
        let seconds = Int(convertedTime) % 60

        return String(format:"%02i:%02i", minutes, seconds)
    }

    private func setupColors() {
        currentTrackLayerColor = isWorkTime ? constants.workTrackLayerColor : constants.restTrackLayerColor
        currentShapeLayerColor = isWorkTime ? constants.workShapeLayerColor : constants.restShapeLayerColor
        let currentOtherColor = isWorkTime ? constants.workOtherColor : constants.restOtherColor

        trackLayer.strokeColor = currentTrackLayerColor.cgColor
        shapeLayer.strokeColor = currentShapeLayerColor.cgColor
        labelTimer.textColor = currentOtherColor
    }

    private func setButtonImage() {
        let currentColor = isWorkTime ? constants.workOtherColor : constants.restOtherColor
        let name = isStarted ? "pause" : "play"

        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 60)
        let image = UIImage(systemName: name, withConfiguration: symbolConfiguration)
        if image != nil {
            buttonStartStop.setImage(image?.withTintColor(currentColor, renderingMode: .alwaysOriginal), for: .normal)
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1 / constants.valueForConvert, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    private func startAnimationAndTimer() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.speed = 1.0
        basicAnimation.toValue = 0
        basicAnimation.duration = CFTimeInterval(durationTimer / constants.valueForConvert)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = true
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
        startTimer()
    }
    
    private func pauseAnimationAndTimer() {
        let pauseTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pauseTime
        timer.invalidate()
    }

    private func resumeAnimationAndTimer() {
        startTimer()
        let pausedTime = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        let timeSincePaused = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePaused
    }

    private func getDuration() -> Double {
        return (isWorkTime ? constants.workCount : constants.restCount) * constants.valueForConvert
    }

    //MARK: - Actions

    @objc private func buttonStartStopAction() {
        isStarted = !isStarted
        setButtonImage()

        if isStarted && durationTimer == (constants.workCount * constants.valueForConvert) {
            startAnimationAndTimer()
        } else if !isStarted {
            pauseAnimationAndTimer()
        } else if labelTimer.text == timerLabelText(time: durationTimer) {
            resumeAnimationAndTimer()
        }
    }

    @objc private func timerAction() {
        if durationTimer == 0 {
            timer.invalidate()
            isWorkTime = !isWorkTime

            setButtonImage()
            setupColors()
            durationTimer = getDuration()
            startAnimationAndTimer()
        }
        durationTimer -= 1
        labelTimer.text = timerLabelText(time: durationTimer)
    }
}

// MARK: - Constants

extension ViewController {

    enum constants {
        static let workTrackLayerColor = UIColor(displayP3Red: 255/255, green: 49/255, blue: 0/255, alpha: 0.2)
        static let workShapeLayerColor = UIColor(displayP3Red: 255/255, green: 49/255, blue: 0/255, alpha: 0.45)
        static let workOtherColor = UIColor(displayP3Red: 255/255, green: 49/255, blue: 0/255, alpha: 0.6)
        static let restTrackLayerColor = UIColor(displayP3Red: 124/255, green: 194/255, blue: 166/255, alpha: 0.4)
        static let restShapeLayerColor = UIColor(displayP3Red: 124/255, green: 194/255, blue: 166/255, alpha: 0.7)
        static let restOtherColor = UIColor(displayP3Red: 124/255, green: 194/255, blue: 166/255, alpha: 0.9)
        static let workCount = 25.00
        static let restCount = 5.00
        static let valueForConvert = 1000.0
        static let lineWidth = CGFloat(10)
    }
}
