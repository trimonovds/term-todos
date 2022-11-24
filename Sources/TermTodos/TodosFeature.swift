struct TodosState: Equatable {
    struct DetailsState: Equatable {
        var listIdx: Int
        var todosCount: Int
        var selectedTodoIdx: Int
    }

    var lists: [TodoList] = [
        TodoList(name: "Home", todos: [
            Todo(isDone: false, text: "Go to Mom"),
            Todo(isDone: false, text: "By pants"),
            Todo(isDone: false, text: "Call Beta"),
            Todo(isDone: true, text: "By some stuff for Mom"),
        ]),
        TodoList(name: "Work", todos: [
            Todo(isDone: false, text: "Close exps"),
            Todo(isDone: false, text: "Create JOB tickets"),
            Todo(isDone: false, text: "Make task"),
        ]),
    ]
    var selectedListIdx = 0
    var details: DetailsState? = nil
    var stopped = false
}

enum TodosAction {
    case up
    case down
    case enter
    case back
    case quit
}

func reduceTodos(state: inout TodosState, action: TodosAction) {
    switch action {
    case .up:
        if let details = state.details {
            state.details?.selectedTodoIdx = clamp(details.selectedTodoIdx - 1, to: details.todosCount - 1)
        } else {
            state.selectedListIdx = clamp(state.selectedListIdx - 1, to: state.lists.count - 1)
        }
    case .down:
        if let details = state.details {
            state.details?.selectedTodoIdx = clamp(details.selectedTodoIdx + 1, to: details.todosCount - 1)
        } else {
            state.selectedListIdx = clamp(state.selectedListIdx + 1, to: state.lists.count - 1)
        }
    case .enter:
        if let details = state.details {
            state.lists[details.listIdx].todos[details.selectedTodoIdx].isDone.toggle()
        } else {
            state.details = TodosState.DetailsState(listIdx: state.selectedListIdx, todosCount: state.lists[state.selectedListIdx].todos.count, selectedTodoIdx: 0)
        }
    case .back:
        if state.details != nil {
            state.details = nil
        }
    case .quit:
        state.stopped = true
    }
}
