import SwiftUI

struct ContentView: View {
    var list: [TodoItem] = [
        TodoItem(text: "Задача 1", importance: .basic),
        TodoItem(text: "Задача 2", importance: .low),
        TodoItem(text: "Задача 3", importance: .important),
        TodoItem(text: "Задача 2", importance: .important, deadline: Date()),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(list) {
                        TodoItemCellView(item: $0)
                    }
                } header: {
                    HStack {
                        Text("Выполнено - \(list.reduce(0, { $0 + ($1.done ? 1 : 0) }))")
                        Spacer()
                        Button {

                        } label: {
                            Text("Показать")
                                .bold()
                        }
                    }
                    .textCase(.none)
                    .font(.system(size: 15))
                    .padding(.bottom, 12)
                }
            }

            .listStyle(.insetGrouped)
            .navigationTitle("Мои дела")
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.97, green: 0.97, blue: 0.95))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
