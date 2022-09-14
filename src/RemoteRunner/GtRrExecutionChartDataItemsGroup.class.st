Class {
	#name : #GtRrExecutionChartDataItemsGroup,
	#superclass : #Object,
	#traits : 'TGtGroup + TGtGroupItems',
	#classTraits : 'TGtGroup classTrait + TGtGroupItems classTrait',
	#instVars : [
		'label'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup class >> fromDictionary: aDictionary [
	^ (self withAll: 
		((aDictionary at: 'items') collect: [ :each | 
			GtRrExecutionChartDataItem fromDictionary: each]))
			label: (aDictionary at: 'label' ifAbsent: [ nil ])
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> asDictionary [ 
	^ Dictionary new 
		at: 'label' put: self label;
		at: 'items' put: (self items collect: #asDictionary as: Array);
		yourself
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> duration [
	^ self endTime - self startTime
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> endTime [ 

	^ self items
		inject: self items first endTime
		into: [ :endTime :anItem | 
			anItem endTime > endTime
				ifTrue: [ anItem endTime ]
				ifFalse: [ endTime ] ]
]

{ #category : #accessing }
GtRrExecutionChartDataItemsGroup >> inject: thisValue into: binaryBlock [ 
	^ self items 
		inject: thisValue into: binaryBlock 
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
	
	^ self items
		inject: self items first startTime
		into: [ :startTime :anItem | 
			anItem startTime < startTime
				ifTrue: [ anItem startTime ]
				ifFalse: [ startTime ] ]
]
