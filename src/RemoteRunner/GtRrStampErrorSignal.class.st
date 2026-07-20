Class {
	#name : #GtRrStampErrorSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'headers',
		'body'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #serialization }
GtRrStampErrorSignal class >> fromGtJsonDictionary: aDictionary [

	^ (super fromGtJsonDictionary: aDictionary)
		headers: (aDictionary at: 'stampErrorHeaders');
		body: (aDictionary at: 'stampErrorBody');
		yourself
]

{ #category : #'instance creation' }
GtRrStampErrorSignal class >> fromStampError: aStampError [
	^ self new
		message: aStampError messageText;
		headers: aStampError errorFrame headers copy;
		body: aStampError errorFrame body;
		yourself
]

{ #category : #serialization }
GtRrStampErrorSignal >> asGtJsonLogDictionary [

	^ super asGtJsonLogDictionary
		at: 'stampErrorHeaders' put: headers;
		at: 'stampErrorBody' put: body;
		yourself
]

{ #category : #accessing }
GtRrStampErrorSignal >> body [
	^ body
]

{ #category : #accessing }
GtRrStampErrorSignal >> body: anObject [
	body := anObject
]

{ #category : #accessing }
GtRrStampErrorSignal >> headers [
	^ headers
]

{ #category : #accessing }
GtRrStampErrorSignal >> headers: aDictionary [
	headers := aDictionary
]

{ #category : #printing }
GtRrStampErrorSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< self message asString
]
