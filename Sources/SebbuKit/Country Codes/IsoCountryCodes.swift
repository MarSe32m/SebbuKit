//
//  IsoCountryCodes.swift
//  
//
//  Created by Sebastian Toivonen on 2.5.2020.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.
import Dispatch

public class IsoCountryCodes {
    public class func getCurrentCountryInfo(_ completion: @escaping (IsoCountryInfo?) -> Void) {
        let endpoint = "https://api.myip.com"
        
        struct MyIPResponse: Codable {
            var ip: String
            var country: String
            var cc: String
        }
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.timeoutInterval = 10
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred while fetching region from myip.com!")
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            if let data = data,
               let response = try? JSONDecoder().decode(MyIPResponse.self, from: data) {
                DispatchQueue.main.async {
                    completion(IsoCountryCodes.find(key: response.cc))
                }
                return
            }
            completion(nil)
        }.resume()
    }
    
    public class func find(key: String) -> IsoCountryInfo? {
        let countries = IsoCountries.allCountries.filter({ $0.alpha2 == key.uppercased() ||
            $0.alpha3 == key.uppercased() || $0.numeric == key })
        return countries.first
    }

    public class func searchByName(_ name: String) -> IsoCountryInfo? {
        let options: String.CompareOptions = [.diacriticInsensitive, .caseInsensitive]
        let name = name.folding(options: options, locale: .current)
        let countries = IsoCountries.allCountries.filter({
            $0.name.folding(options: options, locale: .current) == name
        })
        return countries.count == 1 ? countries.first : searchByPartialName(name)
    }

    private class func searchByPartialName(_ name: String) -> IsoCountryInfo? {
        guard name.count > 3 else {
            return nil
        }
        let options: String.CompareOptions = [.diacriticInsensitive, .caseInsensitive]
        let name = name.folding(options: options, locale: .current)
        let countries = IsoCountries.allCountries.filter({
            $0.name.folding(options: options, locale: .current).contains(name)
        })
        guard countries.count == 1 else {
            return nil
        }
        return countries.first
    }

    public class func searchByNumeric(_ numeric: String) -> IsoCountryInfo? {
        let countries = IsoCountries.allCountries.filter({ $0.numeric == numeric })
        return countries.first
    }

    public class func searchByCurrency(_ currency: String) -> [IsoCountryInfo] {
        let countries = IsoCountries.allCountries.filter({ $0.currency == currency })
        return countries
    }

    public class func searchByCallingCode(_ callingCode: String) -> [IsoCountryInfo] {
        let countries = IsoCountries.allCountries.filter({ $0.calling == callingCode })
        return countries
    }
}
