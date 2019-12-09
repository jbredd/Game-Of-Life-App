import SwiftUI
import Foundation
import Combine

struct ColonyView: View {
    @Binding var colony: Colony
    @State var evolveTime = 1.0
    var evolutionTimer: Publishers.Autoconnect<Timer.TimerPublisher> {
        return Timer.publish(every: TimeInterval(evolveTime), on: .main, in: .common).autoconnect()
    }
    @State var isEvolving = false
    @State var isOpenSettings = false
    @State var wrap = false
    //@State var liveColor = UIColor.green
    //@State var deadColor = UIColor.red
    
    var gridLength: CGFloat
    var cellLength: CGFloat {
        return gridLength/60
    }
    
    func onDragAt(point: CGPoint) {
        if point.x < 0 || point.y < 0 || point.x >= gridLength || point.y >= gridLength {
            return
        }
        let row = Int(point.y/cellLength)
        let col = Int(point.x/cellLength)
        //print(row,col)
        self.colony.setCellAlive(Coordinate(row, col))
    }
    
    
    func renderGrid()->UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: gridLength, height: gridLength))
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.blue.cgColor)

            let rectangle = CGRect(x: 0, y: 0, width: gridLength, height: gridLength)
            ctx.cgContext.addRect(rectangle)
            
            for row in 0..<60 {
                for col in 0..<60 {
                    let rectangle = CGRect(x: Int(CGFloat(col)*cellLength), y: Int(CGFloat(row)*cellLength), width: Int(cellLength), height: Int(cellLength))
                    ctx.cgContext.addRect(rectangle)
                    let color = colony.isCellAlive(Coordinate(row, col)) ? colony.liveColor : colony.deadColor
                    
                    ctx.cgContext.setFillColor(color.cgColor)
                    ctx.cgContext.addRect(rectangle)
                    ctx.cgContext.drawPath(using: .fillStroke)
                }
            }
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        return img
    }
    
    var gridView: some View {
        Image(uiImage: renderGrid()).onReceive(evolutionTimer) {_ in
            if self.isEvolving {
                if self.wrap {self.colony.evolveWrap()}
                else {self.colony.evolve()}
            }
        }.drawingGroup()
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                self.onDragAt(point: value.location)
        }   // 4.
            .onEnded { value in
            }
        )
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Toggle("Wrapping", isOn: self.$wrap)
                    .frame(width: 135)
                    .padding()
                
                if colony.name == "New Colony" {
                    TextField("New Colony", text: self.$colony.name)
                        .font(.largeTitle)
                        .padding()
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .offset(x: -50)
                } else {
                    TextField(colony.name, text: self.$colony.name)
                        .font(.largeTitle)
                        .padding()
                        .multilineTextAlignment(.center)
                        .offset(x: -50)
                }
                                
                Button(action: {self.isOpenSettings.toggle()}) {
                    Image(systemName: "gear")
                        .resizable()
                        .foregroundColor(.black)
                }
                .frame(width: 23, height: 23, alignment: .topTrailing)
                .padding()
                .sheet(isPresented: $isOpenSettings) {
                    Settings(name: self.$colony.name, liveColor: self.$liveColor, deadColor: self.$deadColor, wrapping: self.wrap, timer: self.evolveTime, generationNumber: self.colony.generationNumber, numberLiving: self.colony.numberLivingCells)
                }
            }
            
            self.gridView
                .multilineTextAlignment(.center)
                .offset(x: 0, y: -8)
            
            VStack {
                HStack {
                    Text("Fast")
                    Slider(value: $evolveTime, in: 0.1...2, step: 0.05)
                        .frame(width: 375)
                    Text("Slow")
                }
                
                VStack {
                    if isEvolving {
                        Button(action: {self.isEvolving.toggle()}) {
                            Image(systemName: "pause.fill")
                                 .resizable()
                                .foregroundColor(.black)
                        }.frame(width: 25, height: 25, alignment: .center)
                        
                    } else {
                        Button(action: {self.isEvolving.toggle()}) {
                            Image(systemName: "play.fill")
                                 .resizable()
                                .foregroundColor(.black)
                        }.frame(width: 25, height: 25, alignment: .center)
                    }
                    Text("Evolve")
                }
            }.multilineTextAlignment(.center)
        }
    }
}

