Extension { #name : #StampMessageFrame }

{ #category : #'*RemoteRunner' }
StampMessageFrame >> gtViewHeadersFor: aView [
	<gtView>

	headers ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Headers';
		priority: 20;
		object: [ headers ];
		view: #gtLiveFor:
]
