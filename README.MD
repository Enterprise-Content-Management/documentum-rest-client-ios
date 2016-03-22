Documentum REST IOS Client Samples
=========

This IOS project contains a reference implementation of Documentum REST Services client written in Objective-C code. The
purpose of this project is to demonstrate one way to develop a hypermedia driven REST client to consume Documentum
REST Services. It does NOT indicate that users could not develop a REST client using other technologies.

EMC shares the source code of this project for the technology sharing. If users plan to migrate the sample code to their
 products, they are responsible to maintain this part of the code in their products and should agree with license polices
  of the referenced libraries used by this samp
  le project.


## Overview
This Documentum REST Services client is written with Objective-C code.

*/Supporting Files/main.m* is the main class to be executed with sample operations.

## System Requirements
1. Documentum REST Services 7.0 or 7.1 is deployed in the development environment.
2. IOS SDK is installed.
3. Xcode is recommended as IDE to build, compile and run this project.

### How To Use
1. Set required values as real situation by replacing the following italic parts.
>		NSString * const SERVER_URL = @"http://127.0.0.1:8080";
>		NSString * const USERNAME = @"***username of repository***";
>		NSString * const PASSWORD = @"***password of this user***";
>		NSString * const CABINETS_URI =  @"/***deployed name***/repositories/***repo name***/cabinets.json";

2. Build the project with **Xcode**.
	* Just click on the triangle mark on the top left to build and run.

3. Build the project with **command line**.
	* Modify `TARGET_SDK` value in *build.sh* according to your IOS SDK:
	>		TARGET_SDK="iphoneos9.2"

	* Run *build.sh* file in this folder:
	>		sh build.sh

	* The release project would be in *RestMobileClientAsync/build/Release-iphoneos*