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
				spec repository: 'github://feenkcom/PharoLink:v0.8.525/src' ].
		spec
			baseline: 'GToolkitNotifications' with: [
				spec repository: 'github://feenkcom/gtoolkit-notifications:v0.7.128/src' ].
		spec
			baseline: 'Stamp' with: [
				spec repository: 'github://feenkcom/stamp:v0.6.6/repository' ].
		spec
			baseline: 'Gt4RabbitMq' with: [
				spec repository: 'github://feenkcom/gt4rabbitmq:v0.6.4/src' ].

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
			classified: #'*Pharo-Compatibility'.
		
		ClapCodeEvaluator class compile:
'evaluate
	<commandline>
	<gtPharoPatch: #Pharo13>
	^ (ClapCommandSpec id: #evaluate)
		aliases: #(''eval'');
		commandClass: self;
		description: ''Print the result of a Pharo expression'';
		addHelp;
		addGtGlobalOptions;
		addFlag: #save description: ''Save the image after evaluation'';
		addFlag: #keepAlive description: ''Keep image running'';
		addPositional: #EXPR spec: [ :positional |
			positional
				description: ''The expression to evaluate, joining successive arguments with spaces (if omitted, read the expression from stdin)'';
				multiple: true;
				defaultValue: [ :match | "in the absence of an explicit argument, read from standard input"
					Array with: match context stdin upToEnd ] ];
		yourself'
			classified: #'*Pharo-Compatibility'. ]
	forOlder:
		[ GtRrWorker class compile:
'commandLine
	<commandline>

	^ GtRrWorkerClapCommand commandLineCommand meaning: [ :args | 
		GtRrWorkerClapCommand new executeWithArgs: args ].'
			classified:  #'*Pharo-Compatibility'. ].
]
