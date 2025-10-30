//
//  ApiClient.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 18.10.25.
//

import Foundation
import OSLog

class OneTimeKeyBundle: Codable{
    var opk: [String]
    var opqk: [String]
    
    init(opk: [String], opqk: [String]) {
        self.opk = opk
        self.opqk = opqk
    }
}

class KeyBundle: Codable{
    var regId:UInt32
    var ik: String
    var spk: String
    var opk: [String]
    var spkSignature : String
    var spkID:String
    var PQSPK: String
    var PQSPKID: String
    var PQSPKSignature: String
    var OPQK: [String]
    
    init(regId: UInt32, ik: String, spk: String, opk: [String], spkSignature: String, spkID: String, PQSPK: String, PQSPKID: String, PQSPKSignature: String, OPQK: [String]) {
        self.regId = regId
        self.ik = ik
        self.spk = spk
        self.opk = opk
        self.spkSignature = spkSignature
        self.spkID = spkID
        self.PQSPK = PQSPK
        self.PQSPKID = PQSPKID
        self.PQSPKSignature = PQSPKSignature
        self.OPQK = OPQK
    }
}

func updateOneTimePreKeys(oneTimePreKeys:[String], kyberPreKeys: [String]){
    var request = URLRequest(url: URL(string:"https://consumer.test.sekretess.io/api/v1/consumers/onetimekeystores")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let oneTimeKeyBundle = OneTimeKeyBundle(opk: oneTimePreKeys, opqk: kyberPreKeys)
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    encoder.keyEncodingStrategy = .useDefaultKeys
    request.httpBody = try?encoder.encode(oneTimePreKeys)
    let task = URLSession.shared.dataTask(with: request){
        data, response, error in
        if let error = error{
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else{
            return
        }
        
        guard let data = data else{
            return
        }
    }
    
    task.resume()
}

func upsertKeys(keyBundle: KeyBundle, bearerToken: String, callback: @escaping () -> Void){
    var request = URLRequest(url:URL(string:"https://consumer.test.sekretess.io/api/v1/consumers/keystores")!)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    encoder.keyEncodingStrategy = .useDefaultKeys
    let jsonBody = try?encoder.encode(keyBundle)
    let logParts = String(bytes:Data(bytes:jsonBody!), encoding: .utf8)?.split(by: 3096)
    logParts!.forEach{str in
        os_log("%s", str)
    }
    
    request.httpBody = jsonBody
    let base64Body = jsonBody?.base64EncodedString()
    dump(request, maxDepth: 5000)
    let task = URLSession.shared.dataTask(with: request){
        data, response, error in
        if let error = error {
            return
        }
        let httpResponse = response as? HTTPURLResponse
        guard (200...299).contains(httpResponse!.statusCode) else{
            os_log("UpsertKey failed with http: %d, %s" , httpResponse!.statusCode, httpResponse!.description)
            dump(response, maxDepth: 5000)
            return
        }
        
        guard let data = data
        else {
            return
        }
        
        callback()
    }
    task.resume();
}



extension String {
    func split(by length: Int) -> [String] {
        var result: [String] = []
        var currentIndex = self.startIndex
        while currentIndex < self.endIndex {
            let endIndex = self.index(currentIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            result.append(String(self[currentIndex..<endIndex]))
            currentIndex = endIndex
        }
        return result
    }
}
