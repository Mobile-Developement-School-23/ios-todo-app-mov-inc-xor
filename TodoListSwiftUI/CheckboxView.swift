import SwiftUI

struct CheckboxView: View {
    @State var important: Bool
    @State var checked: Bool

    var body: some View {
        Image(checked ? "CheckboxChecked" : important ? "CheckboxImportant" : "CheckboxDefault")
            .onTapGesture {
                checked.toggle()
            }
    }
}

struct CheckboxView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxView(important: true, checked: true)
    }
}
