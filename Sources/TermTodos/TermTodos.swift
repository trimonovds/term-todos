@main
public struct TermTodos {
    public private(set) var text = "Hello, World!"

    public static func main() {
        print(TermTodos().text)
    }
}
