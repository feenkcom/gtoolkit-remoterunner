"
{{gtClass:GtRrExecutionChartDataItem}} is an object that captutes the data needed by {{gtClass:name=GtRrTasksExecutionHorizontalChartStencil}} about a task. 

It provides the same API as a task, and it is meant to be used polymorphically with tasks when the tasks reside inside different images. Users can serialize the task data and send it back as instances of this class.
"
Class {
	#name : #GtRrExecutionChartDataItem,
	#superclass : #Object,
	#instVars : [
		'identifier',
		'label',
		'startTime',
		'endTime',
		'properties',
		'cachedDuration'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'instance - creation' }
GtRrExecutionChartDataItem class >> fromMachine: aMachine [
	^ self new 
		identifier: aMachine ipAddress;
		startTime: aMachine tasksFirstHandoveTime;
		endTime: aMachine tasksLastResultReceivedTime;
		label:  aMachine description
]

{ #category : #'instance - creation' }
GtRrExecutionChartDataItem class >> fromTask: aTask [
	^ self new 
		identifier: aTask taskId;
		startTime: aTask handoverTime;
		endTime: aTask resultReceivedTime;
		label:  aTask description
]

{ #category : #'instance - creation' }
GtRrExecutionChartDataItem class >> fromWorker: aWorker [
	^ self new 
		identifier: aWorker workerId;
		startTime: aWorker tasksFirstHandoveTime;
		endTime: aWorker tasksLastResultReceivedTime;
		label:  aWorker description
]

{ #category : #serialization }
GtRrExecutionChartDataItem class >> leJsonV4AttributeMapping [

	^ OrderedCollection new
		add: #identifier -> #identifier;
		add: #label -> #label;
		add: #startTime -> #startTime;
		add: #endTime -> #endTime;
		add: #properties -> #properties;
		yourself.
]

{ #category : #serialization }
GtRrExecutionChartDataItem class >> leJsonV4Name [

	^ #gtRrExecutionChartDataItem
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> appendDurationToLabel [
	| newLabel |
	
	newLabel := String streamContents: [ :aStream |
		aStream 
			<< self label;
			<< ' (';
			<< (self duration 
				ifNil: [ '<missing>']
				ifNotNil: [ :aDuration | aDuration gtShortPrintString]);
			<< ')' ].
		
	self label: newLabel
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> duration [
	^ cachedDuration ifNil: [
		(self endTime isNil or: [self startTime isNil ]) 
			ifTrue: [ nil ]
			ifFalse: [
				cachedDuration := self endTime - self startTime ] ]
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> endTime [ 
	^ endTime
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> gtPropertiesFor: aView [
	<gtView>

	properties ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Properties';
		priority: 40;
		object: [ properties ];
		view: #gtLiveFor:
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> identifier [

	^ identifier
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> identifier: anObject [

	identifier := anObject
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> label [

	^ label
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> label: anObject [

	label := anObject
]

{ #category : #printing }
GtRrExecutionChartDataItem >> printOn: aStream [ 
	super printOn: aStream .
	
	aStream parenthesize: [
		{ self identifier . self label . self duration } 
			asStringOn: aStream delimiter: ', ' ]
]

{ #category : #'accessing - properties' }
GtRrExecutionChartDataItem >> properties [

	^ properties
]

{ #category : #'accessing - properties' }
GtRrExecutionChartDataItem >> properties: anObject [

	properties := anObject
]

{ #category : #'accessing - properties' }
GtRrExecutionChartDataItem >> propertyAt: aKey ifAbsent: anAbsentBloc [
	properties ifNil: [
		^ anAbsentBloc value ].
	
	^ properties at: aKey ifAbsent: anAbsentBloc
]

{ #category : #'accessing - properties' }
GtRrExecutionChartDataItem >> propertyAt: aKey put: aValue [
	properties ifNil: [
		properties := Dictionary new].
		
	properties at: aKey put: aValue
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> startTime [

	^ startTime
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> startTime: anObject [

	startTime := anObject
]
