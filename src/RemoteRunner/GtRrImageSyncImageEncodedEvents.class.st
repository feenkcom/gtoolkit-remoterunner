"
GtRrImageSyncImageEncodedEvents provides pre-serialised Epicea events to synchronise a worker machine with the current image.  The list is regenerated automatically as events are added to the session log.
"
Class {
	#name : #GtRrImageSyncImageEncodedEvents,
	#superclass : #GtRrImageSyncEncodedEvents,
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #accessing }
GtRrImageSyncImageEncodedEvents >> updateEncodedEvents [
	"Update the receiver's encoded events."
	| newLatestOmReference imageSyncManager |

	imageSyncManager := GtRrImageSync uniqueInstance.
	newLatestOmReference := imageSyncManager epLog headReference.
	newLatestOmReference = latestOmReference ifTrue: [ ^ self ].
	latestOmReference := newLatestOmReference.
	sessionHistory := imageSyncManager sessionHistory.
	encodedEvents := imageSyncManager encodedChangesFrom: sessionHistory first.
]
