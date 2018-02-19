import Foundation


/// Main entry point.
public class SandboxExplorer: NSObject {

    /// Shared singleton instance
    public static var shared: SandboxExplorer = SandboxExplorer()
    // Wether or not the explorer view is visible
    public var isVisible = false

    private static let sizeCacheDefaultsKey = "se.eriksundin.sandbox-explorer.cache"
    private var sizeCache: [String: Int]
    private var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }

    override init() {
        if let cache = UserDefaults.standard.value(forKey: SandboxExplorer.sizeCacheDefaultsKey) as? [String: Int] {
            self.sizeCache = cache
        } else {
            self.sizeCache = [:]
        }
        super.init()
    }

    public func toggleVisibility() {
        if isVisible {
            rootViewController?.dismiss(animated: true, completion: {
                self.isVisible = false
            })
        } else {
            isVisible = true
            let explorer = SandboxExplorerViewController(data: [])
            if let files = traverse(root: URL(fileURLWithPath: NSHomeDirectory()), sizeCache: &sizeCache) {
                explorer.update(with: files.0)
                UserDefaults.standard.set(sizeCache, forKey: SandboxExplorer.sizeCacheDefaultsKey)
            }
            let controller = UINavigationController(rootViewController: explorer)
            explorer.delegate = self
            rootViewController?.present(controller, animated: true, completion: nil)
        }

    }

}

extension SandboxExplorer: SandboxExplorerDelegate {

    func sandboxExplorerDidTapCancel(_ controller: SandboxExplorerViewController) {
        toggleVisibility()
    }
}

/// Delegate for the SandboxExplorerViewController
protocol SandboxExplorerDelegate: class {

    func sandboxExplorerDidTapCancel(_ controller: SandboxExplorerViewController)
}

/// Represents a file or directory.
class File {

    let name: String
    let parentDir: URL

    /// Full url to this resource.
    var url: URL {
        return parentDir.appendingPathComponent(name)
    }
    var isDirectory = false
    var size: Int?
    var previousSize: Int?
    var children: [File]?

    init(name: String, parentDir: URL) {
        self.name = name
        self.parentDir = parentDir
    }
}

/// Recursively get the files under the given root directory.
///
/// - Parameters:
///   - root: The directory to traverse.
///   - sizeCache: Historic size data, used to calculate delta change in size since last run.
/// - Returns: A tuple with files in the directory and the total size them all.
private func traverse(root: URL, sizeCache: inout [String: Int]) -> ([File], Int)? {
    let resourceKeys : [URLResourceKey] = [.isDirectoryKey, .totalFileSizeKey, .nameKey, .parentDirectoryURLKey]
    guard let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: resourceKeys, options: [.skipsSubdirectoryDescendants]) else {
        return nil
    }

    var size = 0
    var files = [File]()
    for fileURL in enumerator {
        guard let fileURL = fileURL as? URL else {
            continue
        }
        guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)) else {
            continue
        }

        let file = File(name: resourceValues.name!, parentDir: resourceValues.parentDirectory!)
        file.isDirectory = resourceValues.isDirectory!
        file.size = resourceValues.totalFileSize
        if file.isDirectory {
            if let children = traverse(root: file.url, sizeCache: &sizeCache) {
                file.children = children.0
                file.size = children.1
            }
        }
        files.append(file)
        file.previousSize = sizeCache[file.url.absoluteString]
        sizeCache[file.url.absoluteString] = file.size
        if let fileSize = file.size {
            size += fileSize
        }
    }

    return (files, size)
}

/// Cell for file resources.
class FileCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        imageView?.contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static var reuseIdentifier = "fileCell"

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.bounds = CGRect(x: 0, y: 0, width: 26, height: 26)
    }
}

/// The main sandbox file explorer VC.
class SandboxExplorerViewController: UITableViewController {

    weak var delegate: SandboxExplorerDelegate?
    private var folderImage: UIImage? = nil
    private var fileImage: UIImage? = nil
    private var data: [File]

    init(data: [File]) {
        self.data = data

        if let assetsBundleUrl = Bundle(for: SandboxExplorer.self).resourceURL?.appendingPathComponent("Assets.bundle"),
            let assetsBundle = Bundle(url: assetsBundleUrl) {

            folderImage = UIImage(named: "folder", in: assetsBundle, compatibleWith: nil)
            fileImage = UIImage(named: "file", in: assetsBundle, compatibleWith: nil)
        }

        super.init(style: .grouped)
        tableView.register(FileCell.self, forCellReuseIdentifier: FileCell.reuseIdentifier)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeButtonTapped))
    }

    @objc func closeButtonTapped() {
        delegate?.sandboxExplorerDidTapCancel(self)
    }

    func update(with data: [File]) {
        self.data = data
        tableView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.reuseIdentifier, for: indexPath)

        let file = data[indexPath.row]
        cell.textLabel?.text = file.name
        cell.imageView?.image = file.isDirectory ? folderImage : fileImage

        if let size = file.size {
            let text = NSMutableAttributedString(string: "\(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))")

            let previousSize = file.previousSize ?? size
            let diff = size - previousSize
            if diff > 0 {
                let diffText = " (+\(ByteCountFormatter.string(fromByteCount: Int64(diff), countStyle: .file)))"
                text.append(NSAttributedString(string: diffText, attributes: [NSAttributedStringKey.foregroundColor: UIColor.red]))
            } else if diff < 0 {
                let diffText = " (\(ByteCountFormatter.string(fromByteCount: Int64(diff), countStyle: .file)))"
                text.append(NSAttributedString(string: diffText, attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue]))
            }
            cell.detailTextLabel?.attributedText = text
        }
        cell.selectionStyle = file.isDirectory ? .gray : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let file = data[indexPath.row]
        guard let children = file.children, file.isDirectory else {
            return
        }

        let controller = SandboxExplorerViewController(data: children)
        controller.navigationItem.title = file.name
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

}

extension SandboxExplorerViewController: SandboxExplorerDelegate {

    func sandboxExplorerDidTapCancel(_ controller: SandboxExplorerViewController) {
        delegate?.sandboxExplorerDidTapCancel(self)
    }
}
