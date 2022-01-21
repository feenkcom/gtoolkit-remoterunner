Extension { #name : #TKTFuture }

{ #category : #'*RemoteRunner' }
TKTFuture >> gtRrResultFor: aView [

	<gtView>
	^ aView explicit
		  title: 'State';
		  priority: 10;
		  stencil: [ GtInspector forObject: result ]
]
