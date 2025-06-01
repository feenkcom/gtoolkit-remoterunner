Extension { #name : #StampErrorFrame }

{ #category : #'*RemoteRunner-MQ' }
StampErrorFrame >> gtBodyFor: aView [
	<gtView>

	body isString ifFalse: [ ^ aView empty ].
	^ aView text
		title: 'Body';
		priority: 10;
		text: [ body ]
]
