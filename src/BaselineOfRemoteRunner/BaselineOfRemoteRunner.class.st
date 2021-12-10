Class {
	#name : #BaselineOfRemoteRunner,
	#superclass : #BaselineOf,
	#category : #BaselineOfRemoteRunner
}

{ #category : #baselines }
BaselineOfRemoteRunner >> baseline: spec [
	<baseline>
	spec
		for: #common do: [
			spec
				baseline: 'Gt4PharoLink' with: [
					spec repository: 'github://feenkcom/gtoolkit-remote:main/src' ];
				package: 'RemoteRunner'
					with: [ spec requires: #('Gt4PharoLink' ) ] ]
]
