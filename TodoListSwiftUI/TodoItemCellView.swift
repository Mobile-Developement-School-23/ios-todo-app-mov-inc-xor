import SwiftUI

struct TodoItemCellView: View {
    @State var item: TodoItem

    var body: some View {
        HStack(spacing: 12) {
            CheckboxView(important: item.importance == .important, checked: item.done)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    if item.importance != .basic {
                        Image(item.importance == .low ? "Low" : "Important")

                    }
                    Text(item.text)
                }
                if item.deadline != nil {
                    HStack(spacing: 2) {
                        Image("Calendar")
                        Text(item.deadline!.formatted(.dateTime.day(.twoDigits).month().locale(Locale(identifier: "ru_RU"))))
                            .font(.system(size: 15))
                            .foregroundColor(.black.opacity(0.3))
                    }
                }
            }

            Spacer()

            Image("Arrow")
        }
        .padding(.vertical, 8)
    }
}

struct TodoItemCellView_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemCellView(item: TodoItem(text: "Текст", importance: .low, deadline: Date()))
    }
}
