"
A GtRrCodeSyncTask is sent to each code synced remote runner worker every time a change is made to the system's code.
"
Class {
	#name : #GtRrImageSync,
	#superclass : #Object,
	#instVars : [
		'entriesCount'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #'instance creation' }
GtRrImageSync class >> entries: aCollection [

	^ self new entries: aCollection
]

{ #category : #'instance creation' }
GtRrImageSync class >> forChanges: aCollection [
	"Answer the code sync task class based on the size of the changes.
	For 'small' changes use an in-memory buffer, for 'large' changes pass by file.
	See {{gtMethod:GtRrCodeSyncTask class>>#maxBufferedSize}} for the definition of 'small'."
	| approximateSize |

	approximateSize := aCollection sum: [ :anOmEntry |
		anOmEntry content gtRrApproximateSize ].
	^ approximateSize < self maxBufferedSize
		ifTrue: [ GtRrBufferedImageSync ]
		ifFalse: [ GtRrFileImageSync ].
]

{ #category : #accessing }
GtRrImageSync class >> leJsonV4Name [

	^ #gtRrImageSync
]

{ #category : #accessing }
GtRrImageSync class >> maxBufferedSize [
	^ 256000
]

{ #category : #actions }
GtRrImageSync >> copyToFile: aFileReference [
	"Copy the receiver's serialised changes to the specified file"

	self subclassResponsibility
]

{ #category : #accessing }
GtRrImageSync >> entries [
	"Answer the receiver's entries.
	This gathers the entries in to a single collection, which is normally only used for debugging."
	<return: #Array>
	| stonReader |

	stonReader := STONReader on: (self entriesReadStream
		ifNil: [ ^ #() ]).
	^ [ Array streamContents: [ :aStream |
		[ stonReader atEnd ] whileFalse:
			[ aStream nextPut: stonReader next ] ] ]
				ensure: [ stonReader close ].
]

{ #category : #accessing }
GtRrImageSync >> entries: aCollection [
	"Set the receiver's entries and entriesCount"
	
	self subclassResponsibility
]

{ #category : #accessing }
GtRrImageSync >> entriesCount [
	^ entriesCount
]

{ #category : #'private - serialization' }
GtRrImageSync >> entriesCount: anObject [
	entriesCount := anObject
]

{ #category : #accessing }
GtRrImageSync >> entriesReadStream [
	"Answer a readStream on the receiver's entries"
	
	^ self subclassResponsibility
]

{ #category : #'gt-extensions' }
GtRrImageSync >> gtChangesFor: aView [
	<gtView>
	| changes view |

	changes := self entries.
	changes ifEmpty: [ ^ aView empty ].
	view := changes isCollection
		ifTrue: [ #gtItemsFor: ]
		ifFalse: [ #gtLiveFor: ].
	^ aView forward
		title: 'Changes';
		priority: 20;
		object: [ changes ];
		view: view.
]

{ #category : #accessing }
GtRrImageSync >> serializedSize [

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrImageSync >> size [

	^ entriesCount ifNil: [ 0 ]
]

{ #category : #private }
GtRrImageSync >> writeEntries: aCollection on: aStream [

	aCollection do: [ :each | | omEntry |
		omEntry := each copy.
		omEntry content: omEntry content asGtRrCompactChange.
		STON put: omEntry onStream: aStream ].
]
