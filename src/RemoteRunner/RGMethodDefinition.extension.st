Extension { #name : #RGMethodDefinition }

{ #category : #'*RemoteRunner' }
RGMethodDefinition >> gtRrApproximateSize [

	^ sourceCode size
]

{ #category : #'*RemoteRunner' }
RGMethodDefinition >> gtRrApproximateSizeWithData [
	^self gtRrApproximateSize
]
