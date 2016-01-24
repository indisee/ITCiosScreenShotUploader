# iTunesConnect iOS screenshot uploader

![Alt text](Screenshots/1.png?raw=true "Title")![Alt text](Screenshots/2.png?raw=true "Title")	

Small UI util to upload iOS screenshots to iTunesConnect for AppStore

****
OSX Deployment target 10.11 - because of some features of collection view 
****

Wrapper around **iTMSTransporter** command line util from XCode (for default using */Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/itms/bin/iTMSTransporter*, path can be changed in settings)

****
###Before use
* **You have to install XCode and Command Line Tools*
* **You have to setup version in iTunesConnect, create all locales etc* 

****
###Features
* sort screenshots to platforms according to image size
* sort screenshots inside platform by image name
* drag&drop screenshots to reorder

****

###How to use
* clone/download source, open in XCode, start
* drag screenshots to application's window (supporting folders, nested folder)
* (optional) select mode (same/diff) - *read below*
* (optional) reorder screenshots
* When you ready to upload:
	* Prepare Metadata - to download and edit metadata from iTunesConnect (.itmsp will be stored in ~/Library/iTunesUploader folder)
	* (optional) Validate - to validate :)
	* Upload
* wait about 5-10 min (don't know actual time). iTunesConnect need some time to eat screenshots 
	

****



 * You have to add settings - iTunesConnect credentials and SKU of application you want add screenshots to

 * Password will be stored (if you check "Save" checkbox) in keychain, everything else in NSUserDefaults

****

###Modes:

* **same** - same list of screenshots will be uploaded for all locales, no matter how you name screenshots (this mode is the reason why util was born - I'm so bored uploading too many same screenshots to so many locales)

* **diff** - every locale will have its own screenshot set. Add locale name to image's file name, like **"[en-AU]screenshot_1.png"**. Unnamed screenshots will be ignored

****
#WARNING
* If you do not add screenshots for some **platform** - it will **remove** current screenshots for that platform from iTunesConnect
* If you do not add screenshots for some **locale** - it will **leave** current screenshoit for that locale in iTunesConnect 
* If you have more than 5 screenshots for platform - first 5 will be uploaded

There's no editing mode, there's no way (as far as I know) to get current screenshots from iTunesConnect. 



 
****
##KNOWN ISSUES
* it's my first mac application, there might be some strange stuff
* it's my first swift application, there might be some strange stuff
* there's no localization support
* I don't know how to get output of **iTMSTransporter** calls. Log shows in XCode console, but I don't know how to intercept it, NSPipe doesn't works for me
* there's only iOS screenshots support 
* no video support

****

###Feel free to distribute
