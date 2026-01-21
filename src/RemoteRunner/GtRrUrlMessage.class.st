Class {
	#name : #GtRrUrlMessage,
	#superclass : #GtRrMessage,
	#instVars : [
		'url'
	],
	#classVars : [
		'WorkerConfiguration'
	],
	#category : 'RemoteRunner-Model'
}

{ #category : #'instance creation' }
GtRrUrlMessage class >> classForScheme: aSymbol [

	^ self allSubclasses 
		detect: [ :cls | cls scheme =  aSymbol ]
		ifNone: [ self error: 'Unknown scheme: ', aSymbol asString ]
]

{ #category : #accessing }
GtRrUrlMessage class >> scheme [

	^ self subclassResponsibility
]

{ #category : #storing }
GtRrUrlMessage class >> store: aGtRrMessage in: s3BucketUrl [
	"Store the supplied message in the given bucket.
	Answer the s3Url of the file."

	^ self storeBuffer: (GtWireEncoder onByteArray nextPut: aGtRrMessage) contents
		in: s3BucketUrl
]

{ #category : #storing }
GtRrUrlMessage class >> storeBuffer: aByteArray in: aUrl [
	"Store the supplied buffer in the given URL.
	Answer the Url of the file."

	^ (self classForScheme: aUrl asZnUrl scheme)
		storeBuffer: aByteArray in: aUrl
]

{ #category : #private }
GtRrUrlMessage >> asyncWorkerConfiguration [

	^ WorkerConfiguration ifNil:
		[ WorkerConfiguration := AsyncFutureExecutionConfiguration new
			customGroup: #GtRrUrlMessageProcessor;
			maxAmountOfWorkers: 10;
			defaultPriority ].
]

{ #category : #processing }
GtRrUrlMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	([ self retrieveMessage 
		processMq: mqMessage 
		processor: aGtRrProcessor 
		for: anOwner ] asAsyncFuture
			await: self asyncWorkerConfiguration)
				then: [ :v | ]
				otherwise: [ :ex |
					ex freeze.
					[ | theError |
					theError := ex.
					self error: 'Unexpected error while processing Url Message: ', theError messageText printString ] fork ].
]

{ #category : #private }
GtRrUrlMessage >> retrieveMessage [

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrUrlMessage >> url [
	^url
]

{ #category : #accessing }
GtRrUrlMessage >> url: aUrl [

	url := aUrl
]
