Class {
	#name : #GtRrRabbitMqMonitor,
	#superclass : #Object,
	#instVars : [
		'taskQueueStatsCache',
		'resultQueueStatsCache',
		'mqServer',
		'runnerControlStatsCache'
	],
	#category : #'RemoteRunner-MQ'
}

{ #category : #ui }
GtRrRabbitMqMonitor >> gtResultQueueSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Result Queue';
		priority: 20;
		items: 
			[ mqServer isRunning ifTrue:
				[ self resultQueueStatsCache waitForAValue: 5.
				self resultQueueStatsCache value summaryAttributes ]
			ifFalse: [ self serverStoppedAttributes ] ];
		column: #Attribute text: [ :item | item first ];
		column: #Value text: [ :item | item second ];
		send: [ :item | item last ];
		updateWhen: GtTimeCachedObjectAnnouncement
			in: self resultQueueStatsCache announcer;
		actionUpdateButton
]

{ #category : #ui }
GtRrRabbitMqMonitor >> gtRunnerControlSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Runner Control';
		priority: 30;
		items: 
			[ mqServer isRunning ifTrue:
				[ self runnerControlStatsCache waitForAValue: 5.
				self runnerControlStatsCache value summaryAttributes ]
			ifFalse: [ self serverStoppedAttributes ] ];
		column: #Attribute text: [ :item | item first ];
		column: #Value text: [ :item | item second ];
		send: [ :item | item last ];
		updateWhen: GtTimeCachedObjectAnnouncement
			in: self runnerControlStatsCache announcer;
		actionUpdateButton
]

{ #category : #ui }
GtRrRabbitMqMonitor >> gtTaskQueueSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Task Queue';
		priority: 10;
		items: 
			[ mqServer isRunning ifTrue:
				[ self taskQueueStatsCache waitForAValue: 5.
				self taskQueueStatsCache value summaryAttributes ]
			ifFalse: [ self serverStoppedAttributes ] ];
		column: #Attribute text: [ :item | item first ];
		column: #Value text: [ :item | item second ];
		send: [ :item | item last ];
		updateWhen: GtTimeCachedObjectAnnouncement
			in: self taskQueueStatsCache announcer;
		actionUpdateButton
]

{ #category : #accessing }
GtRrRabbitMqMonitor >> mqServer [
	^ mqServer
]

{ #category : #accessing }
GtRrRabbitMqMonitor >> mqServer: anObject [
	mqServer := anObject
]

{ #category : #accessing }
GtRrRabbitMqMonitor >> resultQueueStatsCache [

	^ resultQueueStatsCache ifNil: [ resultQueueStatsCache := GtUpdatingTimeCachedObject
		get: [ (RabbitMqHttpClient
			host: mqServer mqHostName
			port: 15672
			user: mqServer mqUsername
			password: mqServer mqPassword)
				statisticsForQueue: mqServer class taskResultBaseName vhost: '/'. ]
		timeout: 15 seconds
		active: 5 minutes ]
]

{ #category : #accessing }
GtRrRabbitMqMonitor >> runnerControlStatsCache [

	^ runnerControlStatsCache ifNil: [ runnerControlStatsCache := GtUpdatingTimeCachedObject
		get: [ (RabbitMqHttpClient
			host: mqServer mqHostName
			port: 15672
			user: mqServer mqUsername
			password: mqServer mqPassword)
				statisticsForQueue: mqServer class runnerControlChannelBaseName vhost: '/'. ]
		timeout: 15 seconds
		active: 5 minutes ]
]

{ #category : #ui }
GtRrRabbitMqMonitor >> serverStoppedAttributes [

	^ {
		{ 'Server stopped'. true. }.
	}
]

{ #category : #accessing }
GtRrRabbitMqMonitor >> taskQueueStatsCache [

	^ taskQueueStatsCache ifNil: [ taskQueueStatsCache := GtUpdatingTimeCachedObject
		get: [ (RabbitMqHttpClient
			host: mqServer mqHostName
			port: 15672
			user: mqServer mqUsername
			password: mqServer mqPassword)
				statisticsForQueue: mqServer class taskQueueBaseName vhost: '/'. ]
		timeout: 15 seconds
		active: 5 minutes ]
]
