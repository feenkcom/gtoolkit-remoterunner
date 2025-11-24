"
GtRrS3Message stores the actual message in a configured S3 bucket and then on execution retrieves the message and passes control to it.

Note that the message is currently not deleted from the file system.
"
Class {
	#name : #GtRrS3Message,
	#superclass : #GtRrUrlMessage,
	#category : 'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrS3Message class >> scheme [

	^ #s3
]

{ #category : #storing }
GtRrS3Message class >> storeBuffer: aByteArray in: s3BucketUrl [
	"Store the supplied buffer in the given bucket.
	Answer the s3Url of the file."
	| localFile s3Url |

	localFile := FileReference newTempFilePrefix: 'GtRrUrlMessage-' suffix: '.dat'.
	localFile binaryWriteStreamDo: [ :stream |
		stream nextPutAll: aByteArray ].
	s3Url := (s3BucketUrl asZnUrl / localFile basename) asString.
	GtAwsS3CopyCommand new
		source: localFile fullName;
		destination: s3Url;
		execute.
	localFile ensureDelete.
	^ self new url: s3Url.
]

{ #category : #private }
GtRrS3Message >> retrieveMessage [
	"Retrieve the message using the AWS cli.
	This should be replaced by a ZnClient implementation."
	| localFile message |

	localFile := FileLocator temp / url asZnUrl lastPathSegment.
	GtAwsS3CopyCommand new
		source: url;
		destination: localFile fullName;
		execute.
	message := localFile binaryReadStreamDo: [ :stream |
		 (GtWireDecoder on: stream) next ].
	localFile ensureDelete.
	^ message
]
