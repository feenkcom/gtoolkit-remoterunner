Class {
	#name : #GtRrExampleResultWithTask,
	#superclass : #Object,
	#instVars : [
		'exampleResult',
		'task'
	],
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
GtRrExampleResultWithTask >> exampleResult [

	^ exampleResult
]

{ #category : #accessing }
GtRrExampleResultWithTask >> exampleResult: anObject [

	exampleResult := anObject
]

{ #category : #accessing }
GtRrExampleResultWithTask >> exceptionMessageText [
	^ self exampleResult exceptionMessageText
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTask >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item key ];
		  column: #Value text: [ :item | item value ];
		  actionUpdateButton
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTask >> gtTestCaseFor: aView [
	<gtView>
	
	(exampleResult notNil and: [
		exampleResult isKindOf: PharoLinkTestCaseAnnouncement ]) ifFalse: [
			^ aView empty ].
	
	^ aView forward
		  title: 'Test case';
		  priority: 10;
		  object: [ exampleResult ];
		  view: #gtTestCaseFor:
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTask >> gtTraceFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'Trace';
		priority: 15;
		view: #gtTraceFor:;
		object: [ self exampleResult]
]

{ #category : #accessing }
GtRrExampleResultWithTask >> gtViewExternalMemReportFor: aView [
	<gtView>

	task executionData resourceReport externalMemReport ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'External Memory';
		priority: 45;
		object: [ task executionData resourceReport externalMemReport ];
		view: #gtTableFor:
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTask >> gtViewMessageTallyFor: aView [ 
	<gtView>
	
	self exampleResult messageTallyReport 
		ifNil: [ ^ aView empty ].
		
	^ aView forward 
		title: 'Message Tally';
		priority: 50;
		object: [ self exampleResult messageTallyReport ];
		view: #gtViewReportOn:
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTask >> gtViewWorkerAttributesFor: aView [
	<gtView>
	
	self task ifNil: [ ^ aView empty ].
	
	^ aView forward 
		title: 'Worker attributes';
		priority: 40;
		object: [ self task ];
		view: #gtViewWorkerAttributesFor:
]

{ #category : #printing }
GtRrExampleResultWithTask >> printOn: aStream [
	self exampleResult ifNil: [ ^ super printOn: aStream ].
	
	^ self exampleResult printOn: aStream
]

{ #category : #accessing }
GtRrExampleResultWithTask >> providerClass [
	^ self exampleResult providerClass
]

{ #category : #accessing }
GtRrExampleResultWithTask >> resourceReport [
	^ exampleResult resourceReport
]

{ #category : #accessing }
GtRrExampleResultWithTask >> summaryAttributes [
	^ self exampleResult summaryAttributes, {
		'Task' -> self task.
		'Task Id' -> self task taskId }
]

{ #category : #accessing }
GtRrExampleResultWithTask >> task [

	^ task
]

{ #category : #accessing }
GtRrExampleResultWithTask >> task: anObject [

	task := anObject
]

{ #category : #accessing }
GtRrExampleResultWithTask >> taskId [

	^ task taskId
]

{ #category : #accessing }
GtRrExampleResultWithTask >> workerMachineRegion [
	^ self task workerMachineRegion
]

{ #category : #accessing }
GtRrExampleResultWithTask >> workerMachineType [
	^ self task workerMachineType
]
