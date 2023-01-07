"
GtRrTaskExecutionResult holds the result and execution data for a task, allowing the information to be transferred over the network and held without requiring a proxy to the task itself.
"
Class {
	#name : #GtRrTaskExecutionResult,
	#superclass : #Object,
	#instVars : [
		'taskResult',
		'executionData',
		'taskId'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrTaskExecutionResult class >> leJsonV4Name [

	^ #gtRrTaskExecutionResult
]

{ #category : #enumerating }
GtRrTaskExecutionResult >> count: aBlockClosure [

	taskResult ifNil: [ ^ 0 ].
	^ taskResult 
		count: aBlockClosure
]

{ #category : #accessing }
GtRrTaskExecutionResult >> description [
	^ (String streamContents: [ :aStream |
		aStream 
			print: self totalCount;
			<< ' ';
			<< (self totalCount = 1 
				ifTrue: [ 'check' ] ifFalse: [ 'checks' ]);
			<< ' (';
			<< self stateDescription;
			<< ')  ' ])
]

{ #category : #accessing }
GtRrTaskExecutionResult >> duration [
	^ self executionData duration
]

{ #category : #accessing }
GtRrTaskExecutionResult >> durationOnRunner [
	^ self executionData durationOnRunner
]

{ #category : #accessing }
GtRrTaskExecutionResult >> endTime [

	^ self executionData endTime
]

{ #category : #accessing }
GtRrTaskExecutionResult >> errorDetails [
	<return: #GtRrErrorDetails>

	^ self executionData errorDetails
]

{ #category : #accessing }
GtRrTaskExecutionResult >> executionData [

	^ executionData
]

{ #category : #accessing }
GtRrTaskExecutionResult >> executionData: anObject [

	executionData := anObject
]

{ #category : #'accessing - gc details' }
GtRrTaskExecutionResult >> fullGcTime [
	^ self 
		resourceReportIfPresent: [ :aReport | aReport fullGcTimeDiff ] 
		ifAbsent: [ nil ]
]

{ #category : #'gt - extensions' }
GtRrTaskExecutionResult >> gtViewChecksListFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Test Results';
		items: [ self taskResult];
		column: 'Test' text: [ :aResult |
			String streamContents: [ :aStream |
				aStream
					nextPutAll: aResult testCaseClassName asString;
					nextPutAll: '>>#';
					nextPutAll: aResult testCaseSelector ] ];
		column: 'State' text: [ :aResult | aResult shortName ] width: 150;
		column: 'Duration' text: [ :aResult | aResult duration ] width: 150
]

{ #category : #accessing }
GtRrTaskExecutionResult >> handoverTime [

	^ self executionData handoverTime
]

{ #category : #testing }
GtRrTaskExecutionResult >> hasCompleted [

	^ self executionData hasCompleted
]

{ #category : #testing }
GtRrTaskExecutionResult >> hasErrors [
	"Answer a boolean indicating if the receiver failed to execute successfully"

	^ self errorDetails notNil
]

{ #category : #'accessing - gc details' }
GtRrTaskExecutionResult >> incrGcTime [
	^ self 
		resourceReportIfPresent: [ :aReport | aReport incrGcTimeDiff ] 
		ifAbsent: [ nil ]
]

{ #category : #testing }
GtRrTaskExecutionResult >> isErrorResult: aPharoLinkTestCaseResult [
	^ aPharoLinkTestCaseResult isError or: [
		aPharoLinkTestCaseResult isWarning ]
]

{ #category : #testing }
GtRrTaskExecutionResult >> isFinished [

	^ self endTime notNil
]

{ #category : #testing }
GtRrTaskExecutionResult >> isSuccessResult: aPharoLinkTestCaseResult [
	^ aPharoLinkTestCaseResult isSuccess "or: [ 
		aPharoLinkTestCaseResult isSkipped ]"
]

{ #category : #'accessing - resource report' }
GtRrTaskExecutionResult >> machineAvailableMemory [  
	^ self
		resourceReportIfPresent: [ :aReport | 
			aReport machineAvailableMemory ] 
		ifAbsent: [ nil ]
]

{ #category : #'accessing - dynamic' }
GtRrTaskExecutionResult >> numberOfErrors [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		self isErrorResult: pharoLinkTestCaseAnnouncement ]
]

{ #category : #'accessing - dynamic' }
GtRrTaskExecutionResult >> numberOfFailures [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isFailure ]
]

{ #category : #'accessing - dynamic' }
GtRrTaskExecutionResult >> numberOfSkips [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isSkipped ]
]

{ #category : #'accessing - dynamic' }
GtRrTaskExecutionResult >> numberOfSuccesses [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		self isSuccessResult: pharoLinkTestCaseAnnouncement ]
]

{ #category : #printing }
GtRrTaskExecutionResult >> printSupplementalOn: aStream [

	aStream << self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].

]

{ #category : #'accessing - resource report' }
GtRrTaskExecutionResult >> resourceReportIfPresent: aPresentBlock ifAbsent: anAbsentBlock [
	^ self executionData resourceReport 
		ifNil: [ anAbsentBlock value ]
		ifNotNil: [ :report | aPresentBlock cull: report ]
]

{ #category : #accessing }
GtRrTaskExecutionResult >> resultReceivedTime [

	^ self executionData resultReceivedTime
]

{ #category : #accessing }
GtRrTaskExecutionResult >> startTime [

	^ self executionData startTime
]

{ #category : #accessing }
GtRrTaskExecutionResult >> state [
	^ self executionData state
]

{ #category : #printing }
GtRrTaskExecutionResult >> stateDescription [
	^ String streamContents: [ :aStream |
		self printSupplementalOn: aStream ]
]

{ #category : #printing }
GtRrTaskExecutionResult >> supplementalDescription [
	^ String streamContents: [ :aStream |
		self printSupplementalOn: aStream ]
]

{ #category : #accessing }
GtRrTaskExecutionResult >> taskId [

	^ taskId
]

{ #category : #accessing }
GtRrTaskExecutionResult >> taskId: anId [

	taskId := anId
]

{ #category : #accessing }
GtRrTaskExecutionResult >> taskResult [

	^ taskResult
]

{ #category : #accessing }
GtRrTaskExecutionResult >> taskResult: anObject [

	taskResult := anObject
]

{ #category : #accessing }
GtRrTaskExecutionResult >> totalCount [
	"Answer the total number of examples / tests in the receiver"
	
	^ taskResult
		ifNil: [ 0 ] 
		ifNotNil: [ taskResult size ]
]

{ #category : #'accessing - gc details' }
GtRrTaskExecutionResult >> totalGCTime [
	^ self 
		resourceReportIfPresent: [ :aReport | aReport totalGcTimeDiff ] 
		ifAbsent: [ nil ]
]

{ #category : #'accessing - resource report' }
GtRrTaskExecutionResult >> vmMaximumMemorySize [  
	^ self
		resourceReportIfPresent: [ :aReport | 
			aReport vmMaximumMemorySize ] 
		ifAbsent: [ nil ]
]

{ #category : #'accessing - resource report' }
GtRrTaskExecutionResult >> vmMinimumMemorySize [  
	^ self
		resourceReportIfPresent: [ :aReport | 
			aReport vmMinimumMemorySize ] 
		ifAbsent: [ nil ]
]

{ #category : #'accessing - resource report' }
GtRrTaskExecutionResult >> vmStatisticsAtCompletion [  
	^ self
		resourceReportIfPresent: [ :aReport | 
			aReport targetReport ] 
		ifAbsent: [ nil ]
]

{ #category : #'accessing - resource report' }
GtRrTaskExecutionResult >> vmStatisticsAtStart [
	^ self
		resourceReportIfPresent: [ :aReport | 
			aReport sourceReport ] 
		ifAbsent: [ nil ]
]

{ #category : #accessing }
GtRrTaskExecutionResult >> workerAttributes [
	^ self executionData workerAttributes
]

{ #category : #accessing }
GtRrTaskExecutionResult >> workerId [
	^ self executionData workerId
]

{ #category : #accessing }
GtRrTaskExecutionResult >> workerIpAddress [
	^ self executionData workerIpAddress
]
