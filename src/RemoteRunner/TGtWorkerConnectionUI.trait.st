Trait {
	#name : #TGtWorkerConnectionUI,
	#category : #'RemoteRunner-UI'
}

{ #category : #ui }
TGtWorkerConnectionUI >> gtPlaygroundActionFor: anAction [
	<gtAction>

	^ anAction explicit 
		stencil:[ 
			GtRrWorkerPortNumberStencil new workerConnection: self ]
]
