Class {
	#name : #GtRrExampleResultWithTask,
	#superclass : #Object,
	#instVars : [
		'exampleResult',
		'task'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExampleResultWithTask >> exampleResult [

	^ exampleResult
]

{ #category : #accessing }
GtRrExampleResultWithTask >> exampleResult: anObject [

	exampleResult := anObject
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
GtRrExampleResultWithTask >> gtTraceFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'Trace';
		priority: 15;
		view: #gtTraceFor:;
		object: [ self exampleResult]
]

{ #category : #printing }
GtRrExampleResultWithTask >> printOn: aStream [
	self exampleResult ifNil: [ ^ super printOn: aStream ].
	
	^ self exampleResult printOn: aStream
]

{ #category : #accessing }
GtRrExampleResultWithTask >> summaryAttributes [
	^ self exampleResult summaryAttributes, {
		'Task' -> self task }
]

{ #category : #accessing }
GtRrExampleResultWithTask >> task [

	^ task
]

{ #category : #accessing }
GtRrExampleResultWithTask >> task: anObject [

	task := anObject
]
