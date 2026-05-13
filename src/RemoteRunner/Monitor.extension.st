Extension { #name : #Monitor }

{ #category : #'*RemoteRunner' }
Monitor >> isNotEmpty [
	<gtPharoPatch: #Pharo>
	
	^ mutex isNotEmpty
]

{ #category : #'*RemoteRunner' }
Monitor >> size [
	<gtPharoPatch: #Pharo>
	
	^ mutex size
]
