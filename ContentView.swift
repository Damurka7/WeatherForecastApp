//
//  ContentView.swift
//  WeatherForecast
//
//  Created by Damir Nurtdinov on 26.07.2021.
//

import SwiftUI
import SwiftSoup

let myURLString = "https://yandex.ru/pogoda/"
let dictOfCities = ["Казань" : "kazan", "Москва":"moscow", "Екатеринбург":"54", "Сочи":"sochi?via=reg",]

struct TimeTemp: View {
    var time: String
    var temperature : String
    
    var body: some View {
        HStack{
            Text("\(time)")
                .foregroundColor(.white)
                .font(.system(size: 18))
                .bold()
            Spacer()
            Text("\(temperature)")
                .foregroundColor(.white)
                .font(.system(size: 18))
        }
    }
}

struct Cities: View {
    var body: some View {
        HStack{
            List {
                ForEach(dictOfCities.sorted(by: >), id: \.key) { key, value in
                    Section(header: Text(key)) {
                        Text(value)
                    }
                }
            }
        }
    }
}


struct ContentView: View {
    @State public var selectCity = Set<String>()
    @State private var chooseCity = false
    @State private var listOfCititesBlock = CGSize.zero
    @State private var city: String? = "kazan"
    
    var body: some View {
        Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
            .ignoresSafeArea() // Ignore just for the color
            .overlay(
                ZStack{
                    VStack{
                        
                        Text("Ваше местоположение:")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        
                        Text(getCity(city!))
                            .foregroundColor(.white)
                        
                        
                        Image("cloud")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                        
                        Text("Текущая температура:")
                            .foregroundColor(.white)
                            .font(.title)
                        
                        Text(tempFromSite(city!))
                            .font(.system(size: 45))
                            .bold()
                            .foregroundColor(.white)
                        
                        Text(infoFromSite(city!))
                            .foregroundColor(.white)
                            .bold()
                        
                        VStack {
                            Text("Ощущается как")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                            
                            Text(getFeelsLike(city!))
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        .offset(y: 10)
                        
                        
                        List{
                            ForEach(4..<20) { i in //takes info for each hour, starts from 4, ends with 20
                                TimeTemp (time: divideString(tempForHours(city!, iterator: i)).0, temperature: divideString(tempForHours(city!, iterator: i)).1)
                            }
                            .listRowBackground(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                        }
                        .offset(y: 10)
                        
                        
                        Spacer()
                    }
                    
                    
                    
                    Button(action: {
                        self.chooseCity.toggle()
                    }) {
                        
                        Image("button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                    }
                    .offset(x: -160, y: -370)
                    
                    VStack(spacing: 10){
                        HStack{
                            Text("Выберете город:")
                                .multilineTextAlignment(.leading)
                                .font(.title)
                                .offset(x: -45)
                            
                            Button(action: {
                                self.chooseCity.toggle()
                            }) {
                                
                                Image("crosshair")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            }
                            .offset(x: 40)
                        
                            
                        }
                        Spacer()
                        
                        let cities = Array(dictOfCities.keys)
                        
                        HStack{
                            
                                List(cities, id: \.self, selection: $city) { name in
                                    SelectionCell(gorod: name, selectedCity: self.$city)
                                }
                                
                            
                        }
                        
                    }
                    .padding(.top, 50)
                    .frame(maxWidth: 390, maxHeight: .infinity)
                    .background(Color.white)
                    .shadow(radius: 20)
                    .offset(listOfCititesBlock)
                    .offset(x: chooseCity ? 0 : -400)//0 : -400
                    .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
                    .cornerRadius(50)
                    .ignoresSafeArea()
                }
                .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
            )
    }
}

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

struct SelectionCell: View {
    
    let gorod: String
    @Binding var selectedCity: String?
    
    var body: some View {
        HStack {
            Text(gorod)
            Spacer()
            let key = dictOfCities.someKey(forValue: selectedCity!)
            if gorod == key {
                Text("Selected")
            }
        }
        .onTapGesture {
            self.selectedCity = dictOfCities[gorod]
        }
    }
}

func template(_ city : String,_ str: String) -> Array<Elements.Element>{
    var arr:Array<Elements.Element> = []
    guard let myURl = URL(string: myURLString + city) else {return arr}
    
    do {
        
        let myHTMLString = try String(contentsOf: myURl, encoding: .utf8)
        let htmlContent = myHTMLString
        
        do{
            let doc = try SwiftSoup.parse(htmlContent)
            do {
                return try doc.select(str).array()
            }catch{}
        }
    } catch Exception.Error(let type, let message) {
        print(message)
    } catch {
        print("error")
    }
    return arr
}

/*
 function shows the temperature from yandex
 */
func tempFromSite(_ city : String) -> String {
    
    do{
        let element = template(city, "span")
        let text = try element[14].text() //get temperature from site
        return try text
    } catch{}
    return "Fail"
}

/*
 function shows the additional info about weather from yandex
 */
func infoFromSite(_ city : String) -> String {
    
    do{
        let element = template(city, "div")
        let text = try element[40].text() //additional info from cite
        return try text
    } catch{}
    return "Fail"
}

/*
 function shows the name of town
 */
func getCity(_ city : String) -> String {
    
    do{
        let element = template(city, "span")
        let text = try element[9].text() //city from the site
        return try text
    } catch{}
    return "Fail"
}

/*
 function shows the 'feels like' temp
 */
func getFeelsLike(_ city : String) -> String {
    do{
        let element = template(city, "span")
        let text = try element[15].text() //city from the site
        return try text
    } catch{}
    return "Fail"
}

/*
 function shows the temperature for each our
 */
func tempForHours(_ city : String, iterator: Int) -> String {
    do{
        let element = template(city, "li")
        let text = try element[iterator].text() //temp info from cite
        return try text
    } catch{}
    return "Fail"
}

func divideString(_ str: String) -> (String, String) {
    
    var timeStr = String(str.prefix(5))
    var tempStr = String(str.suffix(5))
    return (timeStr, tempStr)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
