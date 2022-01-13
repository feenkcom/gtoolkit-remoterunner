Class {
	#name : #GtRrCodeSyncedLocalManagerStartupAndShutdown,
	#superclass : #GtRrLocalManagerStartupAndShutdown,
	#instVars : [
		'codeSync'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> codeSync [

	^ codeSync
]

{ #category : #initialization }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> initialize [

	super initialize.
	codeSync := GtRrCodeSync new
]

{ #category : #'instance creation' }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> newWorkerLocalProcessArgumentsFor: someSettings [

	^ (super newWorkerLocalProcessArgumentsFor: someSettings)
		  add: '--codeSync' before: '--serverSocketAddress';
		  yourself
]

{ #category : #accessing }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> remoteRunner: aRemoteRunner [

	super remoteRunner: aRemoteRunner.
	codeSync remoteRunner: aRemoteRunner
]

{ #category : #'startup - shutdown' }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> shutdown [

	codeSync stop.
	super shutdown
]

{ #category : #'startup - shutdown' }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> startup [

	super startup.
	codeSync start
]
