# ITCiosScreenShotUploader

Small util to upload iOS screenshots to ITC

****
****

Wrapper on **iTMSTransporter** util from XCode (for default uses */Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/itms/bin/iTMSTransporter*, path can be changed in settings)

**So You have to install XCode and Command Line Utils before uploading screenshots** 

****
**Before use — You have to setup version in ITC, create all locales etc* 

****
###Features
* places screenshots to platforms according to image size
* sort screenshots inside platform by name of images
* drag&drop screenshots to reorder default sorting
****
###How to use
* clone/download source, open in XCode, start
* drag screenshots to application's window (supporting folders, nested folder)
* (optional) select mode (same/diff) - read below
* (optional) reorder screenshots
* When you ready to upload
	* Prepare Metadata - to get and edit metadata from ITC (.itmsp will be stored in ~/Library/iTunesUploader)
	* (optional) Validate - to validate :)
	* Upload
* wait about 5-10 min (don't know actual time). ITC need some time to eat screenshots 
	

****

You have to add settings:
 ITC credentials and SKU of application you want add screenshots to

 Password will be stored (if you check "Save" checkbox) in keychain, everything else in NSUserDefaults

****

###Modes:

* **same** - same list of screenshots will be uploaded for all locales, no matter how you call screenshots (that mode is the reason why unit was born - i'm so bored upload so many same screenshots to so many locales)

* **diff** - for every locale need it own set of screenshots. Need to add locale name to image's file name, name it like **"[en-AU]screenshot_1.png"**

****
#WARNING
There's no editing mode, there's no way (as far as I know) to get current screenshots from ITC. 

So whatever you upload — that you will have (i hope:)
****

### IF's
* If you have more then 5 screenshots for platform - will be used first 5 to upload
* **!!!**  __ If you do not add screenshots for some **platform** - it will **remove** current screenshots for that platform from ITC
* **!!!**  __ If you do not add screenshots for some **locale** - it will **leave** current screenshoit for that locale in ITC 

****
##KNOWN ISSUES
* it's my firts mac application, may be some strange stuff
* it's my first swift application, may be some strange stuff
* there's no localization support
* i don't know how to get output of **iTMSTransporter** calls. Log shows in XCode console, but i don't know how to intercept it, NSPipe doesn't works for me
* there's only ios screenshots support 
* no video support
