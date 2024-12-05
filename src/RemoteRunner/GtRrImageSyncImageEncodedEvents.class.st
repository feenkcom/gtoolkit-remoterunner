"
GtRrImageSyncImageEncodedEvents provides pre-serialised Epicea events to synchronise a worker machine with the current image.  The list is regenerated automatically as events are added to the session log.
"
Class {
	#name : #GtRrImageSyncImageEncodedEvents,
	#superclass : #GtRrImageSyncEncodedEvents,
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #accessing }
GtRrImageSyncImageEncodedEvents class >> leJsonV4Name [

	^ #gtRrChangesSyncImageEncodedEvents
]

{ #category : #accessing }
GtRrImageSyncImageEncodedEvents >> updateEncodedEvents [
	"Update the receiver's encoded events."
	| changesSyncManager |

	changesSyncManager := GtRrChangesSync uniqueInstance.
	sessionHistory := changesSyncManager sessionHistory.
	encodedEvents := changesSyncManager encodedChangesFrom: sessionHistory first.
]
