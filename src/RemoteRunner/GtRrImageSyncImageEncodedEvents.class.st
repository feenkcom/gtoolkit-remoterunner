"
GtRrImageSyncImageEncodedEvents provides pre-serialised Epicea events to synchronise a worker machine with the current image.  The list is regenerated automatically as events are added to the session log.
"
Class {
	#name : #GtRrImageSyncImageEncodedEvents,
	#superclass : #GtRrImageSyncEncodedEvents,
	#instVars : [
		'latestOmReference'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #accessing }
GtRrImageSyncImageEncodedEvents class >> leJsonV4Name [

	^ #gtRrChangesSyncImageEncodedEvents
]

{ #category : #accessing }
GtRrImageSyncImageEncodedEvents >> updateEncodedEvents [
	"Update the receiver's encoded events."
	| newLatestOmReference changesSyncManager |

	changesSyncManager := GtRrChangesSync uniqueInstance.
	newLatestOmReference := changesSyncManager epLog headReference.
	newLatestOmReference = latestOmReference ifTrue: [ ^ self ].
	latestOmReference := newLatestOmReference.
	sessionHistory := changesSyncManager sessionHistory.
	encodedEvents := changesSyncManager encodedChangesFrom: sessionHistory first.
]
