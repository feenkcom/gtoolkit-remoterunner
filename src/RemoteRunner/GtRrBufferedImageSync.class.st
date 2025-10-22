Class {
	#name : #GtRrBufferedImageSync,
	#superclass : #GtRrImageSync,
	#instVars : [
		'serializedChanges'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #accessing }
GtRrBufferedImageSync class >> leJsonV4Name [

	^ #gtRrBufferedImageSync
]

{ #category : #actions }
GtRrBufferedImageSync >> copyToFile: aFileReference [
	"Copy the receiver's serialised changes to the specified file"

	aFileReference writeStreamDo: [ :stream |
		stream nextPutAll: self serializedChanges ].
]

{ #category : #accessing }
GtRrBufferedImageSync >> entries: aCollection [
	"The omEntries are serialised individually and written to the buffer,
	not as a single collection."

	serializedChanges := String new: 200000 streamContents: [ :stream |
		self writeEntries: aCollection on: stream ].
	entriesCount := aCollection size.
]

{ #category : #private }
GtRrBufferedImageSync >> entriesReadStream [

	^ serializedChanges readStream
]

{ #category : #accessing }
GtRrBufferedImageSync >> serializedChanges [

	^ serializedChanges
]

{ #category : #accessing }
GtRrBufferedImageSync >> serializedChanges: anObject [

	serializedChanges := anObject
]

{ #category : #accessing }
GtRrBufferedImageSync >> serializedSize [

	^ serializedChanges
		ifNil: [ 0 ]
		ifNotNil: [ :buffer | buffer size ]
]
