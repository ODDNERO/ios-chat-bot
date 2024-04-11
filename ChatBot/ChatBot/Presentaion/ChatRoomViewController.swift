import SwiftUI
import SnapKit

class ChatRoomViewController: UIViewController {

    private enum Section {
        case main
    }
    
    private let viewModel: ChatRoomViewModel
    
    private var mainStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private var textViewStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    private var textView: UITextView = {
        var textView = UITextView()
        return textView
    }()
    private lazy var sendButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .black
        button.setImage(.add, for: .normal)
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()
    private lazy var collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.itemSize = CGSize(width: view.frame.width, height: 80)
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let layout = createLayout()
//        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ChatListCell.self, forCellWithReuseIdentifier: ChatListCell.identifier)
        return collectionView
    }()
    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Message>(collectionView: collectionView) { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatListCell.identifier, for: indexPath) as? ChatListCell else {
            let cell = ChatListCell()
            cell.configure(message: itemIdentifier)
            return cell
        }
        cell.configure(message: itemIdentifier)
        return cell
    }
    private var input: ChatRoomViewModel.Input
    
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Message>?
    
    init(viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
        self.input = viewModel.input
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSnapshot()
        bindOutput()
        setupLayout()
        makeConstraints()
    }

}

extension ChatRoomViewController {
    private func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot()
        snapshot?.appendSections([.main])
        snapshot?.appendItems([])
        applySnapshot(snapshot)
    }
    
    private func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<Section, Message>?) {
        guard let snapshot else { return }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func bindOutput() {
        viewModel.bindOutput(output: .init{ [weak self] messages in
            if messages.count >= 2 {
                var messages2 = messages
                let messege = messages2.popLast()!
                let afterMessage = messages2.popLast()!
                self?.snapshot?.insertItems([messege], afterItem: afterMessage)
            } else {
                self?.snapshot?.appendItems(messages)
            }
            self?.dataSource.applySnapshotUsingReloadData((self?.snapshot)!)
        } didOccurError: { error in
            print(error)
        })
    }
    
    @objc private func sendMessage() {
        let message = Message(id: UUID(), role: .user, content: textView.text)
        input.send(message)
    }
}

extension ChatRoomViewController {
    private func setupLayout() {
        view.addSubview(mainStackView)
        mainStackView.addSubview(collectionView)
        mainStackView.addSubview(textViewStackView)
        textViewStackView.addSubview(textView)
        textViewStackView.addSubview(sendButton)
    }
    
    private func makeConstraints() {
        mainStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        textViewStackView.snp.makeConstraints {
            $0.leading.equalTo(mainStackView)
            $0.trailing.equalTo(mainStackView)
            $0.bottom.equalTo(mainStackView)
            $0.height.equalTo(textView)
        }
        textView.snp.makeConstraints {
            $0.top.equalTo(textViewStackView.snp.bottom).offset(-20)
            $0.leading.equalTo(textViewStackView)
            $0.trailing.equalTo(textViewStackView).offset(-20)
            $0.bottom.equalTo(textViewStackView)
        }
        sendButton.snp.makeConstraints {
            $0.top.equalTo(textViewStackView.snp.bottom).offset(-20)
            $0.leading.equalTo(textView.snp.trailing)
            $0.trailing.equalTo(textViewStackView)
            $0.bottom.equalTo(textViewStackView)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(mainStackView)
            $0.leading.equalTo(mainStackView)
            $0.trailing.equalTo(mainStackView)
            $0.bottom.equalTo(textViewStackView.snp.top)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            return section
        }
        return layout
    }
}

class ChatListCell: UICollectionViewCell {
    
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        makeConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatListCell {
    private func setupViews() {
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    private func makeConstraints() {
        label.snp.makeConstraints {
//            $0.leading.equalTo(self).offset(15)
            $0.top.equalTo(contentView.snp.top).offset(8)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-8)
            $0.leading.equalTo(contentView.snp.leading).offset(16)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-16)
        }
    }
    
    func configure(message: Message) {
        label.text = message.content
        contentView.backgroundColor = message.role == .user ? .blue : .green
    }
}

struct ChatRoomViewController_PreViews: PreviewProvider {
    static var previews: some View {
        let networkService = DefaultNetworkService()
        let chatbotService = ChatBotService(networkService: networkService)
        let viewModel = ChatRoomViewModel(chatBotService: chatbotService)

        ChatRoomViewController(viewModel: viewModel).toPreview()
    }
}
