# AnimalSpeak

This is the xcode project for building and runing the iOS application. Befor you can test it on your own mechine. Plese read the instructions.

## System requirement


### OS:
```
Mac OS X v10.14.3 or higher
```

### Swift version: 
```
Swift 4
```

## IDE requirement
Make sure Xcode is already installed on your machine before running the program. 
(Xcode download link : https://developer.apple.com/xcode/)

### Xcode version: 
```
10.2
```

## Application target device

### Hardware requirement:
```
This applction is designed for IPhone, but also supports iPad.
Use on iPhone for the best user experience.
```
### OS requirement:
```
iOS 10.1 or higher
```

## Prerequisites
```
1.Befor you can run the project please change the bundle identifier and select 
your own iOS developer team for the project.
```

### Testing

Now you can build and run the project by open the following file:
```
AnimalSpeak.xcworkspace
```
### Start the server on your local machine or cloud server:
```
Please refer to the sever setup documentation(Link:)
```
### To connect the application to your own server:
Change serverIp variable to you server’s IP address in the APIWorker.swift file:
```
/// Store here the server's IP address
    var serverIp = "Replace this with your IP address"
```
### To connect the application to your own server:
Change serverIp variable to you server’s IP address in the APIWorker.swift file:
```
/// Store here the server's IP address
    var serverIp = "Replace this with your IP address"
```

### User your own Google API Key:
Make sure you have enabled the knowledge graph API, maps SDK for iOS, and place API in your Google developer console. 
To connect to your own Google API services, simply set apiKey variable to your API key in the APIWorker.swift file:
```
    public var apiKey = "Replace this with your Google API key"
```
AppDelegate.swift:
```
    var apiKey = "Replace this with your Google API key"
```

### User your own BaiduAI API Key:
Get your own Baidu API account. Set baiduAiURL variable to your own link. You can get that form your BaiduAI console(https://login.bce.baidu.com/?lang=en)
Modify the code in ImagePickerViewController.swift:

```
var baiduAiURL: URL {
        return URL(string: "Replace this with you BaiduAI URL")!
        
    }
```

# Usage
In this section, each ViewController class vill be explained including how they can be used, modified, and improved.
## ImagePickerViewController.swift
This ViewController is bound with the imagePickerView which can be presented as a pop up view. This class implment the fuctionalities of upload images from local photo library or camera. After user upload an image, it will be resize and send to image recgition API. Finally the result will be converted from JSON format to DetailResult() stucture.
### func createRequest(with imageBase64: String):
This method makes http request to image recognition API.
Modify this line to connect to you own service:
```
 var request = URLRequest(url: serverUrl)
```
### Result format:
Confrim the structure of JSON reponse of your own service to the following sample stucture:
```
 "result" : [
    {
      "score" : "0.891785",
      "name" : "Little penguin",
      "baike_info" : {
        "baike_url" : "http:\/\/item\/%E5%B0%8F%E8%93%9D%E4%BC%81%E9%B9%85\/10475388",
        "description" : "Little penguin",
        "image_url" : "http:\/\/baike\/pic\/item\/2fdda3cc7cd98d1068ea3254273fb80e7bec909c.jpg"
      }
    },
    {
      "score" : "0.024584",
      "name" : "Penguin",
      "baike_info" : {
        "baike_url" : "http:\/\/item\/%E4%BB%99%E4%BC%81%E9%B9%85\/10958840",
        "description" : "penguin",
        "image_url" : "http:\/\/pic\/item\/6159252dd42a2834d9a165e25bb5c9ea14cebfd0.jpg"
      }
    }
    ]
```

### func createRequest(with imageBase64: String):
This method makes http request to image recognition API.
Modify this line to connect to you own service:
```
 var request = URLRequest(url: serverUrl)
```
### Result format:
Confrim the structure of JSON reponse of your own service to the following sample stucture:
```
 "result" : [
    {
      "score" : "0.891785",
      "name" : "Little penguin",
      "baike_info" : {
        "baike_url" : "http:\/\/item\/%E5%B0%8F%E8%93%9D%E4%BC%81%E9%B9%85\/10475388",
        "description" : "Little penguin",
        "image_url" : "http:\/\/baike\/pic\/item\/2fdda3cc7cd98d1068ea3254273fb80e7bec909c.jpg"
      }
    },
    {
      "score" : "0.024584",
      "name" : "Penguin",
      "baike_info" : {
        "baike_url" : "http:\/\/item\/%E4%BB%99%E4%BC%81%E9%B9%85\/10958840",
        "description" : "penguin",
        "image_url" : "http:\/\/pic\/item\/6159252dd42a2834d9a165e25bb5c9ea14cebfd0.jpg"
      }
    }
    ]
```

## ImagePickerViewController.swift
This ViewController is bound with the imagePickerView which can be presented as a pop up view. This class implment the fuctionalities of upload images from local photo library or camera. After user upload an image, it will be resize and send to image recgition API. Finally the result will be converted from JSON format to DetailResult() stucture.
### func createRequest(with imageBase64: String):
This method makes http request to image recognition API.
Modify this line to connect to you own service:
```
 var request = URLRequest(url: serverUrl)
```
### Result format:
Confrim the structure of JSON reponse of your own service to the following sample stucture:
```
 "result" : [
    {
      "score" : "0.891785",
      "name" : "Little penguin",
      "baike_info" : {
        "baike_url" : "http:\/\/item\/%E5%B0%8F%E8%93%9D%E4%BC%81%E9%B9%85\/10475388",
        "description" : "Little penguin",
        "image_url" : "http:\/\/baike\/pic\/item\/2fdda3cc7cd98d1068ea3254273fb80e7bec909c.jpg"
      }
    },
    {
      "score" : "0.024584",
      "name" : "Penguin",
      "baike_info" : {
        "baike_url" : "http:\/\/item\/%E4%BB%99%E4%BC%81%E9%B9%85\/10958840",
        "description" : "penguin",
        "image_url" : "http:\/\/pic\/item\/6159252dd42a2834d9a165e25bb5c9ea14cebfd0.jpg"
      }
    }
    ]
```

## MapViewController.swift
This class implement the collectionView and collectionViewDataSource for dsiplaying the rounded animal icons in the top section of the MapView. When Icon seleted heat map will be renderd with on the mapView. Temperature Data will also be pass to slidingUpView. Animal location data and weather condition data is required form animalsSpeak server using REST API calls. Map is implemented using Google map iOS SDK. Address auto completion implementd using Google place service.
### func updateMap(result:NSDictionary):
This method feeds data to heat map and shows item on the GoogleMapView.
Modify fllowing line if replacing the Google Map:
```
 var listToAdd = [GMUWeightedLatLng]()
    if let list = result["response"] as? String{
        if let data = list.data(using: .utf8) {
            if let json = try? JSON(data: data) {
                for latlong in json.arrayValue {
                    let lat = latlong[0].doubleValue.roundTo(places: 4)
                    let lng = latlong[1].doubleValue.roundTo(places: 4)
                    let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat , lng ), intensity: 700.0)
                    listToAdd.append(coords)
                }
                DispatchQueue.main.async {
                    self.heatmapLayer.weightedData = listToAdd
                    self.heatmapLayer.map = self.mapView
                    self.activityIndicatior.isHidden = true
                }
                    
            }
        }
    }
```
## APIWorker.swift
A Utility class offers easier API calls. Open class that handles HTTP requests and its methods use call back to send reslut back on complition.
### Eample:
```
let worker = APIWoker()
worker.sendRequestToServer(methodId: 2,request: ["animals":[name]])
{ (result) in
    DispatchQueue.global().async {
        if result != nil{
            self.updateMap(result: result!)
        }
    }
}
```






## Author

Maoning Tang

## Acknowledgments
CBToast.swift：
```
Acknowledge to bolagong(https://github.com/bolagong)
Toast file is written by bolagong on GitHub at: https://github.com/bolagong/Toast
```
TSSlidingUpPanelManager.swift：
```
Acknowledge to pouyaam(https://github.com/pouyaam)
Toast file is written by pouyaam on GitHub at: https://github.com/pouyaam/SlidingUpPanel
```
YoutubePlayer-in-WKWebView.swift：
```
Acknowledge to hmhv(https://github.com/hmhv)
Toast file is written by hmhv on GitHub at: https://github.com/hmhv/YoutubePlayer-in-WKWebView
```




