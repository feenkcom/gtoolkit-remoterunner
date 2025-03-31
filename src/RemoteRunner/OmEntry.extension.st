Extension { #name : #OmEntry }

{ #category : #'*RemoteRunner' }
OmEntry >> asGtRrCompactChange [
	"Answer the receiver with any information that isn't required by a worker discarded"

	^ self copy content: content asGtRrCompactChange.
]
