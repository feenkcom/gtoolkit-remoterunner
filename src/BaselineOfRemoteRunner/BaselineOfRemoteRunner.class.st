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
			spec postLoadDoIt: #postLoadRemoteRunner:.
			spec
				baseline: 'PharoLink' with: [
					spec repository: 'github://feenkcom/PharoLink:main/src' ];
				baseline: 'GToolkitNotifications' with: [
					spec repository: 'github://feenkcom/gtoolkit-notifications:main/src' ];
				baseline: 'Stamp' with: [
					spec repository: 'github://feenkcom/stamp/repository' ];
				baseline: 'Gt4RabbitMq' with: [
					spec repository: 'github://feenkcom/gt4rabbitmq:main/src' ];
				package: 'RemoteRunner'
					with: [ spec requires: #('PharoLink' 'GToolkitNotifications') ];
				package: 'RemoteRunner-MQ'
					with: [ spec requires: #('RemoteRunner' 'Stamp') ] ]
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
