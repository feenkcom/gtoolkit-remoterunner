"
GtRrStompMqS3Processor sends large (> 64k) messages via the specified S3 bucket.
"
Class {
	#name : #GtRrStompMqS3Processor,
	#superclass : #GtRrStompMqProcessor,
	#instVars : [
		's3Bucket'
	],
	#classVars : [
		'MaxMessageSize'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #accessing }
GtRrStompMqS3Processor class >> maxMessageSize [
	^MaxMessageSize ifNil: [ 4000000 ]
]

{ #category : #accessing }
GtRrStompMqS3Processor class >> maxMessageSize: anObject [
	MaxMessageSize := anObject
]

{ #category : #accessing }
GtRrStompMqS3Processor >> s3Bucket [
	^s3Bucket
]

{ #category : #accessing }
GtRrStompMqS3Processor >> s3Bucket: aZnUrl [
	s3Bucket := aZnUrl asZnUrl
]

{ #category : #private }
GtRrStompMqS3Processor >> serializedGtMessage: aGtRrMessage [
	"Answer the serialised message.
	If the buffer is >= 64k, send the message via s3."
	| messageBuffer s3Message |

	messageBuffer := GtWireEncoder onByteArray
		nextPut: aGtRrMessage;
		contents.
	messageBuffer size < self class maxMessageSize ifTrue: [ ^ messageBuffer ].

	s3Bucket ifNil: [ self error: 'MQ S3 bucket not configured' ].

	s3Message := GtRrS3Message storeBuffer: messageBuffer in: s3Bucket.
	^ GtWireEncoder onByteArray
		nextPut: s3Message;
		contents.
]
