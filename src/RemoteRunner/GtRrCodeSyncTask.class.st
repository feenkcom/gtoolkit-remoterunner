"
A GtRrCodeSyncTask is sent to each code synced remote runner worker every time a change is made to the system's code.
"
Class {
	#name : #GtRrCodeSyncTask,
	#superclass : #GtRrTask,
	#category : #'RemoteRunner-Runner-CodeSync'
}

{ #category : #'instance creation' }
GtRrCodeSyncTask class >> entries: aCollection [

	^ self new entries: aCollection
]

{ #category : #'instance creation' }
GtRrCodeSyncTask class >> forChanges: aCollection [
	"Answer the code sync task class based on the size of the changes.
	For 'small' changes use an in-memory buffer, for 'large' changes pass by file.
	See {{gtMethod:GtRrCodeSyncTask class>>#maxBufferedSize}} for the definition of 'small'."
	| approximateSize |

	approximateSize := aCollection sum: [ :anOmEntry |
		anOmEntry content gtRrApproximateSize ].
	^ approximateSize < self maxBufferedSize
		ifTrue: [ GtRrBufferedCodeSyncTask ]
		ifFalse: [ GtRrFileCodeSyncTask ].
]

{ #category : #accessing }
GtRrCodeSyncTask class >> leJsonV4Name [

	^ #gtRrCodeSyncTask
]

{ #category : #accessing }
GtRrCodeSyncTask class >> maxBufferedSize [
	^ 256000
]

{ #category : #visiting }
GtRrCodeSyncTask >> acceptVisitor: aVisitor [

	^ aVisitor visitCodeSyncTask: self
]

{ #category : #executing }
GtRrCodeSyncTask >> applyOmbuEntry: anOmbuEntry [ 

	GtRrCodeSyncApplyChangeStartingSignal new
		initializeFromOmbuEntry: anOmbuEntry;
		emit.
		
	anOmbuEntry content 
		accept: GtExportedEventApplyVisitor new.
	
	GtRrCodeSyncApplyChangeCompletedSignal new
		initializeFromOmbuEntry: anOmbuEntry;
		emit.
]

{ #category : #accessing }
GtRrCodeSyncTask >> entries [
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
GtRrCodeSyncTask >> entries: aCollection [
	"Set the receiver's entries"
	
	self subclassResponsibility
]

{ #category : #accessing }
GtRrCodeSyncTask >> entriesReadStream [
	"Answer a readStream on the receiver's entries"
	
	^ self subclassResponsibility
]

{ #category : #'gt-extensions' }
GtRrCodeSyncTask >> gtChangesFor: aView [
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

{ #category : #'private - running' }
GtRrCodeSyncTask >> onJobCompleted [
	"Tidy up after the job has completed"
]

{ #category : #executing }
GtRrCodeSyncTask >> run [
	| stonReader |

	stonReader := STONReader on: (self entriesReadStream
		ifNil: [ ^ self ]).
	[ [ stonReader atEnd ] whileFalse:
		[ self applyOmbuEntry: stonReader next ] ]
			ensure: [ stonReader close ].
	^ true
]

{ #category : #accessing }
GtRrCodeSyncTask >> workerId: aString [
	"Set the constraint on the receiver to only run on the specified worker"

	self constraint: (GtRrEqualsConstraint attribute: #id value: aString)
]

{ #category : #private }
GtRrCodeSyncTask >> writeEntries: aCollection on: aStream [

	aCollection do: [ :each | | omEntry |
		omEntry := each copy.
		omEntry content: omEntry content asGtRrCompactChange.
		STON put: omEntry onStream: aStream ].
]
