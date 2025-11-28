"
GtRrCodeSync is responsible for listening to the Epicea Monitor ({{gtClass:EpMonitor}}) and submitting code sync tasks to each of the synced workers when any code change is made.
"
Class {
	#name : #GtRrCodeSync,
	#superclass : #Object,
	#instVars : [
		'events',
		'subscription',
		'flusher',
		'remoteRunner',
		'systemAnnouncements',
		'mutex'
	],
	#category : 'RemoteRunner-Runner-CodeSync'
}

{ #category : #accessing }
GtRrCodeSync >> createOmbuEntryForEvent: anEpiceaEvent [ 
	| entry newReference |
	entry := OmEntry content: anEpiceaEvent.

	newReference := OmReference 
		globalName: 'ExpressionEvaluation'
		localName: UUID new asString36.
	
	entry tags 
		at: OmStore selfReferenceKey put: newReference;
		at: EpLog timeKey put: DateAndTime now.
	
	^entry
]

{ #category : #finalization }
GtRrCodeSync >> finalize [

	self stop.
	super finalize
]

{ #category : #accessing }
GtRrCodeSync >> flush [
	mutex critical:  [
		| buffer job |
		buffer := OrderedCollection new.
		events flush: [:event | buffer add: event].
		buffer ifEmpty: [
			"nothing to send, ignore" ^self].
		job := remoteRunner submitJob: 
			(GtRrCodeSyncJob entries: buffer).
		GtRrCodeSyncJobSignal new
			job: job;
			emit. ].
]

{ #category : #initialization }
GtRrCodeSync >> initialize [

	super initialize.
	"events is a queue of OmEntries"
	events := WaitfreeQueue new.
	flusher := TKTNewProcessTaskRunner new.
	mutex := Semaphore forMutualExclusion.
]

{ #category : #testing }
GtRrCodeSync >> isEmpty [

	^ events isEmpty
]

{ #category : #'as yet unclassified' }
GtRrCodeSync >> mutex [
	^mutex
]

{ #category : #accessing }
GtRrCodeSync >> onEntryAdded: anEntryAddedEvent [

	anEntryAddedEvent entry content isCodeChange ifFalse: 
		[ "only capture code changes" 
		^ self ].
	events nextPut: anEntryAddedEvent entry.
	flusher schedule: [ self flush ]
]

{ #category : #accessing }
GtRrCodeSync >> onExpressionEvaluated: anExpressionEvaluated [
	events nextPut: (self createOmbuEntryForEvent:(EpExpressionEvaluation 
		expression: anExpressionEvaluated expressionEvaluated)).
	flusher schedule: [ self flush ]
]

{ #category : #accessing }
GtRrCodeSync >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrCodeSync >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #accessing }
GtRrCodeSync >> start [

	subscription ifNil: [ 
		subscription := EpMonitor current log announcer
			                when: EpEntryAdded
			                send: #onEntryAdded:
			                to: self ].
	systemAnnouncements ifNil: [
		systemAnnouncements := SystemAnnouncer uniqueInstance weak
							when: ExpressionEvaluated 
							send: #onExpressionEvaluated: 
							to: self ].
]

{ #category : #accessing }
GtRrCodeSync >> stop [

	subscription ifNotNil: [ 
		subscription announcer removeSubscription: subscription.
		subscription := nil ].
	systemAnnouncements ifNotNil: [
		SystemAnnouncer uniqueInstance unsubscribe: self.
		systemAnnouncements := nil ].
]
