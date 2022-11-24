import Darwin.ncurses
import Foundation

@main
public enum TermTodos {
    public static func main() {
        setlocale(LC_CTYPE, "en_US.UTF-8")
        initscr()
        noecho()
        curs_set(0)
        keypad(stdscr, true)
        use_default_colors()
        defer { endwin() }

        var state = TodosState()
        var lastInput: Int32 = 0

        while !state.stopped {
            erase()
            defer { refresh() }

            // Read evn
            let w = COLS
            let h = LINES

            // Render state
            render(state: state)

            // Render bottom bar
            renderBottomBar(w: w, h: h, key: lastInput)

            // Handle input
            let input = getch()
            let action = TodosAction(key: input)
            if let action = action {
                reduceTodos(state: &state, action: action)
            }
            lastInput = input
        }
    }

    private static func renderListScreen(_ screen: TodosScreen.List) {
        let (list, selectedIdx) = (screen.list, screen.selectedTodoIdx)
        for (i, todo) in list.todos.enumerated() {
            if selectedIdx == i {
                attron(NCURSES.ATTRMask.reversed)
            }
            let text = "[\(todo.isDone ? "x" : " ")] \(todo.text)"
            mvaddstr(Int32(i), 0, text)
            attroff(NCURSES.ATTRMask.reversed)
        }
    }

    private static func renderListsScreen(_ screen: TodosScreen.Lists) {
        let (lists, selectedIdx) = (screen.lists, screen.selectedListIdx)
        for (i, list) in lists.enumerated() {
            if selectedIdx == i {
                attron(NCURSES.ATTRMask.reversed)
            }
            let text = "[\(list.todos.count)] \(list.name)"
            mvaddstr(Int32(i), 0, text)
            attroff(NCURSES.ATTRMask.reversed)
        }
    }

    private static func render(state: TodosState) {
        switch state.viewState.last! {
        case let .list(screen):
            renderListScreen(screen)
        case let .lists(screen):
            renderListsScreen(screen)
        }
    }

    private static func renderBottomBar(w: Int32, h: Int32, key: Int32) {
        var bottomBar = "`q` to quit."
        #if DEBUG
            bottomBar.append("\tw: \(w), h: \(h), key: \(key)")
        #endif
        attron(NCURSES.ATTRMask.reversed)
        mvaddstr(h - 1, 0, String(repeating: " ", count: Int(w)))
        mvaddstr(h - 1, 0, bottomBar)
        attroff(NCURSES.ATTRMask.reversed)
    }
}

private enum TodosScreen: Equatable {
    struct Lists: Equatable {
        let lists: [TodoList]
        let selectedListIdx: Int
    }

    struct List: Equatable {
        let list: TodoList
        let selectedTodoIdx: Int
    }

    case lists(Lists)
    case list(List)
}

private typealias TodosViewState = [TodosScreen]

private extension TodosState {
    var viewState: TodosViewState {
        var screens = [TodosScreen.lists(TodosScreen.Lists(lists: lists, selectedListIdx: selectedListIdx))]
        if let details = details {
            screens.append(.list(TodosScreen.List(list: lists[details.listIdx], selectedTodoIdx: details.selectedTodoIdx)))
        }
        return screens
    }
}

private extension TodosAction {
    init?(key: Int32) {
        switch key {
        case "q".unsafeASCII32:
            self = .quit
        case KEY_UP:
            self = .up
        case KEY_DOWN:
            self = .down
        case 127, KEY_LEFT:
            self = .back
        case " ".unsafeASCII32, KEY_RIGHT:
            self = .enter
        default:
            return nil
        }
    }
}

private extension String {
    var unsafeASCII32: Int32 {
        Int32(Character(self).asciiValue!)
    }
}