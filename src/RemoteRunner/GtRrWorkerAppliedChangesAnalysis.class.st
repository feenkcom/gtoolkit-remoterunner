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

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis >> changesWithIndexHash [
	^ appliedChangesEvents referencesWithIndexHash
]

{ #category : #accessing }
GtRrWorkerAppliedChangesAnalysis >> codeSyncChanges [
	^appliedChangesEvents select: [ :anEvent | 
		anEvent class = GtRrCodeSyncApplyChangeLogEvent ]
]

{ #category : #views }
GtRrWorkerAppliedChangesAnalysis >> gtOverviewFor: aView [
	<gtView>

	^ aView columnedList
		title: 'Overview';
		priority: 5;
		items:  [ self overviewData ];
		column: 'Name' text: [ :each | each first ];
		column: 'Value' text: [ :each | each second ];
		send: [ :each | each third ]
]

{ #category : #views }
GtRrWorkerAppliedChangesAnalysis >> gViewChangesFor: aView [
	<gtView>
	^(aView forward)
		title: 'All Changes';
		priority: 25;
		object: [appliedChangesEvents];
		view: #gtViewChangesFor:
]

{ #category : #views }
GtRrWorkerAppliedChangesAnalysis >> gViewCodeSyncChangesFor: aView [
	<gtView>
	^(aView forward)
		title: 'Code Sync Changes';
		priority: 15;
		object: [self codeSyncChanges];
		view: #gtViewChangesFor:
]

{ #category : #views }
GtRrWorkerAppliedChangesAnalysis >> gViewInitiallyReplayedChangesFor: aView [
	<gtView>
	^(aView forward)
		title: 'Initial Changes';
		priority: 10;
		object: [self initiallyReplayedChanges];
		view: #gtViewChangesFor:
]

{ #category : #testing }
GtRrWorkerAppliedChangesAnalysis >> hasOutOfOrderChanges [
	^appliedChangesEvents hasOutOfOrderChanges
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
GtRrWorkerAppliedChangesAnalysis >> initiallyReplayedChanges [
	^appliedChangesEvents select: [ :anEvent | 
		anEvent class = GtRrWorkerApplyChangeLogEvent ]
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

{ #category : #views }
GtRrWorkerAppliedChangesAnalysis >> overviewData [
	^{
		{'Worker'. self workerLabel. self workerLabel}.
		{'Initially Replayed Changes'. self numberOfInitiallyReplayedChanges. self initiallyReplayedChanges}.
		{'Synchronized Changes'. self numberOfCodeSyncChanges. self codeSyncChanges}.
		{'Total Duration'. self totalDuration. self totalDuration}.
		{'Has out-of-order Changes'. self hasOutOfOrderChanges. self hasOutOfOrderChanges}.
		{'Changes with Index Hash' . self changesWithIndexHash base64Encoded. self changesWithIndexHash}.
		{'Changes Hash' . self changesHash base64Encoded. self changesHash}.
	}
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
