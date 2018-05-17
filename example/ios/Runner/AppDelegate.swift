import UIKit
import Flutter
import Rave

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, RavePaymentManagerDelegate {
    var _result: FlutterResult!
    var RAVEPAY_CHANNEL = "ng.i.handikraft/flutter_ravepay_local"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let controller = self.window.rootViewController
        let channel = FlutterMethodChannel(name: RAVEPAY_CHANNEL, binaryMessenger: controller as! FlutterBinaryMessenger);

        channel.setMethodCallHandler(handle)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("iOS => call \(call.method)")
        _result = result
        switch (call.method) {
        case "chargeCard":
            chargeCard(call)
        default:
            _result(FlutterMethodNotImplemented)
        }
    }

    public func chargeCard(_ call: FlutterMethodCall) {
        let config = RavePayConfig.sharedConfig()
        
        let options = call.arguments as! [String: Any]
        let amount = options["amount"] as! String
        let country = options["country"] as! String
        let currency = options["currency"] as! String
        let email = options["email"] as! String
        let isStaging = options["isStaging"]
        let narration = options["narration"] as! String
    //        let useAccounts = options["useAccounts"] as! Bool
    //        let useCards = options["useCards"] as! Bool
        let useSave = options["useSave"] as! Bool
        let txRef = options["txRef"] as! String
    //        let style = options["style"] as! String
        let publicKey = options["publicKey"] as! String
        let secretKey = options["secretKey"] as! String

        config.publicKey = publicKey
        config.secretKey = secretKey
        config.isStaging = isStaging != nil ? isStaging as! Bool : true

        let raveMgr = RavePayManager()
        raveMgr.email = email
        raveMgr.amount = amount
        raveMgr.transcationRef = txRef
        raveMgr.country = country
        raveMgr.currencyCode = currency
        raveMgr.savedCardsAllow = useSave
        raveMgr.delegate = self
        raveMgr.narration = narration
        raveMgr.supportedPaymentMethods = [.card]
    //        raveMgr.supportedPaymentMethods = [.card,.account] // Choose supported payment channel allowed

        raveMgr.show(withController:self.window.rootViewController as! UIViewController)
    }

    func ravePaymentManagerDidCancel(_ ravePaymentManager: RavePayManager) {
        _result(["status": "CANCELLED"]);
    }

    func ravePaymentManager(_ ravePaymentManager: RavePayManager, didSucceedPaymentWithResult result: [String : AnyObject]) {
        _result(["status": "SUCCESS", "data": result]);
    }

    func ravePaymentManager(_ ravePaymentManager: RavePayManager, didFailPaymentWithResult result: [String : AnyObject]) {
        _result(["status": "ERROR", "data": result]);
    }
}
