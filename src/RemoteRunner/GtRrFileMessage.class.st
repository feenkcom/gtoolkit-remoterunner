Class {
	#name : #GtRrFileMessage,
	#superclass : #GtRrUrlMessage,
	#category : 'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrFileMessage class >> scheme [

	^ #file
]

{ #category : #storing }
GtRrFileMessage class >> storeBuffer: aByteArray in: aDirectoryUrl [
	"Store the supplied buffer in the given bucket.
	Answer the s3Url of the file."
	| localFile newUrl |

	localFile := aDirectoryUrl asZnUrl asFileReference /
		('GtRrUrlMessage-', UUID new asString36, '.dat').
	localFile binaryWriteStreamDo: [ :stream |
		stream nextPutAll: aByteArray ].
	newUrl := localFile asZnUrl.
	^ self new url: newUrl.
]

{ #category : #private }
GtRrFileMessage >> retrieveMessage [
	"Retrieve the message from the specified local file"
	| localFile message |

	localFile := url asZnUrl asFileReference.
	message := localFile binaryReadStreamDo: [ :stream |
		 (GtWireDecoder on: stream) next ].
	localFile ensureDelete.
	^ message
]
