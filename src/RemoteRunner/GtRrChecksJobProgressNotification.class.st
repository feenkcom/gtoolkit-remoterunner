Class {
	#name : #GtRrChecksJobProgressNotification,
	#superclass : #GtRrJobProgressNotification,
	#instVars : [
		'failedChecksCount',
		'skippedChecksCount',
		'successfulChecksCount',
		'totalChecksCount',
		'erroredChecksCount'
	],
	#category : #'RemoteRunner-Jobs-Notifications'
}

{ #category : #adding }
GtRrChecksJobProgressNotification >> addTaskAnnouncement: anAnnouncement [

	self updateSummaryWithTaskResult: anAnnouncement taskResult.	
	super addTaskAnnouncement: anAnnouncement.
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> clearSummaryDetails [
	totalChecksCount := 0.
	erroredChecksCount := 0.
	failedChecksCount := 0.
	skippedChecksCount := 0.
	successfulChecksCount := 0.
]

{ #category : #'accessing - results' }
GtRrChecksJobProgressNotification >> collectChecksMatching: aBlock [
	| matchingChecks |
	matchingChecks := OrderedCollection  new.
	self taskResults do: [ :aTaskResult |
			matchingChecks addAll: (aTaskResult select: aBlock) ].
	^ matchingChecks 
]

{ #category : #'accessing - states' }
GtRrChecksJobProgressNotification >> constructStates [
	
	^ {
		(GtRrDataGroupState forNotification: self)
			name: 'All';
			itemCount: self totalChecksCount;
			itemsComputation: [ self job allExamples ].
		(GtRrDataGroupState forNotification: self)
			name: 'Success';
			testCaseState: GtPharoMethodTestCasePassedState;
			itemCount: self successfulChecksCount;
			itemsComputation: [ self successfulChecks ].
		(GtRrDataGroupState forNotification: self)
			name: 'Failure';
			testCaseState: GtPharoMethodTestCaseFailureState;
			itemCount: self failedChecksCount;
			itemsComputation: [ self failedChecks ].
		(GtRrDataGroupState forNotification: self)
			name: 'Error';
			testCaseState: GtPharoMethodTestCaseErrorState;
			itemCount: self erroredChecksCount;
			itemsComputation: [ self erroredChecks ].
		(GtRrDataGroupState forNotification: self)
			name: 'Skipped';
			testCaseState: GtPharoMethodTestCaseSkippedState;
			itemCount: self skippedChecksCount;
			itemsComputation: [ self job skippedExamples ].
		(GtRrDataGroupState forNotification: self)
			name: 'Executing';
			testCaseState: GtPharoMethodExecutingState;
			itemCount: self notExecutedChecksCount;
			itemsComputation: [ self job notExecutedExamples ]} 
]

{ #category : #'accessing - results' }
GtRrChecksJobProgressNotification >> erroredChecks [
	^ self collectChecksMatching: [ :aResult |
			aResult isError or: [ aResult isWarning ] ]
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> erroredChecksCount [

	^ erroredChecksCount
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> erroredChecksCount: anObject [

	erroredChecksCount := anObject
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> executedChecksCount [
	^ self successfulChecksCount 
		+ self erroredChecksCount
		+ self failedChecksCount
]

{ #category : #'accessing - results' }
GtRrChecksJobProgressNotification >> failedChecks [
	^ self collectChecksMatching: [ :aResult | aResult isFailure ]
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> failedChecksCount [

	^ failedChecksCount
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> failedChecksCount: anObject [

	failedChecksCount := anObject
]

{ #category : #'updating - summary' }
GtRrChecksJobProgressNotification >> incrementErrorChecksCountWith: anInteger [
	self erroredChecksCount: self erroredChecksCount + anInteger
]

{ #category : #'updating - summary' }
GtRrChecksJobProgressNotification >> incrementFailedChecksCountWith: anInteger [ 
	self failedChecksCount: self failedChecksCount + anInteger
]

{ #category : #'updating - summary' }
GtRrChecksJobProgressNotification >> incrementSkippedChecksCountWith: anInteger [ 
	self skippedChecksCount: self skippedChecksCount + anInteger
]

{ #category : #'updating - summary' }
GtRrChecksJobProgressNotification >> incrementSuccessfulChecksCountWith: anInteger [ 
	self successfulChecksCount: self successfulChecksCount + anInteger
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> job: aGtRrJob [
	
	self clearSummaryDetails.
	super job: aGtRrJob.
	
	self totalChecksCount: aGtRrJob totalExamplesCount
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> notExecutedChecksCount [
	^ self totalChecksCount 
		- (self successfulChecksCount 
			+ self erroredChecksCount
			+ self failedChecksCount
			+ self skippedChecksCount)
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> notificationLabel [
	^ 'Run Examples (', self job  state, ')'
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> runJobAgain [
	"Create a copy of the receiver's job and run it with progress notifications"
	| jobCopy |

	jobCopy := self job copy.
	jobCopy showExamplesProgressNotification.
	
	GtRemoteRunner default submitJob: jobCopy.
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> skippedChecksCount [

	^ skippedChecksCount
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> skippedChecksCount: anObject [

	skippedChecksCount := anObject
]

{ #category : #callbacks }
GtRrChecksJobProgressNotification >> spawnState: aGroupState fromSource: anElement [
	| computedItems targetItems |

	computedItems := aGroupState items.
	targetItems := (computedItems isKindOf: PharoLinkProxyObject)
		ifTrue: [ computedItems ]
		ifFalse: [(GtSearchFixedMethodsFilter new 
			methods: (computedItems
				collect: [ :aResult | aResult method ])) ].
	
	GtInspectorTool
		openWrappedOn: targetItems
		title: aGroupState name
		from: anElement 
]

{ #category : #'accessing - results' }
GtRrChecksJobProgressNotification >> successfulChecks [
	^ self collectChecksMatching: [ :aResult | aResult isSuccess ]
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> successfulChecksCount [

	^ successfulChecksCount
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> successfulChecksCount: anObject [

	successfulChecksCount := anObject
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> summaryClass [
	"Return a class that when instantiated displays the notification summary to the user"
	^ GtRrChecksJobNotificationSummary
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> totalChecksCount [

	^ totalChecksCount
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> totalChecksCount: anInteger [

	totalChecksCount := anInteger
]

{ #category : #'updating - summary' }
GtRrChecksJobProgressNotification >> updateSummaryWithTaskResult: aTaskResult [

	self incrementSuccessfulChecksCountWith: (aTaskResult count: [ :aResult | 
		aResult isSuccess ]).
	self incrementSkippedChecksCountWith: (aTaskResult count: [ :aResult | 
		aResult isSkipped ]).
	self incrementFailedChecksCountWith: (aTaskResult count: [ :aResult | 
		aResult isFailure ]).
	self incrementErrorChecksCountWith: (aTaskResult count: [ :aResult | 
		aResult isError or: [ aResult isWarning ] ]).
]
