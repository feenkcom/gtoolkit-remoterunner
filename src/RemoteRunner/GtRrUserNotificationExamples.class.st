Class {
	#name : #GtRrUserNotificationExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#instVars : [
		'runner'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrUserNotificationExamples >> notifyOnChangesSyncError [
	"Check that the notification is opened when an error occurs during a changes sync request."

	<gtExample>
	<after: #stopLogging>
	<return: #GtRrUserNotificationExamples>
	| omReference |
	runner := GtRemoteRunner new.
	runner startAnnouncementsNotifier.
	omReference := OmReference globalName: 'nonexistent' localName: '-1'.
	PharoLinkServerCurrentConnection
		value: GtRrPseudoPharoLinkServerConnection new
		during: [ self
				should: [ runner changesSyncEventsFrom: omReference workerId: nil ]
				raise: Error ].
	self assert: runner logNotifier announcementCount equals: 1
]

{ #category : #examples }
GtRrUserNotificationExamples >> notifyOnChangesSyncSuccess [
	"Check that the notification is opened when an error occurs during a changes sync request."

	<gtExample>
	<after: #stopLogging>
	<return: #GtRrUserNotificationExamples>
	| omReference |
	runner := GtRemoteRunner new.
	runner startAnnouncementsNotifier.
	omReference := GtRrChangesSync headReference.	"If this is the null reference and we've been started with detachChangesFromFileSystem use the latest recorded session"
	(omReference isNull and: [ Smalltalk argumentsInclude: '--epiceaMemoryStore' ])
		ifTrue: [ omReference := GtRrChangesSync uniqueInstance sessionHistory last ].
	self deny: omReference isNull description: 'Should not have a null omReference'.
	PharoLinkServerCurrentConnection
		value: GtRrPseudoPharoLinkServerConnection new
		during: [ runner changesSyncEventsFrom: omReference workerId: nil ].
	self assert: runner logNotifier announcementCount equals: 0
]

{ #category : #private }
GtRrUserNotificationExamples >> stopLogging [

	runner ifNil: [ ^ self ].
	runner logNotifier ifNotNil:
		[ :notifierListener | notifierListener notification ifNotNil:
			[ :notification | [ notification requestRemoval ] forkAt: 15 ] ].
	runner stopLogging.
]
