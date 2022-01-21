Extension { #name : #Object }

{ #category : #'*RemoteRunner' }
Object >> gtRrAsError [

	^ GtRrError new
		  message: self asString;
		  setTrace;
		  yourself
]
