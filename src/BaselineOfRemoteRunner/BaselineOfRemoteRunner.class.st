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
				spec repository: 'github://feenkcom/PharoLink:v0.8.450/src' ].
		spec
			baseline: 'GToolkitNotifications' with: [
				spec repository: 'github://feenkcom/gtoolkit-notifications:v0.6.1219/src' ].
		spec
			baseline: 'Stamp' with: [
				spec repository: 'github://feenkcom/stamp:v0.6.0/repository' ].

		spec package: 'RemoteRunner' with: [
			spec requires: #(#PharoLink #GToolkitNotifications) ].
		spec package: 'RemoteRunner-MQ' with: [
			spec requires: #(#RemoteRunner #Stamp) ].
	]
]
