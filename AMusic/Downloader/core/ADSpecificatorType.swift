import WebKit

protocol ADSpecificator {
    var chargedHosts:[String] { get }
    func applyMetadata(with task:ADDownloadTask,completion:@escaping ()->Void)
}
