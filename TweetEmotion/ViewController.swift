
import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var ScoreText: UITextField!
    
    let sentimentClassifier = TweetSentimentClassifier()

    let swifter = Swifter(consumerKey: "W4XzKPuS2MPtW6njqYOfhVz2G", consumerSecret: "p16x1vvRFfGSxZ0ZJB30eQi6xx7DHUY5yfkNxG3HL4pvYwev9s")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        ScoreText.backgroundColor = backgroundView.backgroundColor;
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tapGesture)
   }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
            return true
        
        
    }

    @IBAction func predictPressed(_ sender: Any) {
        
        if let searchText = textField.text {
            
            swifter.searchTweet(using: searchText, lang: "en", count:100, tweetMode: .extended , success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput] ()
                
                for i in 0..<100{
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                do {
                    let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                    
                    var sentimentScore = 0
                    
                    for pred in predictions {
                        
                        let sentiment = pred.label
                        
                        if sentiment == "Pos"{
                            sentimentScore += 1
                        }
                        else if sentiment == "Neg"{
                            sentimentScore -= 1
                        }
                    }
                    self.ScoreText.text = String(sentimentScore)
                    
                    if sentimentScore > 20 {
                        self.sentimentLabel.text = "😍"
                    }
                    else if sentimentScore > 10 {
                        self.sentimentLabel.text = "😄"
                    }
                    else if sentimentScore > 0 {
                        self.sentimentLabel.text = "🙂"
                    }
                    else if sentimentScore == 0 {
                        self.sentimentLabel.text = "😐"
                    }
                    else if sentimentScore > -10 {
                        self.sentimentLabel.text = "😕"
                    }
                    else if sentimentScore > -20 {
                        self.sentimentLabel.text = "😡"
                    }
                    else {
                        self.sentimentLabel.text = "🤮"
                    }
                    
                }
                catch{
                    print(error)
                }
            }) { (error) in
                print("There is an error \(error)")
            }
        }
    }
}

