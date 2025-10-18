Extension { #name : #EpExpressionEvaluation }

{ #category : #'*RemoteRunner' }
EpExpressionEvaluation >> gtRrApproximateSize [
	"Answer the approximate size of the receiver in memory."
	
	^ expression sizeInMemory
]
