Extension { #name : #EpClassModification }

{ #category : #'*RemoteRunner' }
EpClassModification >> asGtRrCompactChange [
	"Answer the receiver with any information that isn't required by a worker discarded.
	Class modifications are converted to a class addition, which is treated in the same way during replay, but doesn't carry the old definition with it."

	^ EpClassAddition class: newClass
]
