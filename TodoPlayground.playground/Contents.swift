import Foundation

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo {
    var  uuid: String = UUID().uuidString
    var title: String
    var isCompleted: Bool
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {

}

// `FileSystemCache`: This implementation should utilize the file system
// to persist and retrieve the list of todos.
// Utilize Swift's `FileManager` to handle file operations.
final class JSONFileManagerCache: Cache {

}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session.
// This won't retain todos across different app launches,
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {

}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)`
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
protocol TodoMethodsProtocol {
    func addTodo(todo: Todo)
    func listTodos()
    func toggleTodo(uuid: String)
    func deleteTodo(uuid: String)
}

final class TodoManager: TodoMethodsProtocol {
    var todos: [Todo]
    
    init(todos: [Todo]) {
        self.todos = todos
    }
    
    func addTodo(todo: Todo) {
        todos.append(todo)
    }
    
    func deleteTodo(uuid: String) {
        todos.removeAll {$0.uuid == uuid}
    }
    
    func toggleTodo(uuid: String) {
        guard !todos.isEmpty else {
            return
        }
        let index = todos.firstIndex {$0.uuid == uuid} ?? 0
        todos[index].isCompleted = true
    }
    
    func listTodos() {
        print("📝 Your ToDo List:")
        for (index, todo) in todos.enumerated() {
            if todo.isCompleted {
                print("\(index + 1). ✅ \(todo.title)")
            } else {
                print("\(index + 1). ☑️ \(todo.title)")
            }
        }
        let numberOfNotCompletedItems = todos.filter({ !$0.isCompleted }).count
        if numberOfNotCompletedItems > 3 {
            print("You have many thinks todo 🏃‍♂️")
        } else if numberOfNotCompletedItems == 0 {
            print("You are hero you did all your ToDos 💯💯")
        } else {
            print("Let's keep going and finish our ToDos 😓")
        }
    }
    
    
}


// * The `App` class should have a `func run()` method, this method should perpetually
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class
final class App {

}


// TODO: Write code to set up and run the app.
print("helllo")

let todo1 = Todo(title: "Task 1", isCompleted: false)
let todo2 = Todo(title: "Task 2", isCompleted: false)
let todo3 = Todo(title: "Task 3", isCompleted: false)
let todo4 = Todo(title: "Task 4", isCompleted: false)

var todoManager = TodoManager(todos: [todo1, todo2, todo3, todo4])
todoManager.listTodos()

todoManager.addTodo(todo: Todo(title: "Task 15", isCompleted: false))
todoManager.listTodos()


todoManager.toggleTodo(uuid: todo3.uuid)
todoManager.toggleTodo(uuid: todo4.uuid)
todoManager.listTodos()

//while let x = readLine() {
//    print(x)
//    if x == "exit" {
//        exit(0)
//    }
//}


