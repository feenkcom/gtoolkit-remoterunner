Extension { #name : #Monitor }

{ #category : #'*RemoteRunner' }
Monitor >> size [
	<gtPharoPatch: #Pharo>
	
	^ mutex size
]
