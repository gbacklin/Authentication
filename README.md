# FrameworkCommunication

There are 3 scripts to build frameworks.

1. Distribute Frameworks in the framework target's Build Phase. This is used while developing the framework and using a Test application within a single workspace. Building your test application will also build the framework, so it makes for easy writing and testing. It can be found in the Distribution-Project folder in the Framework-Universal folder.

2. BuildFatFramework aggregate target. This is a multi binary framework for distribution to other applications while developing the application that will be using the framework. DO NOT use this framework for submitting the application to the AppStore. It will be rejected because it contains simulator binaries. If you look at the Standalone application's target Build Phase, you will see an Strip Simulator Architecture. If you archive the application with this script, your application should then be accepted.

3. Archive post Action for the framework will build and distribute a framework that does not contain simulator binaries. YOu will use this for an application that you want to submit to the AppStore. It can be found in the Distribution folder in the Frameworks-AppStore folder.
