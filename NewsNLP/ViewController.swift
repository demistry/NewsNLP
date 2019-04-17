//
//  ViewController.swift
//  NewsNLP
//
//  Created by David Ilenwabor on 15/04/2019.
//  Copyright © 2019 Demistry. All rights reserved.
//

import UIKit
import PINRemoteImage
import NaturalLanguage
import Speech

class ViewController: UIViewController , SFSpeechRecognizerDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var newsObject : NewsObject?
    fileprivate var switchState : Bool = false
    fileprivate var speechRecognizer : SFSpeechRecognizer!
    fileprivate let audioEngine = AVAudioEngine()
    var inputNode : AVAudioInputNode!
    var isFinal = false
    var recognitionTask : SFSpeechRecognitionTask!
    var recognitionRequest : SFSpeechAudioBufferRecognitionRequest!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_us"))
        speechRecognizer.delegate = self
        inputNode = configureAudioSession()
        hideKeyboardWhenTappedAround()
        tableView.delegate = self
        tableView.register(NewsTableViewCell.nib, forCellReuseIdentifier: "NewsTableViewCell")
        
        Networking.getNews(queryString: "a") { (result) in
            switch result {
            case .success(let newsObject):
                self.newsObject = newsObject
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failure in receiving with error:\(error.localizedDescription) ")
            }
        }
        
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        switchState = sender.isOn
        if switchState {
            startRecording()
        } else{
            stopRecording()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func stopRecording(){
        recognitionTask.cancel()
        recognitionRequest.endAudio()
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
    }
    
    private func startRecording(){
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        recognitionRequest.shouldReportPartialResults = true
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try! audioEngine.start()
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            
            if let result = result {
                // Update the text view with the results.
                Networking.getNews(queryString: result.bestTranscription.formattedString) { (result) in
                    switch result {
                    case .success(let newsObject):
                        self.newsObject = newsObject
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        self.startRecording()
                    case .failure(let error):
                        print("Failure in receiving with error:\(error.localizedDescription) ")
                    }
                }
                
                self.stopRecording()
                //self.textView.text = result.bestTranscription.formattedString
                self.isFinal = result.isFinal
            }
            
//            if error != nil || self.isFinal {
//                // Stop recognizing speech if there is a problem.
//                self.audioEngine.stop()
//                self.inputNode.removeTap(onBus: 0)
//
//                //recognitionRequest = nil
//                //recognitionTask = nil
//
//                //self.recordButton.isEnabled = true
//                //serecordButton.setTitle("Start Recording", for: [])
//            }
        }
        
    }
    
    private func configureAudioSession()-> AVAudioInputNode{
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        return audioEngine.inputNode
        
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }


}

extension ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let news = newsObject else{
            return 0
        }
        return news.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellOpt = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell
        guard let cell = cellOpt, let news = newsObject, news.articles.count > 0 else{
            return UITableViewCell()
        }
        
        
        cell.newsImageView.pin_updateWithProgress = true
        cell.newsImageView.pin_setImage(from: news.articles[indexPath.row].urlToImage)
        
        if switchState{
            cell.newsDescription.attributedText = getLexicalTerms(titleString: news.articles[indexPath.row].description)
            cell.newsTitle.attributedText = getColoredNameEntity(titleString: news.articles[indexPath.row].title)
        }
        else{
            cell.newsDescription.text = news.articles[indexPath.row].description
            cell.newsTitle.text = news.articles[indexPath.row].title
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 194
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = newsObject!.articles[indexPath.row]
        performSegue(withIdentifier: "showWebView", sender: article)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView"{
            let destination = segue.destination as! WebViewController
            destination.newsObject = sender as? ArticleObject
        }
    }
    
    private func getColoredNameEntity(titleString : String)->NSMutableAttributedString{
        let tagger = NSLinguisticTagger(tagSchemes: [.nameType,.lexicalClass], options: 0)
        tagger.string = titleString
        let options : NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags : [NSLinguisticTag] = [.personalName, .organizationName, .placeName]
        let range = NSRange(location: 0, length: titleString.utf16.count)
        let attributedString = NSMutableAttributedString(string: titleString)
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { (tagOpt, tokenRange, stop) in
            guard let tag = tagOpt, tags.contains(tag) else{
                return
            }
            
            let name = (titleString as NSString).substring(with: tokenRange)
            print("name is \(name)")
            let attributes = [NSAttributedString.Key.foregroundColor : UIColor.blue]
            let range = (titleString as NSString).range(of: name)
            attributedString.addAttributes(attributes, range: range)
        }
        return attributedString
    }
    
    private func getLexicalTerms(titleString : String)-> NSMutableAttributedString{
        let tagger = NSLinguisticTagger(tagSchemes: [.lexicalClass], options: 0)
        tagger.string = titleString
        let options : NSLinguisticTagger.Options = [.omitWhitespace]
        let tags : [NSLinguisticTag] = [.adjective]
        let range = NSRange(location: 0, length: titleString.utf16.count)
        let attributedString = NSMutableAttributedString(string: titleString)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { (tagOpt, tokenRange, stop) in
            guard let tag = tagOpt, tags.contains(tag) else{
                return
            }
            let name = (titleString as NSString).substring(with: tokenRange)
            print("lexicals are \(name)")
            let attributes : [NSAttributedString.Key : Any] = [.foregroundColor : UIColor.green, .font : UIFont.boldSystemFont(ofSize: 12)]
            let range = (titleString as NSString).range(of: name)
            attributedString.addAttributes(attributes, range: range)
        }
        return attributedString
    }
}

