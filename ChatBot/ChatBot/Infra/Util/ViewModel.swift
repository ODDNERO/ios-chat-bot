protocol ViewModel {
    associatedtype Input
    associatedtype Output

    func bindOutput(output: Output)
}
