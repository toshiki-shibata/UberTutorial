//
//  HomeController.swift
//  UberTutorial
//
//  Created by minmin on 2021/10/07.
//

import UIKit
import Firebase
import MapKit

class HomeController: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()

    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ckeckIfUserIsLoggedIn()
        enableLocationServices()
    }
    // MARK: - API
    func ckeckIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureUI()
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("ログアウト失敗")
        }
    }

    // MARK: - Helpers

    func configureUI() {
        configureMapView()
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self

        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }

    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame

        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }

    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            print("テーブルが現れた")
        }

    }
}

// MARK: - Location Services
extension HomeController: CLLocationManagerDelegate {
    func enableLocationServices() {
        locationManager.delegate = self

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("決定されてない")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("いつでもOK")
            locationManager.startUpdatingHeading()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("ユーザーが許可したときだけOK")
            locationManager.requestAlwaysAuthorization()

        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }


}


// MARK: - LocationInputActivationViewDelegate

extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
configureLocationInputView()
    }
}

// MARK: - LocationInputActivationViewDelegate

extension HomeController: LocationInputViewDelegate {
    func dissmissLocationInputView() {
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }

    }


}