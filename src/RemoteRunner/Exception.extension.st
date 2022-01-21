Extension { #name : #Exception }

{ #category : #'*RemoteRunner' }
Exception >> gtRrAsError [

	^ GtRrError new
		  message: messageText;
		  trace: self stackString;
		  yourself
]
