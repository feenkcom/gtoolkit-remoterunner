"
GtRrCodeSyncFailed is signalled on the runner when code sync to one or more of the workers failed.
"
Class {
	#name : #GtRrCodeSyncFailed,
	#superclass : #Error,
	#instVars : [
		'job',
		'codeSync'
	],
	#category : #'RemoteRunner-Exceptions'
}

{ #category : #signaling }
GtRrCodeSyncFailed class >> signalJob: aGtRrJob codeSync: aGtRrCodeSync [

	^ self new
		job: aGtRrJob;
		codeSync: aGtRrCodeSync;
		signal.
]

{ #category : #accessing }
GtRrCodeSyncFailed >> codeSync [
	^ codeSync
]

{ #category : #accessing }
GtRrCodeSyncFailed >> codeSync: anObject [
	codeSync := anObject
]

{ #category : #'private - accessing' }
GtRrCodeSyncFailed >> explanationText [

	^ 'There has been an error during code synchronisation to one or more of the workers attached to the receiver''s remote runner.
	
	You should stop or restart the runner using the button above before doing any further work as the workers are in an inconsistent state and may return incorrect results.
	
	The runner is still active to allow for debugging.'.
]

{ #category : #'as yet unclassified' }
GtRrCodeSyncFailed >> gtExplanationViewFor: aView [
	<gtView>
	<gtExceptionView>
	
	^ aView text
		title: 'Code Sync Failure';
		priority: 10;
		text: [ self explanationText ];
		actionButtonIcon: BrGlamorousVectorIcons stop
			label: 'Stop'
			tooltip: 'Stop the runner'
			action: [ self stopRunner ];
		actionButtonIcon: BrGlamorousVectorIcons restart
			label: 'Restart'
			tooltip: 'Restart the runner'
			action: [ self restartRunner ];
		actionButtonIcon: BrGlamorousVectorIcons inspect
			label: 'Job'
			tooltip: 'Inspect the failing job'
			action: [ :button | 
				button phlow spawnObject: job ]. 
]

{ #category : #accessing }
GtRrCodeSyncFailed >> job [
	^ job
]

{ #category : #accessing }
GtRrCodeSyncFailed >> job: anObject [
	job := anObject
]

{ #category : #accessing }
GtRrCodeSyncFailed >> remoteRunner [

	^ codeSync remoteRunner
]

{ #category : #'private - actions' }
GtRrCodeSyncFailed >> restartRunner [

	self stopRunner.
	self remoteRunner start.
]

{ #category : #'private - actions' }
GtRrCodeSyncFailed >> stopRunner [
	| count |

	self remoteRunner stop.
	count := 0.
	[ self remoteRunner registeredWorkerCount > 0 and: [ count < 10 ] ] whileTrue:
		[ 1 second wait.
		count := count + 1. ].
	self remoteRunner registeredWorkerCount > 0
		ifTrue: [ self error: 'Unable to stop remote runner' ].
]
