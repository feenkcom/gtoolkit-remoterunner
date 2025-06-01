Extension { #name : #StampFrame }

{ #category : #'*RemoteRunner-MQ' }
StampFrame >> gtHeadersFor: aView [
	<gtView>

	^ aView forward
		title: 'Headers';
		priority: 20;
		object: [ self headers ];
		view: #gtLiveFor:
]
