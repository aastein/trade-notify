//
//  DownloadManager.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/18/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit


/// Asynchronous Operation base class
///
/// This class performs all of the necessary KVN of `isFinished` and
/// `isExecuting` for a concurrent `NSOperation` subclass. So, to developer
/// a concurrent NSOperation subclass, you instead subclass this class which:
///
/// - must override `main()` with the tasks that initiate the asynchronous task;
///
/// - must call `completeOperation()` function when the asynchronous task is done;
///
/// - optionally, periodically check `self.cancelled` status, performing any clean-up
///   necessary and then ensuring that `completeOperation()` is called; or
///   override `cancel` method, calling `super.cancel()` and then cleaning-up
///   and ensuring `completeOperation()` is called.

class AsynchronousOperation : NSOperation {
    
    override var asynchronous: Bool { return true }
    
    private var _executing: Bool = false
    override var executing: Bool {
        get {
            return _executing
        }
        set {
            if (_executing != newValue) {
                self.willChangeValueForKey("isExecuting")
                _executing = newValue
                self.didChangeValueForKey("isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false
    override var finished: Bool {
        get {
            return _finished
        }
        set {
            if (_finished != newValue) {
                self.willChangeValueForKey("isFinished")
                _finished = newValue
                self.didChangeValueForKey("isFinished")
            }
        }
    }
    
    /// Complete the operation
    ///
    /// This will result in the appropriate KVN of isFinished and isExecuting
    
    func completeOperation() {
        if executing {
            executing = false
            finished = true
        }
    }
    
    override func start() {
        if (cancelled) {
            finished = true
            return
        }
        
        executing = true
        
        main()
    }
}


/// Manager of asynchronous NSOperation objects

class DownloadManager: NSObject, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate {
    
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `NSURLSessionTask`
    
    private var operations = [Int: DownloadOperation]()
    
    /// Serial NSOperationQueue for downloads
    
    let queue: NSOperationQueue = {
        let _queue = NSOperationQueue()
        _queue.name = "download"
        _queue.maxConcurrentOperationCount = 1
        
        return _queue
    }()
    
    /// Delegate-based NSURLSession for DownloadManager
    
    lazy var session: NSURLSession = {
        let id = arc4random()
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(String(id))
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    
    }()
    
    /// Add download
    ///
    /// - parameter URL:  The URL of the file to be downloaded
    ///
    /// - returns:        The DownloadOperation of the operation that was queued
    
    func addDownload(URL: NSURL) -> DownloadOperation {
        let operation = DownloadOperation(session: session, URL: URL)
        operations[operation.task.taskIdentifier] = operation
        queue.addOperation(operation)
        return operation
    }
    
    /// Cancel all queued operations
    
    func cancelAll() {
        queue.cancelAllOperations()
    }
    
    // MARK: NSURLSessionDownloadDelegate methods
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        operations[downloadTask.taskIdentifier]?.URLSession(session, downloadTask: downloadTask, didFinishDownloadingToURL: location)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        operations[downloadTask.taskIdentifier]?.URLSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    // MARK: NSURLSessionTaskDelegate methods
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let key = task.taskIdentifier
        operations[key]?.URLSession(session, task: task, didCompleteWithError: error)
        operations.removeValueForKey(key)
    }
    
}

/// Asynchronous NSOperation subclass for downloading

class DownloadOperation : AsynchronousOperation {
    
    let task: NSURLSessionTask
    
    init(session: NSURLSession, URL: NSURL) {
        task = session.downloadTaskWithURL(URL)
        super.init()
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
    
    // MARK: NSURLSessionDownloadDelegate methods
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let url = String(downloadTask.currentRequest?.URL)
        
        
        do {
            
            let data = try String(contentsOfURL: location, encoding: NSUTF8StringEncoding)
            
            if !data.containsString("<") {
                
                if url.containsString("quotes") {
                    saveStockPrice(data)
                } else {
                    saveStockHistPrice(data, url: url)
                }
            }
        } catch {
            print("ERROR ID 1000", error)
        }
        
       // session.finishTasksAndInvalidate()

    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        //print("\(downloadTask.originalRequest!.URL!.absoluteString) \(progress)")
    }
    
    // MARK: NSURLSessionTaskDelegate methods
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        completeOperation()
        if error != nil {
            print("ERROR ID 1001", error)
        }
    }
    

}

extension DownloadManager: NSURLSessionDelegate {
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler()
                })
            }
        }
    }
}