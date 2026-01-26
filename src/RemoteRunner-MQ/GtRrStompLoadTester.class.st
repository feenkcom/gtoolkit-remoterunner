Class {
	#name : #GtRrStompLoadTester,
	#superclass : #Object,
	#instVars : [
		'mqProcessor',
		'payloadSize',
		'messageCount',
		'timeout',
		'subscriptionId',
		'queue',
		'runId',
		'commandQueue',
		'receivedCount',
		'lastMessageReceivedTime',
		'sendQueued',
		'flushBufferDelay',
		'startReceive',
		'startSend',
		'runProcess',
		'username',
		'password',
		'hostname'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> connect [

	mqProcessor := GtRrStompMqProcessor new
		owner: self;
		mqUsername: username;
		mqPassword: password;
		mqHostName: hostname;
		commandChannelDefinition: commandQueue;
		messageChannelDefinition: queue;
		taskCallback:  [ :mqMessage :gtMessage :anOwner |
			self processMessage: mqMessage gt: gtMessage ].
	mqProcessor start.
	runId := UUID new printString.
]

{ #category : #ui }
GtRrStompLoadTester >> gtSummaryFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Summary';
		  priority: 5;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: #last;
		  actionUpdateButton.
]

{ #category : #accessing }
GtRrStompLoadTester >> hostname [
	^ hostname
]

{ #category : #accessing }
GtRrStompLoadTester >> hostname: anObject [
	hostname := anObject
]

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> initialize [

	super initialize.
	payloadSize := 4000.
	messageCount := 40000.
	timeout := 30.
	flushBufferDelay := 60 seconds.
	subscriptionId := 'loadtestGt'.
	queue := GtRrStompMqProcessor taskQueueDefinitionFor: subscriptionId.
	queue prefetchCount: 500.
	commandQueue := GtRrStompMqProcessor taskQueueDefinitionFor: subscriptionId, 'Command'.
]

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> messageWithSeqId: seq payload: aString [

	^ String streamContents: [ :stream |
		stream
			<< 'run_id=';
				<< runId; lf;
			<< 'seq=';
				print: seq; lf;
			<< aString ].
]

{ #category : #accessing }
GtRrStompLoadTester >> password [
	^ password
]

{ #category : #accessing }
GtRrStompLoadTester >> password: anObject [
	password := anObject
]

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> privateRun [

	self connect.
	receivedCount := 0.
	startSend := DateAndTime now.
	self sendMessages.
	sendQueued := DateAndTime now.
	flushBufferDelay wait.
	startReceive := DateAndTime now.
	self receiveMessages.
]

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> processMessage: mqMessage gt: gtMessage [ 

	gtMessage readStreamDo: [ :stream | | line fields |
		line := stream nextLine.
		fields := line splitOn: $=.
		self assert: fields second = runId.
		line := stream nextLine.
		fields := line splitOn: $=.
		self assert: fields second asNumber = receivedCount.
		mqProcessor write: mqMessage ackFrame.
		lastMessageReceivedTime := DateAndTime now.
		receivedCount := receivedCount + 1 ].
]

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> receiveMessages [

	mqProcessor subscribeToTaskMessages.
]

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> run [

	runProcess := [ [ self privateRun ] ensure: 
		[ flushBufferDelay wait.
		mqProcessor stop. ] ] fork.
]

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> sendMessage: anObject [

	mqProcessor
		sendGtMessage: anObject
		to: queue 
		headers: nil
]

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> sendMessages [
	| index payload |

	payload := String loremIpsum: payloadSize.
	index := 0.
	[ index < messageCount ] whileTrue:
		[ self sendMessage: (self messageWithSeqId: index payload: payload).
		index := index + 1. ].
]

{ #category : #'as yet unclassified' }
GtRrStompLoadTester >> stop [

	mqProcessor stop.
]

{ #category : #ui }
GtRrStompLoadTester >> summaryAttributes [
	| queueTime receiveTime |

	queueTime := [ sendQueued - startSend ]
		on: Error
		do: [ :ex | ex printString ].
	receiveTime := [ lastMessageReceivedTime - startReceive ]
		on: Error
		do: [ :ex | ex printString ].
	^ {
		{ 'Start Send'. startSend. }.
		{ 'Start Queued'. sendQueued. }.
		{ 'Queue Time'. queueTime. }.
		{ 'Start Receive'. startReceive. }.
		{ 'Last Receive'. lastMessageReceivedTime. }.
		{ 'Receive Time'. receiveTime. }.
		}.
]

{ #category : #accessing }
GtRrStompLoadTester >> username [
	^ username
]

{ #category : #accessing }
GtRrStompLoadTester >> username: anObject [
	username := anObject
]
