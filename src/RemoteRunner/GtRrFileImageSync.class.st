Class {
	#name : #GtRrFileImageSync,
	#superclass : #GtRrImageSync,
	#instVars : [
		'entriesFile'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #accessing }
GtRrFileImageSync class >> leJsonV4Name [

	^ #gtRrFileImageSync
]

{ #category : #accessing }
GtRrFileImageSync class >> newEntriesFile [
	| tmpFile |

	tmpFile := FileReference newTempFilePrefix: self name asString suffix: '.ombu'.
	"Windows doesn't clean its temp dir, so make it local to the image"
	OSPlatform current isWindows ifTrue:
		[ | tmpDir |
		tmpDir := 'temp' asFileReference ensureCreateDirectory.
		tmpFile := tmpDir / tmpFile basename  ].
	^ tmpFile.
]

{ #category : #actions }
GtRrFileImageSync >> copyToFile: aFileReference [
	"Copy the receiver's serialised changes to the specified file"

	self entriesFile copyTo: aFileReference.
]

{ #category : #accessing }
GtRrFileImageSync >> entries: aCollection [
	"Write the omEntries to the file as individual entries, not a single collection"
	| omFileStore |
	
	omFileStore := OmFileStore
			named: self entriesFile basenameWithoutExtension
			inDirectory: self entriesFile parent.
	aCollection do: [ :entry |
		omFileStore newEntry: entry ].
	omFileStore flush.
	entriesCount := aCollection size.
]

{ #category : #accessing }
GtRrFileImageSync >> entriesFile [
	^ entriesFile ifNil: [ entriesFile := self class newEntriesFile ]
]

{ #category : #accessing }
GtRrFileImageSync >> entriesFile: aFileReference [

	aFileReference extension = 'ombu' ifFalse:
		[ self error: 'File must be of type `ombu`' ].

	entriesFile := aFileReference.
]

{ #category : #accessing }
GtRrFileImageSync >> entriesReadStream [

	self entriesFile exists ifFalse: [ ^ nil ].
	^ self entriesFile readStream
]

{ #category : #accessing }
GtRrFileImageSync >> serializedSize [

	^ entriesFile
		ifNil: [ 0 ]
		ifNotNil: [ :fr | fr exists
			ifTrue: [ fr size ]
			ifFalse: [ 0 ] ]
]
