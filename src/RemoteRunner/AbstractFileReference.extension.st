Extension { #name : #AbstractFileReference }

{ #category : #'*RemoteRunner' }
AbstractFileReference >> gtRemoteRunnerLogFor: aView [
	<gtView>
	
	((self basename beginsWith: 'remoteRunner') and:
		[ self extension = 'log' ]) ifFalse:
			[ ^ aView empty ].
	^ aView forward
		title: 'Remote Runner Log';
		priority: 10;
		object: 
			[ | reader |
			reader := GtRrRunnerLogReader new 
				filename: self;
				strictMode: false.
			reader load.
			reader. ];
		view: #gtSignalsFor:.
]
