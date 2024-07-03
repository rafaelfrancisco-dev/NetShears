//
//  NetShears.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import UIKit
import SwiftUI

@globalActor public actor NetShearsActor: GlobalActor {
    public static let shared = NetShearsActor()
}

public protocol BodyExporterDelegate: AnyObject, Sendable {
    func netShears(exportResponseBodyFor request: NetShearsRequestModel) -> BodyExportType
    func netShears(exportRequestBodyFor request: NetShearsRequestModel) -> BodyExportType
}

public extension BodyExporterDelegate {
    func netShears(exportResponseBodyFor request: NetShearsRequestModel) -> BodyExportType { .default }
    func netShears(exportRequestBodyFor request: NetShearsRequestModel) -> BodyExportType { .default }
}

public protocol TaskProgressDelegate: AnyObject {
    func task(_ url: URL, didRecieveProgress progress: Progress)
}

@NetShearsActor
public final class NetShears: NSObject {
    public static let shared = NetShears()
    
    public weak var bodyExportDelegate: BodyExporterDelegate?
    public weak var taskProgressDelegate: TaskProgressDelegate?
    
    internal var loggerEnable = false
    internal var interceptorEnable = false
    internal var listenerEnable = false
    internal var swizzled = false
    let networkRequestInterceptor = NetworkRequestInterceptor()

    public var ignore: Ignore = .disbaled

    lazy var config: NetworkInterceptorConfig = {
        var savedModifiers = [Modifier]().retrieveFromDisk()
        return NetworkInterceptorConfig(modifiers: savedModifiers)
    }()

    private func checkSwizzling() {
        if swizzled == false {
            self.networkRequestInterceptor.swizzleProtocolClasses()
            swizzled = true
        }
    }
    
    public func startInterceptor() async {
        await self.networkRequestInterceptor.startInterceptor()
        checkSwizzling()
    }

    public func stopInterceptor() {
        self.networkRequestInterceptor.stopInterceptor()
        checkSwizzling()
    }

    public func startLogger() {
        self.networkRequestInterceptor.startLogger()
        checkSwizzling()
    }

    public func stopLogger() {
        self.networkRequestInterceptor.stopLogger()
        checkSwizzling()
    }

    public func startListener() {
        self.networkRequestInterceptor.startListener()
        checkSwizzling()
    }

    public func stopListener() {
        self.networkRequestInterceptor.stopListener()
        checkSwizzling()
    }
    
    public func modify(modifier: Modifier) {
        config.addModifier(modifier: modifier)
    }
    
    public func modifiedList() -> [Modifier] {
        return config.modifiers
    }
    
    public func removeModifier(at index: Int){
        return config.removeModifier(at: index)
    }

    public func presentNetworkMonitor() async {
        let storyboard = await UIStoryboard.NetShearsStoryBoard
        
        if let initialVC = await storyboard.instantiateInitialViewController() {
            await MainActor.run {
                initialVC.modalPresentationStyle = .fullScreen
                
                Task {
                    await ((initialVC as? UINavigationController)?.topViewController as? RequestsViewController)?.delegate = bodyExportDelegate
                }
            }
            
            await UIViewController.currentViewController()?.present(initialVC, animated: true, completion: nil)
        }
    }
    
    @available(iOS 13.0, *)
    public func view() -> some View {
        NetshearsFlowView()
    }

    public func addCustomRequest(url: String,
                                 host: String,
                                 method: String,
                                 requestObject: Data?,
                                 responseObject: Data?,
                                 success: Bool,
                                 statusCode: Int,
                                 statusMessage: String?,
                                 duration: Double?,
                                 scheme: String,
                                 requestHeaders: [String: String]?,
                                 responseHeaders: [String: String]?) async {
        let request = NetShearsRequestModel(url: url,
                                            host: host,
                                            method: method,
                                            requestObject: requestObject,
                                            responseObject: responseObject,
                                            success: success,
                                            statusCode: statusCode,
                                            duration: duration,
                                            scheme: scheme,
                                            requestHeaders: requestHeaders,
                                            responseHeaders: responseHeaders,
                                            isFinished: true)
        if loggerEnable {
            await RequestStorage.shared.newRequestArrived(request)
        }

        await RequestBroadcast.shared.newRequestArrived(request)
    }

    public func addGRPC(url: String,
                        host: String,
                        method: String,
                        requestObject: Data?,
                        responseObject: Data?,
                        success: Bool,
                        statusCode: Int,
                        statusMessage: String?,
                        duration: Double?,
                        HPACKHeadersRequest: [String: String]?,
                        HPACKHeadersResponse: [String: String]?) async {
        await addCustomRequest(url: url, host: host, method: method, requestObject: requestObject, responseObject: responseObject, success: success, statusCode: statusCode, statusMessage: statusMessage, duration: duration, scheme: "gRPC", requestHeaders: HPACKHeadersRequest, responseHeaders: HPACKHeadersResponse)
    }
}
