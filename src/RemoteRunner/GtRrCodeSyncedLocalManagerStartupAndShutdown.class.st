"
{{gtClass:GtRrCodeSyncedLocalManagerStartupAndShutdown}} extends the local manager to mark every worker started automatically as code synced.
"
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
	codeSync := GtRrCodeSync new.
	"Disable worker auto-restart since the workers would then be out of sync."
	autoRestart := false.
]

{ #category : #'api - worker' }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> registerWorker: aWorkerConnection [

	aWorkerConnection details at: #codeSynced put: true.
]

{ #category : #'startup - shutdown' }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> shutdown [

	codeSync stop.
	super shutdown.
]

{ #category : #'startup - shutdown' }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> startup [

	super startup.
	codeSync 
		remoteRunner: remoteRunner;
		start.
]

{ #category : #ui }
GtRrCodeSyncedLocalManagerStartupAndShutdown >> summaryAttributes [

	^ super summaryAttributes 
		add: { #AutoRestartWorkers. autoRestart. self. };
		yourself.
]
