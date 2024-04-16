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
    private var textViewLabel: UILabel = {
        var label = UILabel()
        label.text = " >>>"
        label.textColor = .white
        label.font = UIFont(name: "Galmuri9", size: 17)

        return label
    }()
    private var textView: UITextField = {
        var textView = UITextField()
        textView.backgroundColor = .black
        textView.font = UIFont(name: "Galmuri9", size: 17)
        textView.textColor = .white
        return textView
    }()
    private lazy var sendButton: UIButton = {
        var button = UIButton()
        button.setTitle("⏎", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont(name: "Galmuri9", size: 17)
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
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
        setTextFieldDelegate()
        registerGestureRecognizer()
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
            self?.clearTextFeild()
            self?.repositionCollectionView(animated: true)
        } didOccurError: { error in
            print(error)
        })
    }
    
    @objc private func sendMessage() {
        guard let text = textView.text else {
            return
        }
        let message = Message(id: UUID(), role: .user, content: text)
        input.send(message)
        dismissKeyboard()
        keyboardWillHide()
    }
    
    private func clearTextFeild() {
        textView.text = ""
    }
    
    private func repositionCollectionView(animated: Bool) {
        let index = collectionView.numberOfItems(inSection: 0)
        let indexPath = IndexPath(item: index - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }
}

extension ChatRoomViewController {
    private func registerGestureRecognizer() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        textViewStackView.snp.updateConstraints {
            $0.bottom.equalTo(mainStackView).offset(-keyboardHeight)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.repositionCollectionView(animated: true)
        }
        
    }
    
    @objc private func keyboardWillHide() {
        textViewStackView.snp.updateConstraints {
            $0.bottom.equalTo(mainStackView)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ChatRoomViewController: UITextFieldDelegate {
    func setTextFieldDelegate() {
        textView.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendMessage()
        return true
    }
}

extension ChatRoomViewController {
    private func setupLayout() {
        view.addSubview(mainStackView)
        mainStackView.addSubview(collectionView)
        mainStackView.addSubview(textViewStackView)
        textViewStackView.addSubview(textViewLabel)
        textViewStackView.addSubview(textView)
        textViewStackView.addSubview(sendButton)
    }
    
    private func makeConstraints() {
        view.backgroundColor = .black
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
            $0.leading.equalTo(textViewStackView).offset(40)
            $0.trailing.equalTo(textViewStackView).offset(-20)
            $0.bottom.equalTo(textViewStackView)
        }
        textViewLabel.snp.makeConstraints {
            $0.top.equalTo(textViewStackView.snp.bottom).offset(-20)
            $0.leading.equalTo(textViewStackView)
            $0.trailing.equalTo(textView.snp.leading)
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
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
            return section
        }
        return layout
    }
}

//struct ChatRoomViewController_PreViews: PreviewProvider {
//    static var previews: some View {
//        let networkService = DefaultNetworkService()
//        let chatbotService = ChatBotService(networkService: networkService)
//        let viewModel = ChatRoomViewModel(chatBotService: chatbotService)
//
//        ChatRoomViewController(viewModel: viewModel).toPreview()
//    }
//}
