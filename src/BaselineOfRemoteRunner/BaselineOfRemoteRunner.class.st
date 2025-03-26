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
				baseline: 'PharoLink' with: [
					spec repository: 'github://feenkcom/PharoLink:main/src' ];
				baseline: 'GToolkitNotifications' with: [
					spec repository: 'github://feenkcom/gtoolkit-notifications:main/src' ];
				baseline: 'Stamp' with: [
					spec repository: 'github://feenkcom/stamp/repository' ];
				package: 'RemoteRunner'
					with: [ spec requires: #('PharoLink' 'GToolkitNotifications') ];
				package: 'RemoteRunner-MQ'
					with: [ spec requires: #('RemoteRunner' 'Stamp') ] ]
]
