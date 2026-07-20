Class {
	#name : #GtRrFileCodeSyncTask,
	#superclass : #GtRrCodeSyncTask,
	#instVars : [
		'entriesFile'
	],
	#category : #'RemoteRunner-Runner-CodeSync'
}

{ #category : #accessing }
GtRrFileCodeSyncTask class >> leJsonV4Name [

	^ #gtRrFileCodeSyncTask
]

{ #category : #accessing }
GtRrFileCodeSyncTask class >> newEntriesFile [
	| tmpFile |

	tmpFile := FileReference newTempFilePrefix: self name asString suffix: '.ombu'.
	"Windows doesn't clean its temp dir, so make it local to the image"
	OSPlatform current isWindows ifTrue:
		[ | tmpDir |
		tmpDir := 'temp' asFileReference ensureCreateDirectory.
		tmpFile := tmpDir / tmpFile basename  ].
	^ tmpFile
]

{ #category : #accessing }
GtRrFileCodeSyncTask >> entries: aCollection [
	"Write the omEntries to the file as individual entries, not a single collection"

	self entriesFile writeStreamDo: [ :fileStream |
		self writeEntries: aCollection on: fileStream ].
]

{ #category : #accessing }
GtRrFileCodeSyncTask >> entriesFile [
	^ entriesFile ifNil: [ entriesFile := self class newEntriesFile ]
]

{ #category : #accessing }
GtRrFileCodeSyncTask >> entriesFile: anObject [
	entriesFile := anObject
]

{ #category : #accessing }
GtRrFileCodeSyncTask >> entriesReadStream [

	self entriesFile exists ifFalse: [ self error: 'Entries file doesn''t exist: ', self entriesFile fullName].
	^ self entriesFile readStream
]

{ #category : #private }
GtRrFileCodeSyncTask >> onJobCompleted [
	"Tidy up after the job has completed"
	
	entriesFile ifNotNil:
		[ entriesFile ensureDelete ].
]
