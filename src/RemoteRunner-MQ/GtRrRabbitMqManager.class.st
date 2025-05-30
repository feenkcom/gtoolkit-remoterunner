Class {
	#name : #GtRrRabbitMqManager,
	#superclass : #Object,
	#instVars : [
		'host',
		'username',
		'password',
		'scheme'
	],
	#category : #'RemoteRunner-MQ'
}

{ #category : #accessing }
GtRrRabbitMqManager >> host [
	^ host
]

{ #category : #accessing }
GtRrRabbitMqManager >> host: anObject [
	host := anObject
]

{ #category : #accessing }
GtRrRabbitMqManager >> password [
	^ password
]

{ #category : #accessing }
GtRrRabbitMqManager >> password: anObject [
	password := anObject
]

{ #category : #accessing }
GtRrRabbitMqManager >> purgeQueue: queueName vhost: vhost [
	| url client |

	url := (self scheme, '://', host) asZnUrl addPathSegments: {
		'api'.
		'queues'.
		vhost.
		queueName.
		'contents'. }.
	url
		username: username;
		password: password.
	client := ZnClient new.
	client delete: url.
	client isSuccess ifFalse:
		[ self error: 'Unable to purge queue ', queueName asString ].
	^ client
]

{ #category : #accessing }
GtRrRabbitMqManager >> scheme [
	^ scheme ifNil: [ 'http' ]
]

{ #category : #accessing }
GtRrRabbitMqManager >> scheme: anObject [
	scheme := anObject
]

{ #category : #accessing }
GtRrRabbitMqManager >> statisticsForQueue: queueName vhost: vhost [
	| url client |

	url := (self scheme, '://', host) asZnUrl addPathSegments: {
		'api'.
		'queues'.
		vhost.
		queueName. }.
	url
		username: username;
		password: password.
	client := ZnClient new.
	client
		accept: ZnMimeType applicationJson;
		get: url.
	client isSuccess ifFalse:
		[ self error: 'Unable to get statistics for: ', queueName asString ].
	^ GtRrRabbitMqQueueStatistics on:
		(STONJSON fromString: client response contents).
]

{ #category : #accessing }
GtRrRabbitMqManager >> username [
	^ username
]

{ #category : #accessing }
GtRrRabbitMqManager >> username: anObject [
	username := anObject
]
