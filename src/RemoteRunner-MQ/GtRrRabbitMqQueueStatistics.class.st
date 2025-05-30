Class {
	#name : #GtRrRabbitMqQueueStatistics,
	#superclass : #Object,
	#instVars : [
		'rawData'
	],
	#category : #'RemoteRunner-MQ'
}

{ #category : #'instance  creation' }
GtRrRabbitMqQueueStatistics class >> on: aDictionary [

	^ self new rawData: aDictionary
]

{ #category : #accessing }
GtRrRabbitMqQueueStatistics >> at: aString [

	^ rawData at: aString
]

{ #category : #ui }
GtRrRabbitMqQueueStatistics >> gtRawInfoFor: aView [
	<gtView>

	rawData ifNil: [ ^ aView empty ].
	
	^ aView forward
		title: 'Raw Info';
		priority: 40;
		object: [ rawData ];
		view: #gtLiveFor:
]

{ #category : #ui }
GtRrRabbitMqQueueStatistics >> gtSummaryFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item last ];
		  actionUpdateButton
]

{ #category : #accessing }
GtRrRabbitMqQueueStatistics >> rawData [
	^ rawData
]

{ #category : #accessing }
GtRrRabbitMqQueueStatistics >> rawData: anObject [
	rawData := anObject
]

{ #category : #'as yet unclassified' }
GtRrRabbitMqQueueStatistics >> summaryAttributes [
	| messageStats incoming deliver ack |

	messageStats := self at: 'message_stats'.
	incoming := String streamContents: [ :stream |
		stream
			print: (messageStats at: 'get');
			<< ' (';
			print: ((messageStats at: 'get_details') at: 'rate');
			<< '/s)' ].
	deliver := String streamContents: [ :stream |
		stream
			print: (messageStats at: 'deliver');
			<< ' (';
			print: ((messageStats at: 'deliver_details') at: 'rate');
			<< '/s)' ].
	ack := String streamContents: [ :stream |
		stream
			print: (messageStats at: 'ack');
			<< ' (';
			print: ((messageStats at: 'ack_details') at: 'rate');
			<< '/s)' ].
	^ {
		{ 'Ready'. self at: 'messages_ready'. }.
		{ 'Unacknowledged'. self at: 'messages_unacknowledged' }.
		{ 'Incoming (/s)'. incoming. }.
		{ 'Deliver (/s)'. deliver. }.
		{ 'Ack (/s)'. ack. }.
		{ 'Consumers'. self at: 'consumers'. }.
		{ 'Idle since'. self at: 'idle_since' }.
	}.
]
