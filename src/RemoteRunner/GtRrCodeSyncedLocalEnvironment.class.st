Class {
	#name : #GtRrCodeSyncedLocalEnvironment,
	#superclass : #GtRrLocalEnvironment,
	#instVars : [
		'codeSync'
	],
	#category : #'RemoteRunner-Runner-CodeSync'
}

{ #category : #accessing }
GtRrCodeSyncedLocalEnvironment >> codeSync [

	^ codeSync
]

{ #category : #initialization }
GtRrCodeSyncedLocalEnvironment >> initialize [

	super initialize.
	codeSync := GtRrCodeSync new
]

{ #category : #'instance creation' }
GtRrCodeSyncedLocalEnvironment >> newWorkerLocalProcessArgumentsFor: someSettings [

	^ (super newWorkerLocalProcessArgumentsFor: someSettings)
		  add: '--attribute' before: '--detachChangesFromFileSystem';
		  add: 'codeSynced' before: '--detachChangesFromFileSystem';
		  add: 'true' before: '--detachChangesFromFileSystem';
		  yourself
]

{ #category : #accessing }
GtRrCodeSyncedLocalEnvironment >> remoteRunner: aRemoteRunner [

	super remoteRunner: aRemoteRunner.
	codeSync remoteRunner: aRemoteRunner
]

{ #category : #'startup - shutdown' }
GtRrCodeSyncedLocalEnvironment >> start [

	super start.
	codeSync start
]

{ #category : #'startup - shutdown' }
GtRrCodeSyncedLocalEnvironment >> stop [

	codeSync stop.
	super stop
]
