# LibreWrist App #


![Exported PNG image6](https://github.com/user-attachments/assets/68ec6106-4866-442d-8e78-bc80ddba2608)![Exported PNG image1 Kopie](https://github.com/user-attachments/assets/68a92ba6-c590-4b3f-87ad-9ab77c36cb8c)




***Warning, This project is highly experimental! Please use this app with caution and extreme care. Do not make careless decisions based on software. Do not use this software if you are unsure. Don't use this App for medical decisions. It comes without absolutely no warranty. Use it at your own risk!***

This software is free and open source. It is being developed out of personal needs, but everyone should be able to benefit from it.

It is not meant to replace the vendor's app, but rather enhance it and make diabetes life a bit easier. It is at a very early stage.
For example there are no widgets or complications yet. Chart is not scrollable, because I don't know how to jump to the current data programmatically. Many other shortcomings for now.

### Usage ###
***Installation:*** Make sure that the watchOS app is installed, ideally before starting the iOS app. Depending on your configuration, the watchOS app is either installed automatically, or has to be installed via the "watch" app on the phone.
- The app needs iOS 17.5 and watchOS 10.5
- TestFlight: https://testflight.apple.com/join/HwgkwcGz
- AppStore: https://apps.apple.com/us/app/librewrist/id6670172928
- Settings are made in the iOS app and are then transferred to the watchOS app. This only works if the watchOS app is installed on the watch.
- To connect to your LibreLinkUp follower account, enter your credentials on the connect tab. If the watchOS app is installed, the credentials are transferred to the watch app. It is possible to re-transfer the credentials by pressing the "connect" button again.
- It can take up to a minute for the data to be fetched and displayed.
- To use the insulin calculation, tap on the IOB label on the home screen. I have added only Novorapid for the moment, but more insulins can be added on request. Please let me know.
  - The app is using the exponetial model from LoopKit. The model takes three paramters: actionDuration, peakActivityTime, and delay. For Novorapid I have set 270, 120, and 15 minutes.
- I have set on the watch the "back to watch" time for this app to one hour. Like this, it is 1 hour in the foreground and gets a reasonable number of updates.

### Features ###
* blood glucose graph on phone and watch
* phone screen always on mode
* insulin on board calculation (IOB)
* iOS widgets and lock screen widgets
* watchOS widget

### ToDo ###
A lot....

### Support and Feedback ###
For support please open an issue, start a discussion or email librewrist [at] cmdline [dot] net. Feedback is very welcome, please use the same methods as for support.

### Donations... ###
...are always very welcome! [paypal.me/lovemyhusky](paypal.me/lovemyhusky)

Please have a look at these projects as well:

### Credits: ###
[DiaBLE](https://github.com/gui-dos/DiaBLE), [LoopKit](https://github.com/LoopKit), [GlucoseDirect](https://github.com/creepymonster/GlucoseDirect), [Nightguard]( https://github.com/nightscout/nightguard), [Nightscout LibreLink Up Uploader](https://github.com/timoschlueter/nightscout-librelink-up)

