Class {
	#name : #GtRrTimestampedChartDataItem,
	#superclass : #Object,
	#instVars : [
		'timestamp',
		'data'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #serialization }
GtRrTimestampedChartDataItem class >> leJsonV4Name [

	^ #gtRrTimestampedChartDataItem
]

{ #category : #accessing }
GtRrTimestampedChartDataItem >> data [

	^ data
]

{ #category : #accessing }
GtRrTimestampedChartDataItem >> data: anObject [

	data := anObject
]

{ #category : #accessing }
GtRrTimestampedChartDataItem >> timestamp [

	^ timestamp
]

{ #category : #accessing }
GtRrTimestampedChartDataItem >> timestamp: anObject [

	timestamp := anObject
]
