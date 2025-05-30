Class {
	#name : #GtRrRabbitMqMonitor,
	#superclass : #GtRrRabbitMqManager,
	#instVars : [
		'taskQueueStatsCache',
		'resultQueueStatsCache',
		'mqServer'
	],
	#category : #'RemoteRunner-MQ'
}

{ #category : #ui }
GtRrRabbitMqMonitor >> gtResultQueueSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Result Queue';
		priority: 10;
		items: 
			[ mqServer isRunning ifTrue:
				[ self resultQueueStatsCache waitForAValue: 5.
				self resultQueueStatsCache value summaryAttributes ]
			ifFalse: [ self serverStoppedAttributes ] ];
		column: #Attribute text: [ :item | item first ];
		column: #Value text: [ :item | item second ];
		send: [ :item | item last ];
		updateWhen: GtTimeCachedObjectAnnouncement
			in: self taskQueueStatsCache announcer;
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
		get: [ GtRrRabbitMqManager new
			host: mqServer mqHostName, ':15672';
			username: mqServer mqUsername;
			password: mqServer mqPassword;
			statisticsForQueue: mqServer class taskResultBaseName vhost: '/'. ]
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
		get: [ GtRrRabbitMqManager new
			host: mqServer mqHostName, ':15672';
			username: mqServer mqUsername;
			password: mqServer mqPassword;
			statisticsForQueue: mqServer class taskQueueBaseName vhost: '/'. ]
		timeout: 15 seconds
		active: 5 minutes ]
]
