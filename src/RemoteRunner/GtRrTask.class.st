Class {
	#name : #GtRrTask,
	#superclass : #Object,
	#instVars : [
		'startTime',
		'endTime',
		'workerIpAddress',
		'result',
		'taskId',
		'errorDetails'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
GtRrTask class >> leJsonV4Name [

	^ #remoteRunnerWorkerTask
]

{ #category : #accessing }
GtRrTask >> endTime [

	^ endTime
]

{ #category : #accessing }
GtRrTask >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrTask >> errorDetails [

	^ errorDetails
]

{ #category : #accessing }
GtRrTask >> errorDetails: anObject [

	errorDetails := anObject
]

{ #category : #ui }
GtRrTask >> gtResultFor: aView [

	<gtView>
	result ifNil: [ ^ aView empty ].

	^ aView forward
		  title: 'Result';
		  priority: 20;
		  object: [ result ];
		  actionUpdateButton
]

{ #category : #ui }
GtRrTask >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item key ];
		  column: #Value text: [ :item | item value ];
		  actionUpdateButton
]

{ #category : #testing }
GtRrTask >> hasErrors [
	"Answer a boolean indicating if the receiver failed to execute successfully"

	^ errorDetails isNotNil
]

{ #category : #accessing }
GtRrTask >> initialize [

	super initialize.
	taskId := UUID new asString
]

{ #category : #running }
GtRrTask >> markTaskCompleted [

	endTime := DateAndTime now.
]

{ #category : #running }
GtRrTask >> markTaskStarted [

	startTime := DateAndTime now.
]

{ #category : #accessing }
GtRrTask >> result [

	^ result
]

{ #category : #accessing }
GtRrTask >> result: anObject [

	result := anObject
]

{ #category : #accessing }
GtRrTask >> run [

	self subclassResponsibility
]

{ #category : #accessing }
GtRrTask >> startTime [

	^ startTime
]

{ #category : #accessing }
GtRrTask >> startTime: anObject [

	startTime := anObject
]

{ #category : #accessing }
GtRrTask >> state [
	"Answer a Symbol indicating the inferred state of the receiver"

	startTime ifNil: [ ^ #notStarted ].
	endTime ifNil: [ ^ #running ].
	^ #completed
]

{ #category : #ui }
GtRrTask >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream |
		stream nextPut: #State -> self state.
		startTime ifNotNil:
			[ stream nextPut: #Started -> startTime ].
		endTime ifNotNil:
			[ stream nextPut: #Ended -> endTime ].
		stream nextPut: #ID -> taskId.
		stream nextPut: 'Worker IP Address' -> workerIpAddress ]
]

{ #category : #accessing }
GtRrTask >> taskId [

	^ taskId
]

{ #category : #accessing }
GtRrTask >> taskId: anObject [

	taskId := anObject
]

{ #category : #accessing }
GtRrTask >> workerIpAddress [

	^ workerIpAddress
]

{ #category : #accessing }
GtRrTask >> workerIpAddress: anObject [

	workerIpAddress := anObject
]
