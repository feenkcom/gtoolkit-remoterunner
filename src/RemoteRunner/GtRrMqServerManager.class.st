Class {
	#name : #GtRrMqServerManager,
	#superclass : #GtRrServerManager,
	#instVars : [
		'mqServer'
	],
	#category : 'RemoteRunner-Runner-Manager'
}

{ #category : #accessing }
GtRrMqServerManager >> mqHostName [

	^ mqServer mqHostName
]

{ #category : #accessing }
GtRrMqServerManager >> mqHostName: aString [

	mqServer mqHostName: aString
]

{ #category : #accessing }
GtRrMqServerManager >> mqPassword [

	^ mqServer mqPassword
]

{ #category : #accessing }
GtRrMqServerManager >> mqPassword: aString [

	mqServer mqPassword: aString
]

{ #category : #accessing }
GtRrMqServerManager >> mqPort [

	^ mqServer mqPort
]

{ #category : #accessing }
GtRrMqServerManager >> mqPort: anInteger [

	mqServer mqPort: anInteger
]

{ #category : #accessing }
GtRrMqServerManager >> mqUsername [

	^ mqServer mqUsername
]

{ #category : #accessing }
GtRrMqServerManager >> mqUsername: aString [

	mqServer mqUsername: aString
]

{ #category : #'as yet unclassified' }
GtRrMqServerManager >> shutdown [

	mqServer stop.
]

{ #category : #'as yet unclassified' }
GtRrMqServerManager >> startup [

	mqServer := GtRrMqServer new
		remoteRunner: remoteRunner.
	remoteRunner server: mqServer.
	mqServer start.
]
