Class {
	#name : #GtRrStatusMessage,
	#superclass : #Object,
	#instVars : [
		'timestamp',
		'messageString',
		'sourceToolLabel'
	],
	#category : #'RemoteRunner-Status'
}

{ #category : #'instance creation' }
GtRrStatusMessage class >> fromJSONDictionary: aDictionary [
	^ self new  
		initializeFromJSONDictionary: aDictionary
]

{ #category : #accessing }
GtRrStatusMessage >> asDictionaryForExport [
	^ {
		'timestamp' -> self timestamp.
		'messageString' -> self messageString.
		'sourceToolLabel' -> self sourceToolLabel
	} asDictionary
]

{ #category : #initialization }
GtRrStatusMessage >> initialize [
	super initialize.
	
	timestamp := DateAndTime now
]

{ #category : #initialization }
GtRrStatusMessage >> initializeFromJSONDictionary: aDictionary [
	timestamp :=  aDictionary at: 'timestamp'.
	messageString :=  aDictionary at: 'messageString'.
	sourceToolLabel :=  aDictionary at: 'sourceToolLabel'.
]

{ #category : #accessing }
GtRrStatusMessage >> messageString [
	^ messageString
]

{ #category : #accessing }
GtRrStatusMessage >> messageString: aString [
	messageString := aString
]

{ #category : #printing }
GtRrStatusMessage >> printOn: aStream [
	super printOn: aStream.
	
	aStream parenthesize: [
		aStream
			<< self timestamp printToSeconds;
			<< ', ';
			<< ', ';
			<< self messageString]
]

{ #category : #accessing }
GtRrStatusMessage >> sourceToolLabel [
	^ sourceToolLabel
]

{ #category : #accessing }
GtRrStatusMessage >> sourceToolLabel: aString [
	sourceToolLabel := aString
]

{ #category : #accessing }
GtRrStatusMessage >> timestamp [
	^ timestamp
]

{ #category : #accessing }
GtRrStatusMessage >> timestamp: anObject [
	timestamp := anObject
]
