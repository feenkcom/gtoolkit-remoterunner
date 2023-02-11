Class {
	#name : #GtRrUnknownOmReference,
	#superclass : #Error,
	#instVars : [
		'omReference',
		'source'
	],
	#category : #'RemoteRunner-Exceptions'
}

{ #category : #'instance creation' }
GtRrUnknownOmReference class >> omReference: anOmReference source: aSource [

	^ self new
		initializeOmReference: anOmReference
		source: aSource
]

{ #category : #accessing }
GtRrUnknownOmReference >> description [

	^ String streamContents: [ :stream |
		stream
			<< 'Unknown reference: ';
			<< omReference gtDisplayString;
			<< ' in: ';
			print: source ].
]

{ #category : #ui }
GtRrUnknownOmReference >> gtSessionHistoryFor: aView [
	<gtView>

	source ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Session History';
		priority: 20;
		object: [ source ];
		view: #gtSessionHistoryFor:
]

{ #category : #'initialize - release' }
GtRrUnknownOmReference >> initializeOmReference: anOmReference source: aSource [

	omReference := anOmReference.
	source := aSource.
]

{ #category : #accessing }
GtRrUnknownOmReference >> messageText [

	^ String streamContents: [ :stream |
		self printOn: stream.
		messageText ifNotNil:
			[ stream
				<< ': ';
				print: messageText ] ]
]
