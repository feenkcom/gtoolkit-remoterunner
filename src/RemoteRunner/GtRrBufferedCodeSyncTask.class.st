Class {
	#name : #GtRrBufferedCodeSyncTask,
	#superclass : #GtRrCodeSyncTask,
	#instVars : [
		'serializedChanges'
	],
	#category : #'RemoteRunner-Runner-CodeSync'
}

{ #category : #accessing }
GtRrBufferedCodeSyncTask class >> leJsonV4Name [

	^ #gtRrBufferedCodeSyncTask
]

{ #category : #accessing }
GtRrBufferedCodeSyncTask >> entries: aCollection [
	"The omEntries are serialised individually and written to the buffer,
	not as a single collection."

	serializedChanges := String new: 200000 streamContents: [ :stream |
		self writeEntries: aCollection on: stream ].
]

{ #category : #private }
GtRrBufferedCodeSyncTask >> entriesReadStream [

	^ serializedChanges readStream
]

{ #category : #accessing }
GtRrBufferedCodeSyncTask >> serializedChanges [

	^ serializedChanges
]

{ #category : #accessing }
GtRrBufferedCodeSyncTask >> serializedChanges: anObject [

	serializedChanges := anObject
]
