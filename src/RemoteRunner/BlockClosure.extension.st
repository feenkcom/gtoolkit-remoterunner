Extension { #name : #BlockClosure }

{ #category : #'*RemoteRunner' }
BlockClosure >> stonOn: aWriter [
	<gtPharoPatch: #Pharo>
	
	self printString stonOn: aWriter
]
