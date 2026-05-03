Class {
	#name : #BaselineOfRemoteRunner,
	#superclass : #BaselineOf,
	#category : #BaselineOfRemoteRunner
}

{ #category : #baseline }
BaselineOfRemoteRunner >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec postLoadDoIt: #'postLoadRemoteRunner:'.
		spec
			baseline: 'PharoLink' with: [
				spec repository: 'github://feenkcom/PharoLink:v0.8.520/src' ].
		spec
			baseline: 'GToolkitNotifications' with: [
				spec repository: 'github://feenkcom/gtoolkit-notifications:v0.7.94/src' ].
		spec
			baseline: 'Stamp' with: [
				spec repository: 'github://feenkcom/stamp:v0.6.6/repository' ].
		spec
			baseline: 'Gt4RabbitMq' with: [
				spec repository: 'github://feenkcom/gt4rabbitmq:v0.6.3/src' ].

		spec package: 'RemoteRunner' with: [
			spec requires: #(#PharoLink #GToolkitNotifications) ].
		spec package: 'RemoteRunner-MQ' with: [
			spec requires: #(#RemoteRunner #Stamp) ].
	]
]

{ #category : #postload }
BaselineOfRemoteRunner >> postLoadRemoteRunner: spec [

	self forPharo13AndNewer: 
		[ GtRrWorkerClapCommand class compile:
'commandLine
	<commandline>

	^ self commandLineCommand
		commandClass: GtRrWorkerClapCommand;
		yourself'
			classified: #'command line'.
		GtRrWorker class removeSelector: #commandLine ]
	forOlder:
		[ GtRrWorker class compile:
'commandLine
	<commandline>

	^ GtRrWorkerClapCommand commandLineCommand meaning: [ :args | 
		GtRrWorkerClapCommand new executeWithArgs: args ].'
			classified:  #'command line'.
		GtRrWorkerClapCommand class removeSelector: #commandLine ].
]
