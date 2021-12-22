//
//  XmppClient.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import UIKit
import XMPPFramework

protocol XmppConnectDelegate:AnyObject {
    func navigateToNextVc()
    func AuthenticationFailed()
}
class XmppClient: NSObject, XMPPStreamDelegate, XMPPMessageArchiveManagementDelegate,XMPPStreamManagementDelegate, XMPPRosterDelegate,XMPPMUCDelegate{
    static let shared = XmppClient()
   weak var XmppConnectDelegateObj:XmppConnectDelegate?
    public var xmppStream: XMPPStream?
    var xmppReconnect: XMPPReconnect?
    var xmppRoster: XMPPRoster?
    var recievedJid = String()
    var targetJid = ""
    var loggedUserName = ""
    var password: String? = nil
    public var xmppLastActivity: XMPPLastActivity?
    var xmppvCardStorage: XMPPvCardCoreDataStorage?
    let roomMemory = XMPPRoomMemoryStorage()
    public var xmppvCardAvatarModule: XMPPvCardAvatarModule?
    var xmppCapabilitiesStorage: XMPPCapabilitiesCoreDataStorage?
    var xmppMessageDeliveryRecipts: XMPPMessageDeliveryReceipts?
    var xmppCapabilities: XMPPCapabilities?
    var myJID = String()
    let bypassTLS: Bool = false
    var isXmppConnected = false
    var customCertEvaluation: Bool?
    //    var xmppuser : XMPPUserCoreDataStorageObject?
    var xmppRoom: XMPPRoom? = nil
    
    var chatDictionary = NSMutableDictionary()
    var presenceArr = NSMutableArray()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func checketwork() -> Bool {
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            return false
          
        case .online(.wwan):
            return true
            
        case .online(.wiFi):
           return true
        
        }
    }
    func connect(username:String,userpassword:String) -> Bool {
        
        if !xmppStream!.isDisconnected {
            return true
        }
        let accesstoken = userpassword
        myJID = "\(username)" + "@\(remoteConfig.Domain)"
        let myPassword = accesstoken
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        let resource = "ios_" + deviceId!
        xmppStream!.myJID = XMPPJID(string: myJID, resource: resource)
        password = myPassword
        xmppStream?.hostName = remoteConfig.Domain
        xmppStream?.hostPort = 5222
        do {
            try xmppStream?.connect(withTimeout: XMPPStreamTimeoutNone)
        } catch {
            
        }
        return xmppStream!.isConnected  // This prints false.
    }
    
    public func setupStream() {
        xmppStream = XMPPStream()
        
        #if !TARGET_IPHONE_SIMULATOR
        xmppStream!.enableBackgroundingOnSocket = true
        #endif
        xmppReconnect = XMPPReconnect()
        xmppRoster = nil
        let storage = XMPPRosterCoreDataStorage.sharedInstance()
        xmppRoster = XMPPRoster.init(rosterStorage: storage!, dispatchQueue: DispatchQueue.main)
        xmppRoster!.autoFetchRoster = true;
        xmppRoster!.autoAcceptKnownPresenceSubscriptionRequests = true;
        xmppvCardStorage = XMPPvCardCoreDataStorage()
        xmppCapabilitiesStorage = XMPPCapabilitiesCoreDataStorage.sharedInstance()
        xmppCapabilities = XMPPCapabilities(capabilitiesStorage: xmppCapabilitiesStorage!)
        xmppCapabilities!.autoFetchHashedCapabilities = true;
        xmppCapabilities!.autoFetchNonHashedCapabilities = false;
        xmppMessageDeliveryRecipts = XMPPMessageDeliveryReceipts(dispatchQueue: .main)
        xmppLastActivity = XMPPLastActivity()
        // Activate xmpp modules
        xmppReconnect!.activate(xmppStream!)
        xmppRoster!.activate(xmppStream!)
        xmppCapabilities!.activate(xmppStream!)
        xmppMessageDeliveryRecipts!.activate(xmppStream!)
        xmppLastActivity!.activate(xmppStream!)
        // Add ourself as a delegate to anything we may be interested in
        xmppStream!.addDelegate(self, delegateQueue: .main)
        xmppRoster!.addDelegate(self, delegateQueue: .main)
        customCertEvaluation = true;
    }
    
    
    func disconnect() {
        goOffline()
        xmppStream!.disconnect()
    }
    func goOnline() {
        
        let presence = XMPPPresence()
        let priority = XMLElement.element(withName: "priority", stringValue: "24") as? XMLElement
            presence.addChild(priority!)
        xmppStream!.send(presence)
        XmppConnectDelegateObj?.navigateToNextVc()
//        messageReceiveDelegate?.hideAlert()
        
    }
    
    func goOffline() {
        let presence = XMPPPresence(type: "DND")
        xmppStream!.send(presence)
    }
    func fetchFreind(targetid:String){
        
        let query = XMLElement(name: "query", xmlns: "jabber:iq:last")
        let streamUUID = xmppStream?.generateUUID
        let iq = XMPPIQ(type: "get", to: XMPPJID(string: recievedJid) , elementID: streamUUID , child: query)
        xmppStream?.send(iq)
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        let presenceType = presence.type
        let myUsername = sender.myJID?.user
        let presenceFromUser = presence.from?.user
        
        if presenceFromUser != myUsername {
            
            if presenceType == "available" {
                
            } else if presenceType == "unavailable" {
                
            }
        }
    }
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        
        return false
    }

    func xmppStreamDidConnect(_ sender: XMPPStream?) {
        isXmppConnected = true
        var _: Error? = nil
        let auth = XMPPPlainAuthentication(stream: xmppStream!, password: password!)
        do {
            try xmppStream?.authenticate(auth)
        } catch {
            print("error")
        }
    }
    
    func xmppStream(_ sender: XMPPStream?, willSecureWithSettings settings: inout [AnyHashable : Any]) {
        
        let expectedCertName = xmppStream!.myJID!.domain
        if expectedCertName != "" {
            settings[kCFStreamSSLPeerName as String] = expectedCertName
        }
        
        if customCertEvaluation! {
            settings[GCDAsyncSocketManuallyEvaluateTrust] = NSNumber(value: true)
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print(error)
        XmppConnectDelegateObj?.AuthenticationFailed()
    }
   
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        goOnline()
        configureStreamManagement()
    }
    
    
    

    func xmppRoom(_ sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
        let newForm = configForm.copy() as! DDXMLElement
        for field in newForm.elements(forName: "field") {
            if let _var = field.attributeStringValue(forName: "var") {
                switch _var {
                case "muc#roomconfig_persistentroom":
                    field.remove(forName: "value")
                    field.addChild(DDXMLElement(name: "value", numberValue: 1))
                case "muc#roomconfig_membersonly":
                    field.remove(forName: "value")
                    field.addChild(DDXMLElement(name: "value", numberValue: 1))
                // other configures
                default:
                    break
                }
                
            }
            
        }
        
        sender.configureRoom(usingOptions: newForm)
    }
    
    func configureStreamManagement() {
        let xmppSMMS = XMPPStreamManagementMemoryStorage()
        let xmppStreamManagement = XMPPStreamManagement(storage: xmppSMMS, dispatchQueue: DispatchQueue.main)
        xmppStreamManagement.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppStreamManagement.activate(xmppStream!)
        xmppStreamManagement.autoResume = true
        xmppStreamManagement.ackResponseDelay = 0.2
        xmppStreamManagement.requestAck()
        xmppStreamManagement.automaticallyRequestAcks(afterStanzaCount: 1, orTimeout: 1)
        xmppStreamManagement.automaticallySendAcks(afterStanzaCount: 1, orTimeout: 1)
        xmppStreamManagement.enable(withResumption: true, maxTimeout: 0)
        xmppStreamManagement.sendAck()
        xmppStream!.register(xmppStreamManagement)
        xmppMessageDeliveryRecipts = XMPPMessageDeliveryReceipts(dispatchQueue: DispatchQueue.main)

        xmppMessageDeliveryRecipts?.activate(xmppStream!)
    }
    

    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        let presenceType = presence.type
        _ = presence.childCount
        let username = sender.myJID?.user
        let presenceFromUser = presence.from?.user
            
            if presenceFromUser != username  {
                if presenceType == "available" {
                    if !presenceArr.contains(presenceFromUser!)
                    {
                      presenceArr.add(presenceFromUser!)
                    }
                }
                else if presenceType == "subscribe" {
                    self.xmppRoster!.subscribePresence(toUser: (presence.from)!)
                }
               
            }
            
        }
    func managedObjectContext_capabilities() -> NSManagedObjectContext? {
        return xmppCapabilitiesStorage?.mainThreadManagedObjectContext
    }
    
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didReceiveMAMMessage message: XMPPMessage) {
        if let xmppMessage = message.mamResult?.forwardedMessage {
            _ = xmppMessage.body
        }
    }

    func            sendingMessageToXmpp(Msg:String,type:String,recievedJid:String,messageid:String){
        

        let msg = XMPPMessage(type: type, to: XMPPJID(string: recievedJid), elementID: messageid)
        msg.addBody(Msg)
        xmppStream!.send(msg)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {



    }
    
   
    func xmppRoomDidCreate(sender: XMPPRoom!) {
        
        sender.fetchConfigurationForm()
        
    }
    
    func xmppRoom(sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
        
        let newForm = configForm.copy() as! DDXMLElement
        
        for field in newForm.elements(forName: "field") {
            
            if let _var = field.attributeStringValue(forName: "var") {
                
                switch _var {
                case "muc#roomconfig_persistentroom":
                    field.remove(forName: "value")
                    field.addChild(DDXMLElement(name: "value", numberValue: 1))
                    
                case "muc#roomconfig_membersonly":
                    field.remove(forName: "value")
                    field.addChild(DDXMLElement(name: "value", numberValue: 1))
                    
                // other configures
                default:
                    break
                }
                
                
                
            }
            
        }
        
        sender.configureRoom(usingOptions: newForm)
    }
    
    func xmppStreamManagement(_ sender: XMPPStreamManagement, didReceiveAckForStanzaIds stanzaIds: [Any]) {
       

              if let messageIds = stanzaIds as? [String] {
                for id in messageIds {
        
                  // TODO: Custom code goes here to change the message status
                }
              }
            }
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        print("message sent")
       
            
    }
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        print("message sent failed")
        print("error for failed msg \(error.localizedDescription)")
        if UserDefaults.standard.object(forKey: "firebaseanalytics") as! Bool
        {

        }

    }
    
   
    
}
