import SwiftUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

struct MyViewController_PreViews: PreviewProvider {
    static var previews: some View {
        ViewController().toPreview()
    }
}
