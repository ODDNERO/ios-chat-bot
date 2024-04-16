import UIKit

class ChatListCell: UICollectionViewCell {
    
    var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .systemGreen
        label.numberOfLines = 0
        label.font = UIFont(name: "Galmuri9", size: 17)
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
            $0.top.equalTo(contentView.snp.top).offset(8)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-8)
            $0.leading.equalTo(contentView.snp.leading).offset(8)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-8)
        }
    }
    
    func configure(message: Message) {
        label.text = "\(message.role.rawValue.capitalized): \(message.content)"
        label.textColor = message.role == .user ? .white : .systemGreen
        contentView.backgroundColor = .black
    }
}

