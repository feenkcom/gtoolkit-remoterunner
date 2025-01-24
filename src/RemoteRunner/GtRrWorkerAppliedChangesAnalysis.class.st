Class {
	#name : #GtRrWorkerAppliedChangesAnalysis,
	#superclass : #Object,
	#instVars : [
		'workerLabel',
		'appliedChangesEvents'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #'instance creation' }
GtRrWorkerAppliedChangesAnalysis class >> fromWorkerEvents: anEventsGroup labeled: aWorkerLabel [
	^self new 
		initializeFromWorkerEvents: anEventsGroup
		labeled: aWorkerLabel
]

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis class >> fromWorkerLogFile: aLogFile [
	^self new 
		initializeFromWorkerLogFile: aLogFile
]

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis class >> fromWorkerSignals: aCollectionOfSignals labeled: aWorkerLabel [
	| workerEvents |
	workerEvents := (GtRrWorkerLogAnalysis new
		strictMode: true;
		signals:  aCollectionOfSignals;
		logEvent) subEvents.

	^self 
		fromWorkerEvents:  workerEvents
		labeled: aWorkerLabel
]

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis >> changesHash [
	^ appliedChangesEvents referencesHash
]

{ #category : #views }
GtRrWorkerAppliedChangesAnalysis >> gViewwChangesFor: aView [
	<gtView>
	^(aView forward)
		title: 'Changes';
		object: [appliedChangesEvents];
		view: #gtViewChangesFor:
]

{ #category : #initialization }
GtRrWorkerAppliedChangesAnalysis >> initializeFromWorkerEvents: anEventsGroup labeled: aWorkerLabel [
	appliedChangesEvents := GtRrWorkerAppliedChangesGroup 
		withAll: (self selectAppliyChangesEventsFrom:  anEventsGroup ).
	workerLabel := aWorkerLabel
]

{ #category : #initialization }
GtRrWorkerAppliedChangesAnalysis >> initializeFromWorkerLogFile: aLogFile [
	self 
		initializeFromWorkerEvents: aLogFile logEvent subEvents
		labeled: aLogFile fileReference basename
]

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis >> numberOfCodeSyncChanges [
	^appliedChangesEvents count: [ :anEvent | 
		anEvent class = GtRrCodeSyncApplyChangeLogEvent ]
]

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis >> numberOfInitiallyReplayedChanges [
	^appliedChangesEvents count: [ :anEvent | 
		anEvent class = GtRrWorkerApplyChangeLogEvent ]
]

{ #category : #printing }
GtRrWorkerAppliedChangesAnalysis >> printOn: aStream [

	super printOn: aStream.
	aStream parenthesize: [
		aStream 
			<< workerLabel
			<< ' - ';
			print: self totalNumberOfChanges;
			<< ' changes (';
			print: self numberOfInitiallyReplayedChanges;
			<< ' initially replayed,';
			print: self numberOfCodeSyncChanges;
			<< ' code sync replayed)' ]
]

{ #category : #initialization }
GtRrWorkerAppliedChangesAnalysis >> selectAppliyChangesEventsFrom: anEventsGroup [	
 	^(anEventsGroup select: [ :anEvent |
		anEvent class = GtRrCodeSyncApplyChangeLogEvent or: [
			anEvent class = GtRrWorkerApplyChangeLogEvent ] ])
]

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis >> totalDuration [
	^appliedChangesEvents totalDuration
]

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis >> totalNumberOfChanges [
	^appliedChangesEvents size
]

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis >> workerLabel [
	^workerLabel
]
