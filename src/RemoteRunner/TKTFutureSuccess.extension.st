Extension { #name : #TKTFutureSuccess }

{ #category : #'*RemoteRunner' }
TKTFutureSuccess >> gtRrValueFor: aView [

	<gtView>
	^ aView explicit
		  title: 'Value';
		  priority: 10;
		  stencil: [ GtInspector forObject: value ]
]
