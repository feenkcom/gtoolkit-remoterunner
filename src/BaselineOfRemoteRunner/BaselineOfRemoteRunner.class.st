Class {
	#name : #BaselineOfRemoteRunner,
	#superclass : #BaselineOf,
	#category : #BaselineOfRemoteRunner
}

{ #category : #baseline }
BaselineOfRemoteRunner >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			baseline: 'PharoLink' with: [
				spec repository: 'github://feenkcom/PharoLink:v0.8.371/src' ].
		spec
			baseline: 'GToolkitNotifications' with: [
				spec repository: 'github://feenkcom/gtoolkit-notifications:v0.6.899/src' ].

		spec package: 'RemoteRunner' with: [
			spec requires: #('PharoLink' 'GToolkitNotifications') ].
	]
]
