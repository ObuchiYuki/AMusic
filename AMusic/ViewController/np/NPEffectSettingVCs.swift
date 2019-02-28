import UIKit
import AVFoundation

class NPEffectBaseVC: AMViewController {
    override func colorThemeDidChange(with palette: ColorPalette) {
        super.colorThemeDidChange(with: palette)
        
        self.view.backgroundColor = palette.backgroundColor
        self.view.allSubviews(of: UILabel.self).filter{$0.font.pointSize == 27}.forEach{
            $0.textColor = palette.textColor
        }
    }
}

class NPEffectManuVC: NPTableViewContoller{
    override func viewDidAppear(_ animated: Bool) {
        let cell = tableView.cellForRow(at: [1, 0])
        cell?.detailTextLabel?.text = MediaPlayer.default.effect.reverb.locarizedName
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        switch indexPath {
        case [1, 0]:
            cell.detailTextLabel?.text = MediaPlayer.default.effect.reverb.locarizedName
        default:
            break
        }
        
        return cell
    }
}

class NPEffectPitchVC :NPEffectBaseVC{
    @IBOutlet weak var pitchSlider: AMMixerSlider!
    @IBAction func didPitchSliderChange(_ sender: AMMixerSlider) {
        MediaPlayer.default.effect.pitchShift = sender.value
    }
    @IBOutlet weak var speedSlider: AMMixerSlider!
    @IBAction func didSpeedSliderChange(_ sender: AMMixerSlider) {
        MediaPlayer.default.effect.speed = sender.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pitchSlider.value = MediaPlayer.default.effect.pitchShift
        speedSlider.value = MediaPlayer.default.effect.speed
    }
}

class NPEffectReverbVC: AMTableViewController{
    var reverbTypes:[IndexPath: AVAudioUnitReverbPreset?] = [
        [0,0]: nil,
        [0,1]: nil,
        
        [1,0]: .smallRoom,
        [1,1]: .mediumRoom,
        [1,2]: .largeRoom,
        [1,3]: .mediumHall,
        [1,4]: .largeHall,
        [1,5]: .mediumChamber,
        [1,6]: .largeChamber,
        [1,7]: .mediumHall2,
        [1,8]: .mediumHall3,
        [1,9]: .largeHall2,
        [1,10]: .cathedral,
        [1,11]: .plate
    ]
    var selectedIndexPath:IndexPath = [0, 0]
    
    func selectionDidChange(to indexPath:IndexPath){
        MediaPlayer.default.effect.reverb.isManualType = indexPath == [0,1]
        MediaPlayer.default.effect.reverb.type = reverbTypes[indexPath] ?? nil
    }
    override func colorThemeDidChange(with palette: ColorPalette) {
        super.colorThemeDidChange(with: palette)
        self.view.backgroundColor = palette.groupeTableViewColor
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.useAlternatelyCell = false
        
        if MediaPlayer.default.effect.reverb.isManualType {
            selectedIndexPath = [0, 1]
        }else{
            if MediaPlayer.default.effect.reverb.type == nil {selectedIndexPath = [0, 0];return}
            guard let reverb = reverbTypes.values.index(of: MediaPlayer.default.effect.reverb.type) else {return}
            selectedIndexPath = reverbTypes.keys[reverb]
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reverbTypes.filter{$0.key.section == section}.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath != [0, 1] {tableView.deselectRow(at: indexPath, animated: true)} else {performSegue(withIdentifier: "toManual", sender: nil)}
        
        let oldSelectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        
        tableView.reloadRows(at: [selectedIndexPath, oldSelectedIndexPath], with: .automatic)
        
        selectionDidChange(to: indexPath)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.getCurrentColorThemedCell(withIdentifier: "cell", for: indexPath)
        
        switch indexPath {
        case [0, 0]: cell.textLabel?.text = "なし"
        case [0, 1]: cell.textLabel?.text = "カスタム"
        default:     cell.textLabel?.text = reverbTypes[indexPath]??.locarizedName ?? ""
        }
        
        if selectedIndexPath == indexPath{
            cell.accessoryType = .checkmark
        }else if indexPath == [0, 1]{
            cell.accessoryType = .disclosureIndicator
        }else{
            cell.accessoryType = .none
        }
        
        return cell
    }
}

class NPEffectManualReverbVC: NPEffectBaseVC {
    @IBOutlet weak var reverbSlider: AMMixerSlider!
    @IBAction func reverbSliderDidChange(_ sender: AMMixerSlider) {
        MediaPlayer.default.effect.reverb.feebback = sender.value
    }
    @IBOutlet weak var mixSlider: AMMixerSlider!
    @IBAction func mixSliderDidChange(_ sender: AMMixerSlider) {
        MediaPlayer.default.effect.reverb.mix = sender.value
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reverbSlider.value = MediaPlayer.default.effect.reverb.feebback
        mixSlider.value = MediaPlayer.default.effect.reverb.mix
    }
}


extension EffectPlayerSetting.Reverb{
    var locarizedName:String{
        if self.isManualType{
            return "カスタム"
        }else if let type = self.type{
            return type.locarizedName
        }else{
            return "なし"
        }
    }
}

extension AVAudioUnitReverbPreset{
    var locarizedName: String{
        switch self {
        case .smallRoom    :return "部屋 (小)"
        case .mediumRoom   :return "部屋 (中)"
        case .largeRoom:    return "部屋 (大)"
        case .mediumHall:   return "ホール (中)"
        case .largeHall:    return "ホール (大)"
        case .mediumChamber:return "音響室 (中)"
        case .largeChamber: return "音響室 (中)"
        case .mediumHall2:  return "ホール2 (中)"
        case .mediumHall3:  return "ホール3 (中)"
        case .largeHall2:   return "ホール2 (大)"
        case .cathedral:    return "大聖堂"
        case .plate:        return "プレート"
        default: return ""
        }
    }
}

class NPEffectEQVC: NPEffectBaseVC {
    @IBOutlet weak var eqSwitch: UISwitch!
    @IBAction func eqSwitchDidChange(_ sender: UISwitch) {
        if sender.isOn{
            MediaPlayer.default.effect.equalizerGains = [2,6,8,11,7,6,5,2,9,7].map{6-$0}
        }else{
            MediaPlayer.default.effect.equalizerGains = Array(repeating: 0, count: 10)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eqSwitch.isOn = MediaPlayer.default.effect.equalizerGains.filter{$0 == 0}.count != 0
    }
}















