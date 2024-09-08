# LibreWrist App #

![watch](https://github.com/user-attachments/assets/6e9da8ca-c773-4747-bd9a-aa0db2741033)

***Warning, This project is highly experimental! Please use this app with caution and extreme care. Do not make careless decisions based on software. Do not use this software if you are unsure. Don't use this App for medical decisions. It comes without absolutely no warranty. Use it at your own risk!***

This software is free and open source. It is being developed out of personal needs, but everyone should be able to benefit from it.

It is not meant to replace the vendor's app, but rather enhance it and make diabetes life a bit easier. It is at a very early stage.
For example there are no widgets or complications yet. Chart is not scrollable, because I don't know how to jump to the current data programmatically. Many other shortcomings for now.

### Usage ###
- Settings are made in the iOS app and are then transferred to the watchOS app. This only works if the watchOS app is installed on the watch.
- To connect to your LibreLinkUp follower account, enter your credentials on the connect tab. If the watchOS app is installed, the credentials are transferred to the watch app. It is possible to re-transfer the credentials by pressing the "connect" button again.
- It can take up to a minute for the data to be fetched and displayed.
- To use the insulin calculation, tap on the IOB label on the home screen. I have added only Novorapid for the moment, but more insulins can be added on request.
  - The app is using the exponetial model from LoopKit. The model takes three paramters: actionDuration, peakActivityTime, and delay. For Novorapid I have set 270, 120, and 15 minutes.
- As I have not yet added the widgets / complications, the most convenient way to start the app is by creating a "shortcut" and put that as a widget on the lock screen. In the details of the shortcut one can select "Show on Apple Watch". Then the shortcut is available as a widget on the watch as well.

### Feedback... ###
... is welcome, use the "Issues" functionality of Github.

### Donations... ###
...are always very welcome! [paypal.me/lovemyhusky](paypal.me/lovemyhusky)

Please consider a donation for these projects as well:

### Credits: ###
[DiaBLE](https://github.com/gui-dos/DiaBLE), [LoopKit](https://github.com/LoopKit), [GlucoseDirect](https://github.com/creepymonster/GlucoseDirect), [Nightguard]( https://github.com/nightscout/nightguard), [Nightscout LibreLink Up Uploader](https://github.com/timoschlueter/nightscout-librelink-up)

