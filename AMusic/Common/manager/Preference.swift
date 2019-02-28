import Foundation


class Preference:NSObject{
    // MARK: - Singleton
    static let `default` = Preference()
    
    // MARK: - APIs
    var isEffectOn:Bool = true{
        didSet{_save(isEffectOn, forKey: .is_effect_on)}
    }
    
    // MARK: - Init
    override init() {
        super.init()
        self.isEffectOn = _extract(Bool.self, key: .is_effect_on, default: true)
    }
    
    // MARK: - Private Enum
    private enum _PreferenceSavableKeys: String{
        case is_effect_on
    }
    
    // MARK: - Private Properties
    private let kPreferenceNameSpace = "AMPreference"
    
    // MARK: - Private Mathods
    private func _rawKeyName(for key:_PreferenceSavableKeys)->String{
        return kPreferenceNameSpace+"."+key.rawValue
    }
    private func _save<T>(_ value:T ,forKey key: _PreferenceSavableKeys){
        UserDefaults.standard.set(value , forKey: _rawKeyName(for: key))
    }
    private func _extract<T>(_ Type:T.Type,key: _PreferenceSavableKeys)->T?{
        if UserDefaults.standard.object(forKey: _rawKeyName(for: key)) == nil{
            return nil
        }
        
        if let value = UserDefaults.standard.object(forKey: _rawKeyName(for: key)) as? T{
            return value
        }else{
            return nil
        }
    }
    private func _extract<T>(_ Type:T.Type,key: _PreferenceSavableKeys, default defaultValue: T)->T{
        if UserDefaults.standard.object(forKey: _rawKeyName(for: key)) == nil{
            return defaultValue
        }
        
        if let value = UserDefaults.standard.object(forKey: _rawKeyName(for: key)) as? T{
            return value
        }else{
            return defaultValue
        }
    }
}
