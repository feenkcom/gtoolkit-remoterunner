Class {
	#name : #GtRrCodeSyncManager,
	#superclass : #GtRrServerManager,
	#instVars : [
		'codeSync'
	],
	#category : 'RemoteRunner-Runner-Manager'
}

{ #category : #accessing }
GtRrCodeSyncManager >> codeSync [
	^ codeSync
]

{ #category : #accessing }
GtRrCodeSyncManager >> codeSync: anObject [
	codeSync := anObject
]

{ #category : #initialization }
GtRrCodeSyncManager >> initialize [

	super initialize.
	codeSync := GtRrCodeSync new.
]

{ #category : #'api - worker' }
GtRrCodeSyncManager >> registerWorker: aWorkerConnection [
	"If the receiver has been set in the manager
	code sync should be enabled for each worker."
	
	aWorkerConnection attributes at: #codeSynced put: true.
]

{ #category : #'as yet unclassified' }
GtRrCodeSyncManager >> shutdown [

	codeSync stop.
]

{ #category : #'api - worker' }
GtRrCodeSyncManager >> startup [

	codeSync
		remoteRunner: remoteRunner;
		start.
]
