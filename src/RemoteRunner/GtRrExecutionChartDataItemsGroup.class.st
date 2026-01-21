Class {
	#name : #GtRrExecutionChartDataItemsGroup,
	#superclass : #Object,
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#instVars : [
		'identifier',
		'label'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #serialization }
GtRrExecutionChartDataItemsGroup class >> leJsonV4Name [

	^ #gtRrExecutionChartDataItemsGroup
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> appendDurationToLabel [
	| newLabel |
	
	newLabel := String streamContents: [ :aStream |
		aStream 
			<< self label.
		(self endTime notNil and: [self startTime notNil])
			ifTrue: [
				aStream
					<< ' (';
					<< self duration gtShortPrintString;
					<< ')' ] ].
		
	self label: newLabel
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> duration [
	^ self endTime - self startTime
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> endTime [ 
	self items ifEmpty: [ ^ nil ].
	
	^ self items
		inject: self items first endTime
		into: [ :endTime :anItem | 
			(anItem endTime notNil and: [ anItem endTime  > endTime])
				ifTrue: [ anItem endTime ]
				ifFalse: [ endTime ] ]
]

{ #category : #'gt - extensions' }
GtRrExecutionChartDataItemsGroup >> gtItemsFor: aView [ 
	<gtView>
	
	^ aView forward 
		title: 'Items';
		object: [ self items ];
		view: #gtItemsFor:
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> identifier [

	^ identifier
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> identifier: anObject [

	identifier := anObject
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> inject: thisValue into: binaryBlock [ 
	^ self items 
		inject: thisValue into: binaryBlock 
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> items: anArray [ 
	self initializeWith: anArray
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> label [

	^ label
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> label: anObject [

	label := anObject
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> startTime [ 
	self items ifEmpty: [ ^ nil ].
	
	^ self items
		inject: self items first startTime
		into: [ :startTime :anItem | 
			(anItem startTime notNil and: [ anItem startTime < startTime])
				ifTrue: [ anItem startTime ]
				ifFalse: [ startTime ] ]
]
