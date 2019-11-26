import SwiftUI

struct ColonyList: View {
    @Binding var colonyData: [Colony]
    @Binding var currentID: Int
    @State var isAdding = false
    
    func colonyIndex(_ colony: Colony)-> Int {
        return colony.id
    }
    
    var body: some View {
        List {
            HStack {
                Text("Colonies")
                    .font(.largeTitle)
                    .padding()
                Button(action: {
                    self.isAdding.toggle()
                }) {
                    Text("+")
                } .sheet(isPresented: $isAdding) {
                    Templates(colonyData: self.$colonyData, isAdding: self.$isAdding)
                }
            }
            
            ForEach(colonyData) { colony in
                Text("\(colony.name)")
                    .onTapGesture {self.currentID = colony.id}
            }
        }
    }
}