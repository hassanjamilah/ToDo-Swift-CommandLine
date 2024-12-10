import Foundation

/*
 Change the cache implementation
 Handle the save success errors
 */

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: Codable, CustomStringConvertible {
    var uuid: String
    var title: String
    var isCompleted: Bool
    
    init(uuid: String = "", title: String = "", isCompleted: Bool = false) {
        self.uuid = UUID().uuidString
        self.title = title
        self.isCompleted = isCompleted
    }
    
    var description: String {
        "\(title): is \(isCompleted ? "Completed. 👏" : "not completed yet. 🤦")"
    }
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func saveTodos(todos: [Todo]) -> Bool
    func readTodos() -> [Todo]

}

// `FileSystemCache`: This implementation should utilize the file system
// to persist and retrieve the list of todos.
// Utilize Swift's `FileManager` to handle file operations.
final class JSONFileManagerCache: Cache {
    // Get the data file url
    private func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathExtension("todos.data")
    }
    
    func saveTodos(todos: [Todo]) -> Bool {
        do {
            let data = try JSONEncoder().encode(todos)
            let outfile = try self.fileURL()
            try data.write(to: outfile)
            return true
        } catch {
            print("Error in saving the file")
            return false
        }
    }
    
    func readTodos() -> [Todo] {
        do {
            let fileURL = try self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let todos = try JSONDecoder().decode([Todo].self, from: data)
            return todos
        } catch {
            return []
        }
    }

}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session.
// This won't retain todos across different app launches,
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
    var todos: [Todo] = []
    func saveTodos(todos: [Todo]) -> Bool {
        self.todos = todos
        return true
    }
    
    func readTodos() -> [Todo] {
        return todos
    }
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
    func toggleTodo(todoNumber: Int?)
    func deleteTodo(todoNumber: Int?)
}

final class TodoManager: TodoMethodsProtocol {

    var cache: Cache
    
    init(cache: Cache) {
        self.cache = cache
    }

    var numberOfTodos: Int {
        let todos = cache.readTodos()
        return todos.count
    }
    
    func addTodo(todo: Todo) {
        var currentTodos =  cache.readTodos()
        currentTodos.append(todo)
        let result = cache.saveTodos(todos: currentTodos)
        PrintMessage.printSuccessOrFailMessage(result: result)
    }
    
    func deleteTodo(todoNumber: Int?) {
        guard let todoNumber = todoNumber, todoNumber > 0 else {
            return
        }
        
        let index = todoNumber - 1
        var currentTodos =  cache.readTodos()
        if index < currentTodos.count {
            currentTodos.remove(at: index)
            let result = cache.saveTodos(todos: currentTodos)
            PrintMessage.printSuccessOrFailMessage(result: result)
        }
    }
    
    func toggleTodo(todoNumber: Int?) {
        guard let todoNumber = todoNumber, todoNumber > 0 else {
            return
        }
        
        let index = todoNumber - 1
         
        var currentTodos =  cache.readTodos()
        if index < currentTodos.count {
            currentTodos[index].isCompleted = true
            let result = cache.saveTodos(todos: currentTodos)
            PrintMessage.printSuccessOrFailMessage(result: result)
        }
    }
    
    func listTodos() {
        let todos = cache.readTodos()

        print(todos.count == 0 ? "\nYou do not have any ToDos in your list yet. ⁉️\n" : "\n📝 Your ToDo List:")
        for (index, todo) in todos.enumerated() {
            if todo.isCompleted {
                print("\(index + 1). ✅  \(todo.description)")
            } else {
                print("\(index + 1). ☑️ \(todo.description)")
            }
        }
        let numberOfNotCompletedItems = todos.filter({ !$0.isCompleted }).count
        if numberOfNotCompletedItems > 3 {
            print("\nYou have many things todo 🏃‍♂️\n")
        } else if numberOfNotCompletedItems == 0, todos.count > 0 {
            print("\nYou are hero you did all your ToDos 💯💯\n")
        } else if todos.count > 0 {
            print("\nLet's keep going and finish our ToDos 😓\n")
        }
    }
    
    
}

// * The `App` class should have a `func run()` method, this method should perpetually
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class
final class App {
    var todoManager: TodoManager
    
    init(todoManager: TodoManager) {
        self.todoManager = todoManager
    }
    
    enum AppCommand: String {
        case add = "1. Add"
        case list = "2. List"
        case toggle = "3. Toggle"
        case delete = "4. Delete"
        case exit = "5. Exit"
        
        static func printCommands() -> String {
            return "\(self.add.rawValue)\n\(self.list.rawValue)\n\(self.toggle.rawValue)\n\(self.delete.rawValue)\n\(self.exit.rawValue)"
        }
    }
    
    private var inputMessage: String {
        "Please choose what do you want to do from the following list (Enter the command name or the command number):"
    }
    
    private var whereToSaveMessage: String {
        "Where do you want to save your ToDo list (Enter the number of save option)?"
    }
    
    private var whereToSaveOptions: String {
        "1. Memory\n2. File System\n"
    }

    private func executeAdd() {
        PrintMessage.printColoredMessage("Enter the ToDo Title: ", color: .green)
        let todoTitle = readLine() ?? ""
        let todo = Todo(title: todoTitle, isCompleted: false)
        todoManager.addTodo(todo: todo)
        PrintMessage.printColoredMessage("Your todo added successfully. 👍", color: .cyan)
    }
    
    private func executeList() {
        todoManager.listTodos()
    }
    
    private func executeToggle() {
        if todoManager.numberOfTodos > 0 {
            PrintMessage.printColoredMessage("Which ToDo you want to toggle (Enter the number of the ToDo)?", color: .green)
            todoManager.listTodos()
            let input = readLine() ?? ""
            todoManager.toggleTodo(todoNumber: Int(input) ?? 0)
            todoManager.listTodos()
            PrintMessage.printColoredMessage("Your todo toggled successfully. 👍", color: .cyan)
        } else {
            todoManager.listTodos()
        }
        
    }
    
    private func executeDelete() {
        if todoManager.numberOfTodos > 0 {
            PrintMessage.printColoredMessage("Which ToDo you want to delete (Enter the number of the ToDo)?", color: .green)
            todoManager.listTodos()
            let input = readLine() ?? ""
            todoManager.deleteTodo(todoNumber: Int(input) ?? 0)
            todoManager.listTodos()
            PrintMessage.printColoredMessage("Your todo deleted successfully. 👍", color: .cyan)
        } else {
            todoManager.listTodos()
        }
    }
    
    private func executeExit() {
        exit(0)
    }
    
    private func chooseWhereToSave() {
        PrintMessage.printColoredMessage(whereToSaveMessage, color: .green)
        PrintMessage.printColoredMessage(whereToSaveOptions, color: .reset)
        let userInput = readLine()
        switch userInput {
        case "1":
            todoManager = TodoManager(cache: InMemoryCache())
        case "2":
            todoManager = TodoManager(cache: JSONFileManagerCache())
        default:
            print("Can not understand your choice, Do you want to continue (y/n)?")
            let yesNoInput = readLine()
            switch yesNoInput {
            case "n":
                exit(0)
            default:
                chooseWhereToSave()
            }
        }
    }
    
    private func printInputMessage() {
        PrintMessage.printColoredMessage(inputMessage, color: .green)
        PrintMessage.printColoredMessage(AppCommand.printCommands(), color: .reset)
    }
    
    func run() {
        PrintMessage.printColoredMessage("********* Welcome to Awsome ToDo *********", color: .magenta)
        chooseWhereToSave()
        printInputMessage()
        while let command = readLine()?.lowercased() {
            switch command {
            case "1", "add":
                executeAdd()
            case "2", "list":
                executeList()
            case "3", "toggle":
                executeToggle()
            case "4", "delete":
                executeDelete()
            case "5", "exit":
                executeExit()
            default:
                PrintMessage.printColoredMessage("Can not understand your command!!", color: .red)
            }
            printInputMessage()
        }
    }
}

final class PrintMessage {
    enum ConsoleColor: String {
        case red = "\u{001B}[31m"
        case green = "\u{001B}[32m"
        case yellow = "\u{001B}[33m"
        case blue = "\u{001B}[34m"
        case magenta = "\u{001B}[35m"
        case cyan = "\u{001B}[36m"
        case white = "\u{001B}[37m"
        case reset = "\u{001B}[0m"
    }
    
    static func printColoredMessage(_ text: String, color: ConsoleColor) {
        print("\(color.rawValue)\(text)\(ConsoleColor.reset.rawValue)")
    }
    
    static func printSuccessOrFailMessage(result: Bool) {
        if result {
            PrintMessage.printColoredMessage("Your ToDo was saved successfully. 👏", color: .cyan)
        } else {
            PrintMessage.printColoredMessage("Error in savig your ToDo. 😢", color: .red)
        }
    }
}



// Run the application
let main = App(todoManager: TodoManager(cache: InMemoryCache()))
main.run()












